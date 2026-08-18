import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'employePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    _animController.dispose();
    super.dispose();
  }

  void _showComingSoonDialog({
    required String title,
    required String description,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.20),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.lightGold, AppColors.primaryGold],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.darkGreen, size: 32),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Helpline: 1800 123 4500',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Got It',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: Stack(
        children: [
          // 1. Ambient Luxury Gradient Orbs (Botanical Emerald & Sacred Gold)
          _buildAmbientGlows(size),

          // 2. Main Scrollable Content with Staggered Fade
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 8 : 16),

                      // 3. Classic Glass Hero Logo & Branding Top Header
                      _buildClassicHeroLogo(),

                      const SizedBox(height: 18),

                      // 4. Welcome Headline & Tagline
                      _buildHeadlineSection(),

                      const SizedBox(height: 24),

                      // 5. Trust / Feature Glass Badges Row
                      _buildTrustBadgesRow(),

                      const SizedBox(height: 28),

                      // 6. Section Divider Header
                      _buildSectionHeader('SELECT ACCESS PORTAL'),

                      const SizedBox(height: 14),

                      // 7. Glassmorphic Interactive Portal Cards
                      _buildGlassPortalCard(
                        title: 'Employee & ASM Portal',
                        subtitle: 'Sign in for sales reporting, attendance, ID badge & order management',
                        icon: Icons.badge_rounded,
                        tagText: 'LIVE ACCESS',
                        tagColor: AppColors.leafGreen,
                        gradientColors: const [
                          Color(0xFF0D4B2E), // Deep Forest Green
                          Color(0xFF1B6B44), // Rich Emerald
                        ],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmployeeLoginPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _buildGlassPortalCard(
                        title: 'Authorized Dealer Portal',
                        subtitle: 'B2B distributor stock dispatch, billing & supply chain management',
                        icon: Icons.storefront_rounded,
                        tagText: 'B2B PARTNER',
                        tagColor: AppColors.primaryGold,
                        gradientColors: const [
                          Color(0xFF144D3D),
                          Color(0xFF26735E),
                        ],
                        onTap: () {
                          _showComingSoonDialog(
                            title: 'Authorized Dealer Portal',
                            description:
                                'The B2B Dealer & Distributor portal is currently undergoing scheduled maintenance. Please contact your regional Area Sales Manager for manual order booking.',
                            icon: Icons.storefront_rounded,
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _buildGlassPortalCard(
                        title: 'Retailer & Pharmacy Store',
                        subtitle: 'Retail partner inventory replenishment & loyalty incentives',
                        icon: Icons.shopping_bag_rounded,
                        tagText: 'RETAIL NETWORK',
                        tagColor: const Color(0xFFE5A93C),
                        gradientColors: const [
                          Color(0xFF234B36),
                          Color(0xFF3B6E52),
                        ],
                        onTap: () {
                          _showComingSoonDialog(
                            title: 'Retailer Network',
                            description:
                                'Retail partner login will be available in the upcoming release. For urgent product restocking, please contact our helpline or your assigned ASM.',
                            icon: Icons.shopping_bag_rounded,
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // 8. Luxury Glass Footer
                      _buildClassicFooter(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 1. AMBIENT GLOW ORBS & BACKGROUND
  // ============================================================
  Widget _buildAmbientGlows(Size size) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Top Right Emerald Orb
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.18),
                    AppColors.primaryGreen.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Top Left Gold Glow
          Positioned(
            top: 60,
            left: -80,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.15),
                    AppColors.primaryGold.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Center Jade Aura
          Positioned(
            top: size.height * 0.42,
            right: -100,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryGreen.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sacred Gold Glow
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lightGold.withValues(alpha: 0.20),
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

  // ============================================================
  // 2. CLASSIC HERO LOGO TOP
  // ============================================================
  Widget _buildClassicHeroLogo() {
    return Column(
      children: [
        // Glassmorphic Pedestal with Gold Rim & App Icon Logo
        Center(
          child: Container(
            height: 110,
            width: 110,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  AppColors.lightGold,
                  AppColors.primaryGold,
                  AppColors.deepGold,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.22),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.92),
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: Image.asset(
                    'assets/appiconwithoutbackground.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.spa_rounded,
                      color: AppColors.primaryGreen,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Brand Name in Royal Typography
        Text(
          'DURVASA',
          style: GoogleFonts.cinzel(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.5,
            color: AppColors.darkGreen,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'AYURVED PVT. LTD.',
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            color: AppColors.deepGold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 3. HEADLINE SECTION
  // ============================================================
  Widget _buildHeadlineSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 16,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Official Enterprise Management Portal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. TRUST BADGES ROW (Glassmorphic Pills)
  // ============================================================
  Widget _buildTrustBadgesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPillBadge(Icons.eco_rounded, '100% Herbal'),
        const SizedBox(width: 8),
        _buildPillBadge(Icons.security_rounded, 'Enterprise Grade'),
        const SizedBox(width: 8),
        _buildPillBadge(Icons.bolt_rounded, 'Instant Sync'),
      ],
    );
  }

  Widget _buildPillBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryGreen),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5. SECTION HEADER
  // ============================================================
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 18,
          width: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGold, AppColors.deepGold],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 6. LUXURY GLASS PORTAL CARD
  // ============================================================
  Widget _buildGlassPortalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String tagText,
    required Color tagColor,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: AppColors.lightGold.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors[0].withValues(alpha: 0.94),
                      gradientColors[1].withValues(alpha: 0.90),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.38),
                    width: 1.3,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Icon badge + Status pill tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glass Icon Box
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withValues(alpha: 0.18),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.30),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.white,
                            size: 26,
                          ),
                        ),

                        // Status Tag Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tagColor.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tagText,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Bottom Enter Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Click to Enter Portal',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightGold,
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 7. CLASSIC FOOTER
  // ============================================================
  Widget _buildClassicFooter() {
    return Column(
      children: [
        // Gold Divider with Center Diamond
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: 50,
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform.rotate(
                angle: 0.785, // 45 deg diamond
                child: Container(
                  height: 6,
                  width: 6,
                  color: AppColors.primaryGold,
                ),
              ),
            ),
            Container(
              height: 1,
              width: 50,
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Text(
          'Durvasa Ayurved Pvt. Ltd.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.darkGreen,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '© 2025 All Rights Reserved • Enterprise Portal v2.0',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

