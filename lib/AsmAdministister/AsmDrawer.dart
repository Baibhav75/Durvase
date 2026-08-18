import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../homepage.dart';
import '../../HomeDrawerpage/attendenceHistory.dart';
import '../../VisitPage/VisitPage.dart';
import '../../Doctorpage/DoctorPagefst.dart';
import '../../PaymentPage/Paymentinpage.dart';
import '../../HomeDrawerpage/FieldAllotted.dart';
import '../../HomeDrawerpage/id_card_screen.dart';
import '../../model/TodoModel.dart';
import '../../model/TodoModel1.dart';
import '../../service/api_serviceProfile.dart';
import '../../service/session_manager.dart';
import 'asm_profile_page.dart';
import 'attendance_history_page.dart';

class AsmDrawer extends StatefulWidget {
  final TodoModel userData;

  const AsmDrawer({
    super.key,
    required this.userData,
  });

  @override
  State<AsmDrawer> createState() => _AsmDrawerState();
}

class _AsmDrawerState extends State<AsmDrawer> {
  TodoModel1? _profileData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final mobile = widget.userData.mobile;

    if (mobile == null || mobile.isEmpty) return;

    final isCached = ApiService.isProfileCached(mobile);

    if (!isCached && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final profile = await ApiService.fetchProfile(mobile);

      if (!mounted) return;

      setState(() {
        _profileData = profile;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Drawer profile error: $e');

      if (!mounted) return;

      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _goTo(Widget page) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _closeDrawer() {
    Navigator.pop(context);
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String feature) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Coming Soon!',
          style: GoogleFonts.poppins(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await SessionManager.logout();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(
        Icons.circle,
        color: Colors.transparent,
        size: 0,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      horizontalTitleGap: 8,
      title: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGold,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _profileHeader() {
    final employee = _profileData?.data1?.first;

    final name = employee?.name ?? widget.userData.name ?? 'Manager';
    final email = employee?.email ?? widget.userData.email ?? 'manager@durvasaayurved.com';
    final employeeType = employee?.employeeType ?? widget.userData.employeeType ?? 'ASM Administrator';
    final image = employee?.image;

    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGreen,
            AppColors.primaryGreen,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _profileImage(image),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.cream.withOpacity(.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeeType,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _idCardHeaderButton(),
              const SizedBox(width: 8),
              _profileButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileImage(String? image) {
    return Container(
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
        backgroundImage: image != null && image.isNotEmpty
            ? NetworkImage(image)
            : const AssetImage(
                'assets/durvasa_logo.png',
              ) as ImageProvider,
        child: image == null || image.isEmpty
            ? const Icon(
                Icons.person,
                color: AppColors.primaryGreen,
                size: 30,
              )
            : null,
      ),
    );
  }

  Widget _idCardHeaderButton() {
    return OutlinedButton.icon(
      onPressed: () {
        _goTo(
          IdCardScreen(
            userData: widget.userData,
          ),
        );
      },
      icon: const Icon(
        Icons.badge_outlined,
        color: AppColors.lightGold,
        size: 14,
      ),
      label: Text(
        'ID Card',
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.lightGold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _profileButton() {
    return ElevatedButton(
      onPressed: () {
        _goTo(
          AsmProfilePage(
            userData: widget.userData,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryGreen,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.primaryGold,
          ),
        ),
      ),
      child: Text(
        'View Profile',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.primaryGreen,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _isLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGold,
                        ),
                      ),
                    ),
                  )
                : _profileHeader(),

            const SizedBox(height: 10),

            // Dashboard
            _drawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: _closeDrawer,
            ),

            // Employee / ASM ID Card
            _drawerItem(
              icon: Icons.badge_outlined,
              title: 'ASM Identity Card',
              onTap: () => _goTo(
                IdCardScreen(
                  userData: widget.userData,
                ),
              ),
            ),

            // Field Allotted
            _drawerItem(
              icon: Icons.assignment,
              title: 'Field Allotted',
              onTap: () => _goTo(
                FieldAllotted(
                  employeeId: widget.userData.empId ?? widget.userData.asmId ?? '',
                ),
              ),
            ),

            // Attendance
            _drawerItem(
              icon: Icons.history,
              title: 'Attendance History',
              onTap: () => _goTo(
                AsmAttendanceHistoryPage(
                  userData: widget.userData,
                ),
              ),
            ),

            // Doctor Visits
            _drawerItem(
              icon: Icons.medical_services,
              title: 'Doctor Visits',
              onTap: () => _goTo(
                DoctorPagefst(),
              ),
            ),

            // Business Visit
            _drawerItem(
              icon: Icons.business,
              title: 'Business Visit',
              onTap: () => _goTo(
                const Visitpage(),
              ),
            ),

            // Total Visits
            _drawerItem(
              icon: Icons.analytics,
              title: 'Total Visits',
              onTap: () => _goTo(
                const Visitpage(),
              ),
            ),

            // Total Collection
            _drawerItem(
              icon: Icons.attach_money,
              title: 'Total Collection',
              onTap: () => _goTo(
                const PaymentPageFst(),
              ),
            ),

            Divider(
              color: AppColors.white.withOpacity(.2),
            ),

            // Settings
            _drawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _showComingSoon('Settings'),
            ),

            // Logout
            _drawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }
}