// lib/showcase_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mobile App Showcase',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Ambient Background Orbs
          _buildAmbientOrbs(size),

          // 2. Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: isDesktop ? _buildSideBySideLayout() : _buildPageViewLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ambient Orbs
  Widget _buildAmbientOrbs(Size size) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: size.width * 0.1,
            child: Container(
              height: 380,
              width: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD7E3F8).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: size.width * 0.1,
            child: Container(
              height: 420,
              width: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF6E8DC).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Side by side for large screens
  Widget _buildSideBySideLayout() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDeviceFrame(isScreen1: true),
            const SizedBox(width: 60),
            _buildDeviceFrame(isScreen1: false),
          ],
        ),
      ),
    );
  }

  // PageView for mobile screens
  Widget _buildPageViewLayout() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              Center(child: _buildDeviceFrame(isScreen1: true)),
              Center(child: _buildDeviceFrame(isScreen1: false)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            const SizedBox(width: 8),
            _buildDot(1),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Reusable iOS Device Frame
  Widget _buildDeviceFrame({required bool isScreen1}) {
    return Container(
      width: 320,
      height: 680,
      decoration: BoxDecoration(
        color: isScreen1 ? const Color(0xFFF2F2F7) : Colors.black,
        borderRadius: BorderRadius.circular(44),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Screen Content
            Positioned.fill(
              child: isScreen1 ? _buildScreen1Content() : _buildScreen2Content(),
            ),

            // Dynamic Island
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 105,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            // Status Bar
            Positioned(
              top: 8,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '11:11',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.signal_cellular_alt_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full_rounded, size: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // Home Indicator Bar
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 110,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SCREEN 1: "The place for all your places"
  // ------------------------------------------------------------
  Widget _buildScreen1Content() {
    return Container(
      color: const Color(0xFF02040C),
      child: Stack(
        children: [
          // Background Gradient / Ambient Layer
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08132B),
                    Color(0xFF02040C),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Fade Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF02040C).withOpacity(0.7),
                    const Color(0xFF02040C),
                  ],
                ),
              ),
            ),
          ),

          // Main Layout Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Brand Logo
                Image.asset(
                  'assets/appiconwithoutbackground.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.spa_rounded,
                    color: AppColors.lightGold,
                    size: 60,
                  ),
                ),

                const Spacer(),

                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    children: [
                      const TextSpan(text: 'The place for all\n'),
                      TextSpan(
                        text: 'your places',
                        style: GoogleFonts.playfairDisplay(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFE8B2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Save, Organize and Share\nyour favorite places',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Continue with Apple Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.apple_rounded, color: Color(0xFF1A1A1A), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Continue with Apple',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Terms of Use
                Text(
                  'By continuing, you agree to Terms of Use',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SCREEN 2: "Unlock Pro"
  // ------------------------------------------------------------
  Widget _buildScreen2Content() {
    return Container(
      color: const Color(0xFF14151D),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),

          // Top Header
          Text(
            'Unlock Pro:',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Divider
          Container(
            height: 1,
            width: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 5 Feature Rows
          _buildFeatureRow(Icons.layers_outlined, 'Create private Guides'),
          _buildFeatureRow(Icons.phone_iphone_rounded, 'Import from social media'),
          _buildFeatureRow(Icons.all_inclusive_rounded, 'Unlimited Guides'),
          _buildFeatureRow(Icons.auto_awesome_outlined, 'AI search'),
          _buildFeatureRow(Icons.people_outline_rounded, 'Collaborate with friends'),

          const Spacer(),

          // Pricing Cards (Monthly vs Yearly)
          Row(
            children: [
              // Monthly Card
              Expanded(
                child: Container(
                  height: 96,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26735E), Color(0xFF144D3D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monthly', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white)),
                          Text('\$20', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                      Text('Billed Monthly', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Yearly Card
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 96,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E212A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Yearly', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white54)),
                              Text('\$200', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white60)),
                            ],
                          ),
                          Text('Billed Yearly', style: GoogleFonts.inter(fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4D5057),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Save \$40',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Subscribe Button
          Container(
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Subscribe',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C0C0E),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF0C0C0E)),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
