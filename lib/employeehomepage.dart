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
import 'showcase_screen.dart';
import 'viewHome/widgets/home_drawer.dart';
import 'viewHome/widgets/mr_work_report_page.dart';
import 'viewHome/widgets/mr_work_report_history_page.dart';

class EmployeeHomePage extends StatefulWidget {
  final TodoModel userData;
  final String userId;

  const EmployeeHomePage({super.key, required this.userData, required this.userId});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  late Animation<double> _ambientAnimation;

  @override
  void initState() {
    super.initState();
    _preloadProfileData();

    // Smooth continuous floating ambient background animation
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _ambientAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  void _preloadProfileData() {
    if (widget.userData.mobile != null) {
      ApiService.fetchProfile(widget.userData.mobile!).catchError((_) => null);
    }
  }

  void _showWorkReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'MR Work Report',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
              ),
              tileColor: AppColors.creamBackground,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_task_rounded, color: AppColors.primaryGreen),
              ),
              title: Text(
                'Submit Daily Report',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              ),
              subtitle: Text(
                'Fill and submit today\'s field visit report',
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryGreen),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MrWorkReportPage(userData: widget.userData),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
              ),
              tileColor: AppColors.creamBackground,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_edu_rounded, color: AppColors.deepGold),
              ),
              title: Text(
                'Work Report History',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark),
              ),
              subtitle: Text(
                'View previous submitted reports and stats',
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryGreen),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MRWorkReportHistoryPage(userData: widget.userData),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
              MaterialPageRoute(builder: (context) => DoctorReportPage()),
            );
            break;
          case "Work Report":
            _showWorkReportOptions(context);
            break;
          case "Showcase":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShowcaseScreen()),
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
                child: Icon(icon, color: AppColors.primaryGreen, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated Ambient Glow Orbs
  Widget _buildAmbientGlows(Size size) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ambientAnimation,
        builder: (context, child) {
          final val = _ambientAnimation.value;
          return Stack(
            children: [
              Positioned(
                top: -60 + (25 * val),
                right: -60 + (20 * (1 - val)),
                child: Container(
                  height: 240 + (20 * val),
                  width: 240 + (20 * val),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.16 + (0.04 * val)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 200 + (30 * (1 - val)),
                left: -70 + (25 * val),
                child: Container(
                  height: 220 + (20 * (1 - val)),
                  width: 220 + (20 * (1 - val)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryGold.withOpacity(0.14 + (0.04 * val)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50 + (20 * val),
                right: -50 + (20 * val),
                child: Container(
                  height: 230 + (20 * val),
                  width: 230 + (20 * val),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.lightGold.withOpacity(0.18 + (0.05 * val)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          "Welcome, ${widget.userData.name ?? 'Employee'}",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_iphone_rounded, color: AppColors.lightGold),
            tooltip: 'App Showcase',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShowcaseScreen()),
              );
            },
          ),
        ],
      ),
      drawer: HomeDrawer(userData: widget.userData),
      body: Stack(
        children: [
          // 1. Subtle Botanical Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/appiconwithoutbackground.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

          // 2. Dual-Tone Gradient Veil
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.creamBackground.withOpacity(0.92),
                    AppColors.creamBackground.withOpacity(0.85),
                    const Color(0xFFF6F1E3).withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // 3. Animated Ambient Glowing Orbs
          _buildAmbientGlows(size),

          // 4. Main Scrollable Dashboard Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Employee Gradient Card
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
                const SizedBox(height: 20),

                // Dashboard Action Cards Grid
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
                    _buildDashboardCard(Icons.assignment_turned_in_rounded, "Work Report", context),
                    _buildDashboardCard(Icons.phone_iphone_rounded, "Showcase", context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
