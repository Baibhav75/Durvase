import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../HomeDrawerpage/attendenceHistory.dart';
import '../../VisitPage/VisitPage.dart';
import '../../Doctorpage/DoctorPagefst.dart';
import '../../OrderPage/orderPagefist.dart';
import '../../PaymentPage/Paymentinpage.dart';
import '../../HomeDrawerpage/FieldAllotted.dart';
import '../../model/TodoModel.dart';
import '../../model/TodoModel1.dart';
import '../../service/api_serviceProfile.dart';
import '../../service/session_manager.dart';
import 'profile_screen.dart';

class HomeDrawer extends StatefulWidget {
  final TodoModel userData;

  const HomeDrawer({super.key, required this.userData});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  TodoModel1? _profileData;
  bool _isDrawerProfileLoading = false;
  String? _drawerProfileErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDrawerProfileData();
  }

  Future<void> _fetchDrawerProfileData() async {
    if (widget.userData.mobile == null) {
      if (mounted) {
        setState(() {
          _drawerProfileErrorMessage = 'Mobile number not available';
        });
      }
      return;
    }

    final mobile = widget.userData.mobile!;
    if (ApiService.isProfileCached(mobile)) {
      final cachedData = await ApiService.fetchProfile(mobile);
      if (mounted) {
        setState(() {
          _profileData = cachedData;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isDrawerProfileLoading = true;
        _drawerProfileErrorMessage = null;
      });
    }

    try {
      final profileData = await ApiService.fetchProfile(mobile);
      if (mounted) {
        setState(() {
          _profileData = profileData;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _drawerProfileErrorMessage = 'Failed to load profile data';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDrawerProfileLoading = false;
        });
      }
    }
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName - Coming Soon!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    await SessionManager.logout();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout();
            },
            child: Text(
              "Logout",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildDrawerProfileHeader() {
    final employeeData = _profileData?.data1?.first;

    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.deepPurple),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: employeeData?.image != null
                    ? NetworkImage(employeeData!.image!)
                    : const AssetImage('assets/durvasa_logo.png')
                        as ImageProvider,
                child: employeeData?.image == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.deepPurple,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeData?.name ?? widget.userData.name ?? 'Employee',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employeeData?.email ??
                          widget.userData.email ??
                          'employee@email.com',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employeeData?.employeeType ??
                          widget.userData.employeeType ??
                          'Employee Type',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userData: widget.userData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'View Profile',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.deepPurple,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _isDrawerProfileLoading
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : _buildDrawerProfileHeader(),
            if (_profileData != null &&
                _profileData!.data1 != null &&
                _profileData!.data1!.isNotEmpty)
              Container(
                color: Colors.deepPurple[700],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              )
            else if (_drawerProfileErrorMessage != null)
              Container(), // empty fallback

            const SizedBox(height: 10),
            _buildDrawerItem(Icons.dashboard, "Dashboard", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.assignment, "Field Allotted", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FieldAllotted(
                    employeeId: widget.userData.empId ?? 'EMP785291',
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.history, "Attendance History", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceHistoryPage(userData: widget.userData),
                ),
              );
            }),
            _buildDrawerItem(Icons.medical_services, "Doctor Visits", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoctorPagefst()),
              );
            }),
            _buildDrawerItem(Icons.business, "Business Visit", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Visitpage()),
              );
            }),
            _buildDrawerItem(Icons.analytics, "Total Visits", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Visitpage()),
              );
            }),
            _buildDrawerItem(Icons.attach_money, "Total Collection", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentPageFst()),
              );
            }),
            const Divider(color: Colors.white70),
            _buildDrawerItem(Icons.settings, "Settings", () {
              Navigator.pop(context);
              _showComingSoon(context, "Settings");
            }),
            _buildDrawerItem(Icons.exit_to_app, "Logout", () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            }),
          ],
        ),
      ),
    );
  }
}
