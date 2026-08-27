import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'DealerAdministister/dealer_login_screen.dart';
import 'RetailerAdministister/retailer_login_page.dart';
import 'constants/app_colors.dart';
import 'AsmAdministister/asmHomePage.dart';
import 'employePage.dart';
import 'employeehomepage.dart';
import 'model/TodoModel.dart';
import 'service/app_security_service.dart';
import 'service/session_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFingerprintEnabled = false;
  bool _isBiometricAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkFingerprintStatus();
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

  Future<void> _checkFingerprintStatus() async {
    try {
      final enabled = await AppSecurityService.isFingerprintEnabled();
      if (mounted) {
        setState(() {
          _isFingerprintEnabled = enabled;
        });
      }
    } catch (e) {
      debugPrint('Error checking fingerprint status in HomePage: $e');
    }
  }

  Future<void> _loginWithFingerprint() async {
    if (_isBiometricAuthenticating) return;

    setState(() => _isBiometricAuthenticating = true);

    try {
      final result = await AppSecurityService.authenticateWithBiometrics(
        localizedReason: 'Scan fingerprint to log in to Durvasa Ayurved',
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // Validate existing session
        final bool isLoggedIn = await SessionManager.isLoggedIn();
        final TodoModel? sessionData = await SessionManager.getLoginData();

        if (isLoggedIn && sessionData != null) {
          final bool isAsm = sessionData.employeeType?.toLowerCase().contains('asm') == true ||
              sessionData.employeeType?.toLowerCase().contains('ams') == true;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => isAsm
                  ? AsmhomepageHomePage(
                      userData: sessionData,
                      userId: sessionData.empId?.toString() ??
                          sessionData.asmId?.toString() ??
                          '',
                    )
                  : EmployeeHomePage(
                      userData: sessionData,
                      userId: sessionData.empId?.toString() ?? '',
                    ),
            ),
            (route) => false,
          );
        } else {
          // No active session found -> navigate to login screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No active session found. Please select Employee & ASM Portal to sign in with password.',
              ),
              backgroundColor: AppColors.darkGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmployeeLoginPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Biometric login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isBiometricAuthenticating = false);
      }
    }
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

                      // Quick Biometric Unlock (Only when enabled)
                      if (_isFingerprintEnabled) ...[
                        _buildQuickFingerprintCard(),
                        const SizedBox(height: 24),
                      ],

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DealerLoginPage(),
                            ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RetailerLoginScreen(),
                            ),
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
  // QUICK BIOMETRIC UNLOCK CARD
  // ============================================================
  Widget _buildQuickFingerprintCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D4B2E), // Deep Forest Green
            Color(0xFF186842), // Rich Emerald
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isBiometricAuthenticating ? null : _loginWithFingerprint,
          borderRadius: BorderRadius.circular(24),
          splashColor: AppColors.lightGold.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Glowing Fingerprint Avatar
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.16),
                    border: Border.all(
                      color: AppColors.primaryGold,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _isBiometricAuthenticating
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.fingerprint_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Login with Fingerprint',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryGold, width: 0.8),
                            ),
                            child: Text(
                              'FAST',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Touch sensor for quick biometric access',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Icon
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

