import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'Attendancepage/attendance_page.dart';
import 'Doctorpage/DoctorPagefst.dart';
import 'OrderPage/orderPagefist.dart';
import 'PaymentPage/Paymentinpage.dart';
import 'Taskpage/activeTask.dart';
import 'VisitPage/visitSelectType.dart';
import 'model/TodoModel.dart';
import 'model/TodoModel1.dart';
import 'service/api_serviceProfile.dart';
import 'viewHome/widgets/home_drawer.dart';

class EmployeeHomePage extends StatefulWidget {
  final TodoModel userData;
  final String userId;

  const EmployeeHomePage({super.key, required this.userData, required this.userId});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  @override
  void initState() {
    super.initState();
    _preloadProfileData();
  }

  void _preloadProfileData() {
    if (widget.userData.mobile != null) {
      ApiService.fetchProfile(widget.userData.mobile!).catchError((_) {});
    }
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
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
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.lightGold.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.08),
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
                  color: AppColors.primaryGreen.withOpacity(0.08),
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
          "Welcome, ${widget.userData.name ?? 'Employee'}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      drawer: HomeDrawer(userData: widget.userData),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
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
                            color: AppColors.white.withOpacity(0.12),
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.person, color: AppColors.white, size: 28),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back!",
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.userData.name ?? 'Employee',
                                style: GoogleFonts.poppins(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                widget.userData.employeeType ?? 'Staff Member',
                                style: GoogleFonts.poppins(
                                  color: AppColors.cream.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.white.withOpacity(0.2)),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
