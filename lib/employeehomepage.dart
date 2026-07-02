import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  const EmployeeHomePage({super.key, required this.userData});

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
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
              MaterialPageRoute(builder: (context) =>  TaskScreen()),
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
              MaterialPageRoute(builder: (context) =>  OrderPageFst()),
            );
            break;
          case "Payment In":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  PaymentPageFst()),
            );
            break;
          case "Doctor":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  DoctorPagefst()),
            );
            break;
        }
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.deepPurple, size: 38),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Welcome, ${widget.userData.name ?? 'Employee'}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                    colors: [Colors.deepPurple, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back!",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.userData.name ?? 'Employee',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.userData.employeeType ?? 'Employee Type',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white70),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip('ID: ${widget.userData.empId ?? 'N/A'}'),
                        _buildInfoChip(
                          'Mobile: ${widget.userData.mobile ?? 'N/A'}',
                        ),
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
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.50,
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
