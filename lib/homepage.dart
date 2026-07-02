import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'employePage.dart';
import 'debug_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildStakeholderCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          highlightColor: Colors.white.withOpacity(0.1),
          splashColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Header Text
                        Text(
                          "Welcome to",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Durvasa Portal",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: const Color(0xFF333333),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 30),

                        // Animated Logo
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Image.asset(
                              'assets/durvasa_logo.png',
                              height: height * 0.22,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select Login Type",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stakeholder Cards
                        _buildStakeholderCard(
                          context: context,
                          title: "Employee",
                          subtitle: "Access internal dashboard",
                          icon: Icons.badge_outlined,
                          gradientColors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmployeeLoginPage(),
                              ),
                            );
                          },
                        ),

                        _buildStakeholderCard(
                          context: context,
                          title: "Dealer",
                          subtitle: "Manage your dealership",
                          icon: Icons.storefront_outlined,
                          gradientColors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                          onTap: () {},
                        ),

                        _buildStakeholderCard(
                          context: context,
                          title: "Retailer",
                          subtitle: "Retail partner portal",
                          icon: Icons.shopping_cart_outlined,
                          gradientColors: [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
                          onTap: () {},
                        ),

                        // Debug button
                        if (!const bool.fromEnvironment('dart.vm.product'))
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DebugPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bug_report, color: Colors.orange),
                              label: Text(
                                "Debug Session",
                                style: GoogleFonts.poppins(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),

                        const Spacer(),
                        const SizedBox(height: 40),

                        // Footer
                        Text(
                          "Durvasa Ayurved Pvt. Ltd.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "© 2025 All Rights Reserved",
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
