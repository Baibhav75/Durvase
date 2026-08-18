import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../homepage.dart';
import '../../HomeDrawerpage/attendenceHistory.dart';
import '../../VisitPage/VisitPage.dart';
import '../../Doctorpage/DoctorPagefst.dart';
import '../../OrderPage/orderPagefist.dart';
import '../../PaymentPage/Paymentinpage.dart';
import '../../HomeDrawerpage/FieldAllotted.dart';
import '../../HomeDrawerpage/id_card_screen.dart';
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
          style: GoogleFonts.poppins(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await SessionManager.logout();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Logout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.poppins(color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
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
                color: AppColors.error,
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
      leading: Icon(icon, color: AppColors.primaryGold),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerProfileHeader() {
    final employeeData = _profileData?.data1?.first;

    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.white,
                  backgroundImage: employeeData?.image != null
                      ? NetworkImage(employeeData!.image!)
                      : const AssetImage('assets/durvasa_logo.png') as ImageProvider,
                  child: employeeData?.image == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primaryGreen,
                          size: 30,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeData?.name ?? widget.userData.name ?? 'Employee',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeeData?.email ?? widget.userData.email ?? 'employee@email.com',
                      style: GoogleFonts.poppins(
                        color: AppColors.cream.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeeData?.employeeType ?? widget.userData.employeeType ?? 'Staff Member',
                      style: GoogleFonts.poppins(
                        color: AppColors.lightGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryGold, width: 1),
                ),
                elevation: 2,
              ),
              child: Text(
                'View Profile',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
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
        color: AppColors.primaryGreen,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _isDrawerProfileLoading
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  )
                : _buildDrawerProfileHeader(),
            if (_profileData != null &&
                _profileData!.data1 != null &&
                _profileData!.data1!.isNotEmpty)
              Container(
                color: AppColors.darkGreen,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              )
            else if (_drawerProfileErrorMessage != null)
              Container(),

            const SizedBox(height: 10),
            _buildDrawerItem(Icons.dashboard, "Dashboard", () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.badge, "Employee ID Card", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IdCardScreen(userData: widget.userData),
                ),
              );
            }),
            _buildDrawerItem(Icons.assignment, "Field Allotted", () {
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
            Divider(color: AppColors.white.withOpacity(0.2)),
            _buildDrawerItem(Icons.settings, "Settings", () {
              Navigator.pop(context);
              _showComingSoon(context, "Settings");
            }),
            _buildDrawerItem(
              Icons.exit_to_app,
              "Logout",
              () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
