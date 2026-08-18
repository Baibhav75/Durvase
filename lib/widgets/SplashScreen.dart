import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../AsmAdministister/asmHomePage.dart';
import '../employeehomePage.dart';
import '../homepage.dart';
import '../service/app_security_service.dart';
import 'app_unlock_screen.dart';
import '/model/TodoModel.dart';
import '/service/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  // Staggered Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideTextAnimation;
  late Animation<double> _fadeTextAnimation;
  late Animation<double> _fadeTaglineAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLoginStatus();
  }

  void _initAnimations() {
    // Main entrance controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Continuous soft pulse controller for golden glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Subtle continuous rotation for ornamental accent ring
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // Scale animation with smooth spring curve
    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Logo fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // Title slide animation
    _slideTextAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Title fade animation
    _fadeTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    // Tagline fade animation
    _fadeTaglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Pulse animation (breathing effect)
    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Rotation animation
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.linear,
      ),
    );

    _mainController.forward();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Run splash minimum delay concurrently with session loading (2.8s for smooth animation)
      final splashDelay = Future.delayed(const Duration(milliseconds: 2800));

      final bool loggedIn = await SessionManager.isLoggedIn();
      TodoModel? userData;

      if (loggedIn) {
        userData = await SessionManager.getLoginData();
      }

      await splashDelay;

      if (!mounted) return;

      if (loggedIn && userData != null) {
        final bool isAsm = userData.employeeType?.toLowerCase().contains('asm') == true ||
            userData.employeeType?.toLowerCase().contains('ams') == true;

        final bool securityEnabled = await AppSecurityService.isSecurityEnabled();

        if (securityEnabled) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (context, animation, secondaryAnimation) => AppUnlockScreen(
                userData: userData!,
                userId: userData.empId?.toString() ?? '',
                isAsm: isAsm,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder: (context, animation, secondaryAnimation) => isAsm
                  ? AsmhomepageHomePage(
                      userData: userData!,
                      userId: userData.empId?.toString() ?? '',
                    )
                  : EmployeeHomePage(
                      userData: userData!,
                      userId: userData.empId?.toString() ?? '',
                    ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error in splash screen: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Luxury Ayurvedic Emerald & Deep Forest Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.0, -0.15),
                radius: 1.2,
                colors: [
                  AppColors.primaryGreen, // Rich Ayurvedic Primary Green
                  AppColors.darkGreen,    // Dark Deep Green
                  Color(0xFF03140A),      // Obsidian Green
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // 2. Subtle Golden Glow Ambient Halo behind the Logo
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: size.height * 0.28,
                left: (size.width - 280) / 2,
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.22), // Golden glow
                          blurRadius: 70,
                          spreadRadius: 25,
                        ),
                        BoxShadow(
                          color: AppColors.secondaryGreen.withOpacity(0.35), // Emerald radiance
                          blurRadius: 90,
                          spreadRadius: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Subtle Animated Golden Orbit Ring
          Positioned(
            top: size.height * 0.28,
            left: (size.width - 250) / 2,
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.20),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 120,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.lightGold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 110,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold,
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Center Content (Logo + Brand + Tagline)
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Animated App Icon Badge matching playstore.png
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 175,
                        height: 175,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.lightGold,   // Light Gold highlight
                              AppColors.primaryGold, // Primary Gold
                              AppColors.deepGold,    // Deep Gold shadow
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withOpacity(0.40),
                              blurRadius: 28,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.55),
                              blurRadius: 20,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4.5), // Golden border thickness
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/playstore.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/appiconwithoutbackground.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/durvasa_logo.png',
                                      fit: BoxFit.contain,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animated Brand Typography & Tagline
                  SlideTransition(
                    position: _slideTextAnimation,
                    child: FadeTransition(
                      opacity: _fadeTextAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "DURVASA" with Metallic Gold Shader
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.cream,
                                AppColors.lightGold,
                                AppColors.primaryGold,
                                AppColors.deepGold,
                                AppColors.lightGold,
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ).createShader(bounds),
                            child: const Text(
                              'DURVASA',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6.0,
                                color: AppColors.white,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Golden Wings Ornament + "AYURVED"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primaryGold,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'AYURVED',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4.5,
                                  color: AppColors.lightGold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 36,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primaryGold,
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline with smooth fade
                  FadeTransition(
                    opacity: _fadeTaglineAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Authentic Ayurvedic Excellence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Elegant Animated Loading Indicator & Footer
                  FadeTransition(
                    opacity: _fadeTaglineAnimation,
                    child: Column(
                      children: [
                        _buildAnimatedDots(),
                        const SizedBox(height: 16),
                        Text(
                          'Pure • Nature • Healing',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                            color: AppColors.primaryGold.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Three soft pulsing Ayurvedic gold dots
  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final double delayOffset = index * 0.2;
            final double animVal = ((_pulseController.value + delayOffset) % 1.0);
            final double dotScale = 0.7 + (animVal * 0.5);
            final double dotOpacity = 0.3 + (animVal * 0.7);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: dotScale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGold.withOpacity(dotOpacity.clamp(0.0, 1.0)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.5 * dotOpacity),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
