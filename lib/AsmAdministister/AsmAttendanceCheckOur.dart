import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../employeehomePage.dart';
import '/model/attendance_model.dart';
import '/service/attendance_service.dart';
import '../widgets/location_display_widget.dart';
import '../service/geocoding_service.dart';
import '../service/attendance_manager.dart';
import '../model/TodoModel.dart'; // Add this import
import '../service/api_serviceProfile.dart';
import 'asmHomePage.dart';

class AsmAttendanceOutPage extends StatefulWidget {
  final File? capturedImage; // This is the check-in image
  final Function(DateTime)? onCheckOut;
  final DateTime checkInTime;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String locationName;
  final TodoModel userData; // Add userData parameter
  final String userId;

  const AsmAttendanceOutPage({
    super.key,
    this.capturedImage,
    this.onCheckOut,
    required this.checkInTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.locationName = "Capital Icon",
    required this.userData, // Add required userData parameter
    required this.userId,
  });



  @override
  State<AsmAttendanceOutPage> createState() => _AsmAttendanceOutPageState();
}

class _AsmAttendanceOutPageState extends State<AsmAttendanceOutPage> {
  late String _currentTime;
  late DateTime _checkInTime;
  Duration _workDuration = Duration.zero;
  Timer? _timer;
  bool _isSubmitting = false;
  File? _checkOutImage;

  // Current location for checkout
  double? _currentLatitude;
  double? _currentLongitude;
  String _currentLocationName = "Capital Icon";
  bool _isGettingLocation = false;

  // City names for check-in and check-out locations
  String? _checkInCityName;
  String? _checkOutCityName;
  bool _isGettingCheckInCity = false;
  bool _isGettingCheckOutCity = false;

  @override
  void initState() {
    super.initState();
    // Try to get check-in time from widget or SharedPreferences
    _initializeCheckInTime();
    _currentTime = _formatTime(DateTime.now());
    _startClock();
    _getCurrentLocation(); // Get current location on init
    _getCheckInCityName(); // Get check-in location city name
  }

