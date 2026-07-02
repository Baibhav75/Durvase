import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'attendanceOutPage.dart';
import '../widgets/location_display_widget.dart';
import '../model/TodoModel.dart';
import '../service/attendance_manager.dart';

class AttendancePage extends StatefulWidget {
  final TodoModel userData;

  const AttendancePage({super.key, required this.userData});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _currentTime = "";
  String _currentDate = "";
  double? _latitude;
  double? _longitude;
  Timer? _timer;
  Timer? _durationTimer;
  File? _capturedImage;

  // Attendance manager instance
  final AttendanceManager _attendanceManager = AttendanceManager();

  // Check-in status
  bool _isCheckedIn = false;
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _getCurrentLocation();
    _checkAttendanceStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  // Check if user is already checked in
  Future<void> _checkAttendanceStatus() async {
    try {
      setState(() {
        _isCheckedIn = _attendanceManager.isCheckedIn;
        _isCheckingStatus = false;
      });

      // If user is checked in, restore the session and continue timing
      if (_isCheckedIn) {
        // Restore data from AttendanceManager
        _capturedImage = _attendanceManager.checkInImage;
        _latitude = _attendanceManager.checkInLatitude;
        _longitude = _attendanceManager.checkInLongitude;

        // Start the duration timer
        _startDurationTimer();

        // Navigate to checkout page automatically
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToCheckoutPage();
        });
      }
    } catch (e) {
      print('Error checking attendance status: $e');
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  void _startNewSession() {
    // Session is now managed by AttendanceManager
    _startDurationTimer();
  }

  // Start a timer to continuously update the work duration display
  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_attendanceManager.isCheckedIn) {
        setState(() {
          // Trigger rebuild to update duration display
        });
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();

    int hour = now.hour % 12;
    if (hour == 0) hour = 12;
    String minute = now.minute.toString().padLeft(2, '0');
    String period = now.hour >= 12 ? 'PM' : 'AM';

    setState(() {
      _currentTime = "$hour:$minute $period";
      _currentDate =
      "${_getWeekday(now.weekday)}, ${_getMonth(now.month)} ${now.day}, ${now.year}";
    });
  }

  String _getWeekday(int day) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[day - 1];
  }

  String _getMonth(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  // Get formatted work duration string
  String _getWorkDurationString() {
    if (_attendanceManager.isCheckedIn) {
      return _attendanceManager.getFormattedWorkDuration();
    }
    return "0 h 0 m";
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });

        // Check in using AttendanceManager
        _attendanceManager.checkIn(
          checkInTime: DateTime.now(),
          latitude: _latitude ?? 0.0,
          longitude: _longitude ?? 0.0,
          checkInImage: _capturedImage!,
          locationName: "Capital Icon",
        );

        // Start new session
        _startNewSession();

        // Update local state
        setState(() {
          _isCheckedIn = true;
        });

        // Navigate to checkout page
        _navigateToNextPage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToNextPage() {
    if (_attendanceManager.isCheckedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceOutPage(
            userData: widget.userData,
            capturedImage: _attendanceManager.checkInImage,
            checkInTime: _attendanceManager.checkInTime!,
            checkInLatitude: _attendanceManager.checkInLatitude,
            checkInLongitude: _attendanceManager.checkInLongitude,
            locationName: _attendanceManager.locationName,
            onCheckOut: (checkOutTime) {
              // Clear attendance state after checkout
              _attendanceManager.checkOut();
              setState(() {
                _isCheckedIn = false;
                _capturedImage = null;
              });
            },
          ),
        ),
      );
    }
  }

  // Navigate directly to checkout page
  void _navigateToCheckoutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceOutPage(
          userData: widget.userData,
          capturedImage: _attendanceManager.checkInImage,
          checkInTime: _attendanceManager.checkInTime!,
          checkInLatitude: _attendanceManager.checkInLatitude,
          checkInLongitude: _attendanceManager.checkInLongitude,
          locationName: _attendanceManager.locationName,
          onCheckOut: (checkOutTime) {
            // Clear attendance state after checkout
            _attendanceManager.checkOut();
            setState(() {
              _isCheckedIn = false;
              _capturedImage = null;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking status
    if (_isCheckingStatus) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Attendance",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Attendance",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Bar with Title Only
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "Welcome To Attendify!",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Current Time and Date
              Text(
                _currentTime,
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentDate,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Current Session Status
              if (_attendanceManager.isCheckedIn) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45CEEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Active Session",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Checked in at ${_attendanceManager.getFormattedCheckInTime()}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Duration: ${_attendanceManager.getFormattedWorkDuration()}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Check-in Button
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow effect
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // Main button
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4B0082), Color(0xFF6A0DAD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _attendanceManager.isCheckedIn ? "CHECK-OUT" : "CHECK-IN",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Instruction text
              Text(
                _attendanceManager.isCheckedIn
                    ? "Tap to check-out and complete session"
                    : "Tap to take photo for check-in",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),

              // Show captured image preview if available
              if (_capturedImage != null) ...[
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Captured Image",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_capturedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // Location Info Card
              LocationDisplayWidget(
                latitude: _latitude,
                longitude: _longitude,
                isLocating: _latitude == null && _longitude == null,
                onRefresh: _getCurrentLocation,
              ),

              const SizedBox(height: 25),

              // Quick Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      "Today",
                      _getWorkDurationString(),
                      Icons.today,
                    ),
                    _buildStatItem(
                      "This Week",
                      "42h 15m",
                      Icons.calendar_today,
                    ),
                    _buildStatItem(
                      "Status",
                      _attendanceManager.isCheckedIn ? "Active" : "Ready",
                      Icons.fact_check,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Map View
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Office Location",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/maplogo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Map Preview",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepPurple, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}