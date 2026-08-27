import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel.dart';
import '../service/asm_profile_service.dart';
import '../service/session_manager.dart';
import '../widgets/gemini_widget.dart';
import '/Attendancepage/attendance_page.dart';
import '/Doctorpage/DoctorPagefst.dart';
import '/OrderPage/orderPagefist.dart';
import '/PaymentPage/Paymentinpage.dart';
import '/Taskpage/activeTask.dart';
import '/VisitPage/visitSelectType.dart';
import '/model/TodoModel1.dart';
import 'AsmDrawer.dart';
import 'asm_business_page.dart';
import 'your_team.dart';

class AsmhomepageHomePage extends StatefulWidget {
  final TodoModel userData;
  final String userId;

  const AsmhomepageHomePage({super.key, required this.userData, required this.userId});

  @override
  State<AsmhomepageHomePage> createState() => _AsmhomepageHomePageState();
}

class _AsmhomepageHomePageState extends State<AsmhomepageHomePage> {
  String _effectiveEmpId = '';

  @override
  void initState() {
    super.initState();
    _effectiveEmpId = widget.userData.empId ?? widget.userId;
    _initAndSyncAsmProfile();
  }

  Future<void> _initAndSyncAsmProfile() async {
    // 1. First retrieve stored Employee ID directly from SessionManager (database)
    final storedEmpId = await SessionManager.getEmpId();
    if (storedEmpId != null && storedEmpId.isNotEmpty && mounted) {
      setState(() {
        _effectiveEmpId = storedEmpId;
        widget.userData.empId = storedEmpId;
      });
    }

    // 2. Fetch fresh ASM Profile from API and sync with database
    final rawId = widget.userData.asmId ?? widget.userData.empId ?? widget.userId;
    final int resolvedAsmId = int.tryParse(rawId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

    try {
      final profile = await AsmProfileService.getAsmProfile(resolvedAsmId);
      await SessionManager.saveAsmProfile(profile);

      final freshEmpId = profile.empId ?? profile.uniqueId ?? profile.employeeCode;
      if (freshEmpId != null && freshEmpId.isNotEmpty && mounted) {
        setState(() {
          _effectiveEmpId = freshEmpId;
          widget.userData.empId = freshEmpId;
          if (profile.name != null && profile.name!.isNotEmpty) {
            widget.userData.name = profile.name;
          }
          if (profile.mobile != null && profile.mobile!.isNotEmpty) {
            widget.userData.mobile = profile.mobile;
          }
        });
      }
    } catch (e) {
      debugPrint('Error syncing ASM profile in asmHomePage: $e');
    }
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: AppColors.cream,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String title, BuildContext context) {
    return _AsmAnimatedDashboardCard(
      icon: icon,
      title: title,
      onTap: () {
        final currentId = _effectiveEmpId.isNotEmpty ? _effectiveEmpId : (widget.userData.empId ?? widget.userId);

        switch (title) {
          case "Attendance":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendancePage(
                  userData: widget.userData..empId = currentId,
                ),
              ),
            );
            break;
          case "Task":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskScreen()),
            );
            break;
          case "Visit":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VisitTypeScreen(
                  employeeData: Data1(
                    name: widget.userData.name,
                    employeeType: widget.userData.employeeType,
                    mobile: widget.userData.mobile,
                    employeeId: currentId,
                    empId: currentId,
                  ),
                ),
              ),
            );
            break;
          case "Order":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPageFst(userId: currentId)),
            );
            break;
          case "Payment In":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentPageFst()),
            );
            break;
          case "Doctor":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorReportPage()),
            );
            break;
          case "Business":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BusinessPage()),
            );
            break;
          case "AI Assistant":
            DurvasaAiAssistantSheet.show(context);
            break;
          case "Your Team":
          case "Your TeamR":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YourTeamPage(
                  userData: widget.userData..empId = currentId,
                ),
              ),
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          "Welcome, ${widget.userData.name ?? 'Manager'}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      drawer: AsmDrawer(userData: widget.userData),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.deepGold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withValues(alpha: 0.15),
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.white, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AMS Management Portal",
                                style: GoogleFonts.poppins(
                                  color: AppColors.cream,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.userData.name ?? 'ASM Administrator',
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.userData.employeeType ?? 'Area Sales Manager',
                                style: GoogleFonts.poppins(
                                  color: AppColors.cream.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip('ID: ${_effectiveEmpId.isNotEmpty ? _effectiveEmpId : (widget.userData.empId ?? 'N/A')}'),
                        _buildInfoChip('Mobile: ${widget.userData.mobile ?? 'N/A'}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _buildDashboardCard(Icons.fingerprint, "Attendance", context),
                  _buildDashboardCard(Icons.check_circle_outline, "Task", context),
                  _buildDashboardCard(Icons.location_on, "Visit", context),
                  _buildDashboardCard(Icons.shopping_cart, "Order", context),
                  _buildDashboardCard(Icons.account_balance_wallet, "Payment In", context),
                  _buildDashboardCard(Icons.medical_information, "Doctor", context),
                  _buildDashboardCard(Icons.auto_awesome_rounded, "AI Assistant", context),
                  _buildDashboardCard(Icons.groups, "Your Team", context),
                  _buildDashboardCard(Icons.business_center, "Business", context),
                ],
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),

      // ==========================================
      // AI CHAT FLOATING ACTION BUTTON
      // ==========================================
      floatingActionButton: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(
                alpha: 0.25,
              ),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => DurvasaAiAssistantSheet.show(context),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Lottie.asset(
                'assets/Ai chat.json',
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryGreen,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _AsmAnimatedDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AsmAnimatedDashboardCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AsmAnimatedDashboardCard> createState() => _AsmAnimatedDashboardCardState();
}

class _AsmAnimatedDashboardCardState extends State<_AsmAnimatedDashboardCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            gradient: _isPressed
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withValues(alpha: 0.12),
                      AppColors.primaryGold.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isPressed ? AppColors.primaryGold : AppColors.lightGold.withValues(alpha: 0.4),
              width: _isPressed ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primaryGreen.withValues(alpha: 0.22)
                    : AppColors.primaryGreen.withValues(alpha: 0.08),
                blurRadius: _isPressed ? 16 : 12,
                spreadRadius: _isPressed ? 1 : 0,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isPressed
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    boxShadow: _isPressed
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isPressed ? AppColors.primaryGold : AppColors.primaryGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: _isPressed ? FontWeight.w700 : FontWeight.w600,
                    color: _isPressed ? AppColors.primaryGreen : AppColors.textDark,
                  ),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
