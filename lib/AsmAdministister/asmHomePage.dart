import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel.dart';
import '/Attendancepage/attendance_page.dart';
import '/Doctorpage/DoctorPagefst.dart';
import '/OrderPage/orderPagefist.dart';
import '/PaymentPage/Paymentinpage.dart';
import '/Taskpage/activeTask.dart';
import '/VisitPage/visitSelectType.dart';
import '/model/TodoModel1.dart';
import '/service/api_serviceProfile.dart';
import 'AsmDrawer.dart';
import 'your_team.dart';

class AsmhomepageHomePage extends StatefulWidget {
  final TodoModel userData;
  final String userId;

  const AsmhomepageHomePage({super.key, required this.userData, required this.userId});

  @override
  State<AsmhomepageHomePage> createState() => _AsmhomepageHomePageState();
}

class _AsmhomepageHomePageState extends State<AsmhomepageHomePage> {
  @override
  void initState() {
    super.initState();
    _preloadProfileData();
  }

  void _preloadProfileData() {
    if (widget.userData.mobile != null) {
      ApiService.fetchProfile(widget.userData.mobile!).catchError((_) => TodoModel1());
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
    return GestureDetector(
      onTap: () {
        switch (title) {
          case "Attendance":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendancePage(userData: widget.userData),
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
                    employeeId: widget.userData.empId,
                  ),
                ),
              ),
            );
            break;
          case "Order":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPageFst(userId: widget.userId)),
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
              MaterialPageRoute(builder: (context) => DoctorPagefst()),
            );
            break;
          case "Business":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskScreen()),
            );
            break;
          case "Your Team":
          case "Your TeamR":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => YourTeamPage(userData: widget.userData),
              ),
            );
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.lightGold.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
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
                        _buildInfoChip('ID: ${widget.userData.empId ?? 'N/A'}'),
                        _buildInfoChip('Mobile: ${widget.userData.mobile ?? 'N/A'}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
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
                  _buildDashboardCard(Icons.groups, "Your Team", context),
                  _buildDashboardCard(Icons.business_center, "Business", context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