  // Initialize check-in time from widget or AttendanceManager
  void _initializeCheckInTime() async {
    try {
      // Use the checkInTime from widget if available, otherwise get from AttendanceManager
      if (widget.checkInTime != null) {
        _checkInTime = widget.checkInTime;
      } else {
        // Try to get from AttendanceManager
        final attendanceManager = AttendanceManager();
        if (attendanceManager.checkInTime != null) {
          _checkInTime = attendanceManager.checkInTime!;
        } else {
          // Fallback to current time
          _checkInTime = DateTime.now();
        }
      }

      // Update work duration
      setState(() {
        _workDuration = DateTime.now().difference(_checkInTime);
      });
    } catch (e) {
      print('Error initializing check-in time: $e');
      _checkInTime = DateTime.now();
    }
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        final now = DateTime.now();
        _currentTime = _formatTime(now);
        _workDuration = now.difference(_checkInTime);
      });
    });
  }

  String _formatTime(DateTime time) {
    return "${_padZero(time.hour)}:${_padZero(time.minute)}:${_padZero(time.second)}";
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _padZero(int value) => value.toString().padLeft(2, '0');

  // Get current location for checkout
  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location service is enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
            SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permissions are permanently denied, we cannot request permissions.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });

      // Get address for the current location to send to API
      try {
        final address = await GeocodingService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          setState(() {
            _currentLocationName = address;
          });
        }
      } catch (e) {
        print("Error getting address: $e");
      }

      setState(() {
        _isGettingLocation = false;
      });

      // Get city name for check-out location
      _getCheckOutCityName();

      print('📍 Checkout Location Captured:');
      print('   Latitude: $_currentLatitude');
      print('   Longitude: $_currentLongitude');
      print('   Address: $_currentLocationName');
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Capture checkout image
  Future<void> _captureCheckOutImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80, // Reduce quality for smaller file size
      );

      if (image != null) {
        setState(() {
          _checkOutImage = File(image.path);
        });

        // Also get location when capturing checkout image
        await _getCurrentLocation();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing checkout image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show confirmation dialog first
  void _showCheckoutPopup() {
    _timer?.cancel();
    final checkOutTime = DateTime.now();

    // Ensure we have current location before showing dialog
    if (_currentLatitude == null || _currentLongitude == null) {
      _getCurrentLocation().then((_) {
        _showCheckoutDialog(checkOutTime);
      });
    } else {
      _showCheckoutDialog(checkOutTime);
    }
  }

  void _showCheckoutDialog(DateTime checkOutTime) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                title: Text(
                  "Check Out?",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Are you sure you want to check out?",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Work Duration: ${_formatDuration(_workDuration)}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location status
                    Row(
                      children: [
                        Icon(
                          _currentLatitude != null
                              ? Icons.check_circle
                              : Icons.location_off,
                          color: _currentLatitude != null
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentLatitude != null
                              ? "Location captured"
                              : "Getting location...",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _currentLatitude != null
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Checkout image capture
                    if (_checkOutImage == null) ...[
                      ElevatedButton(
                        onPressed: () async {
                          await _captureCheckOutImage();
                          if (_checkOutImage != null && _currentLatitude != null) {
                            Navigator.pop(context); // Close dialog
                            _submitAttendanceToAPI(DateTime.now()); // Auto-submit!
                          } else {
                            setStateDialog(() {}); // Update the dialog state
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: Text(
                          "Capture Checkout Photo",
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Checkout photo captured!",
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      _startClock(); // Restart timer
                    },
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(color: Colors.grey[600]),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (_checkOutImage != null && _currentLatitude != null)
                        ? () async {
                      Navigator.pop(context); // Close confirmation dialog

                      await _submitAttendanceToAPI(checkOutTime);

                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AsmhomepageHomePage(
                              userId: widget.userId,
                              userData: widget.userData,
                            ),
                          ),
                              (route) => false,
                        );
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text(
                      "Check Out",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }); // Close StatefulBuilder
      },
    );
  }

  // API submission method with proper data handling
  Future<void> _submitAttendanceToAPI(DateTime checkOutTime) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Use actual employee data from widget.userData
      String employeeId = widget.userData.empId ?? "UNKNOWN";
      if (widget.userData.mobile != null) {
        try {
          final profileData = await ApiService.fetchProfile(widget.userData.mobile!);
          if (profileData != null && profileData.data1 != null && profileData.data1!.isNotEmpty) {
            employeeId = profileData.data1!.first.empId ?? employeeId;
          }
        } catch (e) {
          print('Could not fetch profile for empId: $e');
        }
      }

      final String employeeName = widget.userData.name ?? "Unknown Employee";
      final String employeeMobile = widget.userData.mobile ?? "Unknown";

      // Check if attendance was recently submitted to prevent duplicates
      final wasRecentlySubmitted = await AttendanceService.wasRecentlySubmitted(
        employeeId,
      );
      if (wasRecentlySubmitted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Attendance already submitted recently. Please wait before submitting again.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Validate required data
      if (_currentLatitude == null || _currentLongitude == null) {
        throw Exception('Checkout location is required');
      }

      if (_checkOutImage == null) {
        throw Exception('Checkout photo is required');
      }

      print('🎯 Attendance Submission Debug:');
      print('   Employee: $employeeName ($employeeId)');
      print('   Check-in Time: $_checkInTime');
      print('   Check-out Time: $checkOutTime');
      print(
        '   Check-in Location: ${widget.checkInLatitude}, ${widget.checkInLongitude}',
      );
      print('   Check-out Location: $_currentLatitude, $_currentLongitude');
      print('   Work Duration: $_workDuration');
      print('   Has Check-in Image: ${widget.capturedImage != null}');
      print('   Has Check-out Image: ${_checkOutImage != null}');

      // Submit to API with both images and locations
      final result = await AttendanceService.submitAttendance(
        employeeId: employeeId,
        employeeName: employeeName,
        checkInTime: _checkInTime,
        checkOutTime: checkOutTime,
        checkInLatitude: widget.checkInLatitude ?? 0.0,
        checkInLongitude: widget.checkInLongitude ?? 0.0,
        checkOutLatitude: _currentLatitude!,
        checkOutLongitude: _currentLongitude!,
        locationName: widget.locationName,
        workDuration: _workDuration,
        checkInImage: widget.capturedImage, // Send check-in image
        checkOutImage: _checkOutImage, // Send check-out image
        checkInCityName: _checkInCityName, // Send check-in city name
        checkOutCityName: _checkOutCityName, // Send check-out city name
        checkOutLocationName: _currentLocationName, // Send check-out address
      );

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        _showSuccessDialog(checkOutTime, result['message']);
      } else {
        String errorMessage = result['message'] ?? 'Unknown error occurred';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog('Failed to submit attendance: $e');
    }
  }

  // Success dialog (Smooth redirect)
  void _showSuccessDialog(DateTime checkOutTime, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Check-Out Successful! You worked for ${_formatDuration(_workDuration)}"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    widget.onCheckOut?.call(checkOutTime);
    _resetCheckedInStatus();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Reset the checked-in status using AttendanceManager
  Future<void> _resetCheckedInStatus() async {
    try {
      final attendanceManager = AttendanceManager();
      attendanceManager.checkOut();
      print('✅ Reset checked-in status using AttendanceManager');
    } catch (e) {
      print('⚠️ Error resetting checked-in status: $e');
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.green[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.green[800]),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Submission Failed",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          content: Text(errorMessage, style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCheckoutPopup();
              },
              child: Text(
                "Retry",
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "Check Out",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // SingleChildScrollView wrapper for scrollable content
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header
                    const SizedBox(height: 10),
                    Text(
                      "Time Clock",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Check-in Image Display
                    if (widget.capturedImage != null) ...[
                      _buildImageSection(
                        "Check-in Photo",
                        widget.capturedImage!,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Check-out Image Display
                    if (_checkOutImage != null) ...[
                      _buildImageSection("Check-out Photo", _checkOutImage!),
                      const SizedBox(height: 20),
                    ],

                    // Location Status
                    LocationDisplayWidget(
                      latitude: _currentLatitude,
                      longitude: _currentLongitude,
                      isLocating: _isGettingLocation,
                      onRefresh: _getCurrentLocation,
                    ),
                    const SizedBox(height: 20),

                    // Time Info Card
                    _buildTimeInfoCard(),

                    const SizedBox(height: 30),

                    // My Day Activity Button
                    _buildActivityButton(),

                    const SizedBox(height: 40),

                    // Check-out Button
                    _buildCheckoutButton(),

                    const SizedBox(height: 20),

                    // Location Label
                    _buildLocationLabel(),

                    // Extra padding at the bottom for better scrolling
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isSubmitting) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String title, File image) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(image, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current Location",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentLocationName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentLatitude != null && _currentLongitude != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lat: ${_currentLatitude!.toStringAsFixed(4)}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    "Lng: ${_currentLongitude!.toStringAsFixed(4)}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: Text(
              _currentTime,
              style: GoogleFonts.robotoMono(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF49C8F4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total work hours today",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              ),
              Text(
                _formatDuration(_workDuration),
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF49C8F4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "My Day Activity",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _showCheckoutPopup,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isSubmitting
                    ? [Colors.grey, Colors.grey[700]!]
                    : [const Color(0xFF2E3A4A), const Color(0xFF3C4A5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 25,
                  spreadRadius: 4,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _isSubmitting
                ? [
              const SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Submitting...",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]
                : [
              const Icon(Icons.touch_app, color: Colors.white, size: 50),
              const SizedBox(height: 6),
              Text(
                "CHECK-OUT",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.grey, size: 18),
        const SizedBox(width: 4),
        Text(
          "Location: $_currentLocationName",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Submitting Attendance...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get city name for check-in location
  Future<void> _getCheckInCityName() async {
    if (widget.checkInLatitude == null || widget.checkInLongitude == null)
      return;

    setState(() {
      _isGettingCheckInCity = true;
    });

    try {
      final cityName = await GeocodingService.getCityFromCoordinates(
        widget.checkInLatitude!,
        widget.checkInLongitude!,
      );

      if (mounted) {
        setState(() {
          _checkInCityName = cityName;
          _isGettingCheckInCity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkInCityName = 'Unknown location';
          _isGettingCheckInCity = false;
        });
      }
    }
  }

  // Get city name for check-out location
  Future<void> _getCheckOutCityName() async {
    if (_currentLatitude == null || _currentLongitude == null) return;

    setState(() {
      _isGettingCheckOutCity = true;
    });

    try {
      final cityName = await GeocodingService.getCityFromCoordinates(
        _currentLatitude!,
        _currentLongitude!,
      );

      if (mounted) {
        setState(() {
          _checkOutCityName = cityName;
          _isGettingCheckOutCity = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkOutCityName = 'Unknown location';
          _isGettingCheckOutCity = false;
        });
      }
    }
  }
}
