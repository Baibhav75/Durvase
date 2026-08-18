import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../AsmAdministister/asmHomePage.dart';
import '../constants/app_colors.dart';
import '../employeehomepage.dart';
import '../homepage.dart';
import '../model/TodoModel.dart';
import '../service/app_security_service.dart';

class AppUnlockScreen extends StatefulWidget {
  final TodoModel userData;
  final String userId;
  final bool isAsm;

  const AppUnlockScreen({
    super.key,
    required this.userData,
    required this.userId,
    required this.isAsm,
  });

  @override
  State<AppUnlockScreen> createState() => _AppUnlockScreenState();
}

class _AppUnlockScreenState extends State<AppUnlockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _isFingerprintEnabled = false;
  bool _isPasswordEnabled = false;
  bool _isBiometricSupported = false;
  bool _isBiometricEnrolled = false;

  bool _showPasswordView = false;
  bool _isAuthenticating = false;
  bool _obscurePassword = true;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initSecurityState();
  }

  Future<void> _initSecurityState() async {
    _isFingerprintEnabled = await AppSecurityService.isFingerprintEnabled();
    _isPasswordEnabled = await AppSecurityService.isAppPasswordEnabled();
    _isBiometricSupported = await AppSecurityService.isBiometricSupported();
    _isBiometricEnrolled = await AppSecurityService.isBiometricEnrolled();

    // If fingerprint is enabled and device supports it with enrolled biometric,
    // default to fingerprint mode and automatically prompt
    if (_isFingerprintEnabled && _isBiometricSupported && _isBiometricEnrolled) {
      setState(() {
        _showPasswordView = false;
      });
      // Small delay to allow UI to mount before launching system dialog
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _authenticateWithFingerprint();
        }
      });
    } else {
      // Fallback directly to password view
      setState(() {
        _showPasswordView = true;
        if (_isFingerprintEnabled && (!_isBiometricSupported || !_isBiometricEnrolled)) {
          _statusMessage =
              "Fingerprint authentication is unavailable on this device. Please use your App Password.";
          _isError = true;
        } else if (_isPasswordEnabled) {
          _statusMessage = null;
        }
      });
    }
  }

  Future<void> _authenticateWithFingerprint() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = null;
      _isError = false;
    });

    final result = await AppSecurityService.authenticateWithBiometrics(
      localizedReason: 'Scan your fingerprint to unlock Durvasa Ayurved',
    );

    if (!mounted) return;

    setState(() {
      _isAuthenticating = false;
    });

    if (result.isSuccess) {
      _navigateToHome();
    } else {
      setState(() {
        _statusMessage = result.message;
        _isError = true;
      });
    }
  }

  void _verifyAndUnlockWithPassword() {
    final entered = _passwordController.text.trim();
    if (entered.isEmpty) {
      setState(() {
        _statusMessage = "Please enter your app password";
        _isError = true;
      });
      return;
    }

    if (AppSecurityService.verifyPassword(entered)) {
      _navigateToHome();
    } else {
      setState(() {
        _statusMessage = "Incorrect password. Please try again.";
        _isError = true;
      });
      _passwordController.clear();
      _passwordFocus.requestFocus();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => widget.isAsm
            ? AsmhomepageHomePage(
                userData: widget.userData,
                userId: widget.userId,
              )
            : EmployeeHomePage(
                userData: widget.userData,
                userId: widget.userId,
              ),
      ),
    );
  }

  void _continueWithLogin() {
    // Navigate to existing login without modifying saved preferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. App Logo / Brand Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/durvasa_logo.png',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.shield_outlined,
                      size: 44,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Title & User Greeting
                Text(
                  "Unlock App",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userData.name != null && widget.userData.name!.isNotEmpty
                      ? "Welcome back, ${widget.userData.name}"
                      : "Durvasa Ayurved Security",
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Main Unlock Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _showPasswordView
                      ? _buildPasswordView()
                      : _buildFingerprintView(),
                ),

                const SizedBox(height: 28),

                // 4. "Continue with Login" Fallback Option
                TextButton.icon(
                  onPressed: _continueWithLogin,
                  icon: const Icon(Icons.login_rounded, size: 18, color: AppColors.primaryGreen),
                  label: Text(
                    "Continue with Login",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintView() {
    return Column(
      children: [
        // Fingerprint Pulse Avatar
        GestureDetector(
          onTap: _isAuthenticating ? null : _authenticateWithFingerprint,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isError ? AppColors.error : AppColors.primaryGreen,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              size: 60,
              color: _isError ? AppColors.error : AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          "Use your fingerprint to continue",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),

        if (_statusMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (_isError ? AppColors.error : AppColors.secondaryGreen).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusMessage!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _isError ? AppColors.error : AppColors.secondaryGreen,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action Button: Try Again / Use Fingerprint
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isAuthenticating ? null : _authenticateWithFingerprint,
            icon: _isAuthenticating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.fingerprint, size: 20),
            label: Text(
              _isError ? "Try Again" : "Use Fingerprint",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Switch to Password Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showPasswordView = true;
                _statusMessage = null;
                _isError = false;
              });
            },
            icon: const Icon(Icons.lock_outline, size: 18, color: AppColors.primaryGreen),
            label: Text(
              "Use Password",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.primaryGreen),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Text(
            "Enter App Password",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            "Testing Default: 1234",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password Input Field
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          keyboardType: TextInputType.number,
          obscureText: _obscurePassword,
          style: GoogleFonts.poppins(fontSize: 16, letterSpacing: 3),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "••••",
            hintStyle: GoogleFonts.poppins(letterSpacing: 4, color: Colors.grey.shade400),
            filled: true,
            fillColor: AppColors.creamBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onSubmitted: (_) => _verifyAndUnlockWithPassword(),
        ),

        if (_statusMessage != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: (_isError ? AppColors.error : AppColors.secondaryGreen).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusMessage!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _isError ? AppColors.error : AppColors.secondaryGreen,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Unlock Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _verifyAndUnlockWithPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              "Unlock",
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),

        // If biometric is supported & enabled, show option to switch back to Fingerprint
        if (_isFingerprintEnabled && _isBiometricSupported && _isBiometricEnrolled) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showPasswordView = false;
                  _statusMessage = null;
                  _isError = false;
                });
                _authenticateWithFingerprint();
              },
              icon: const Icon(Icons.fingerprint, size: 20, color: AppColors.primaryGreen),
              label: Text(
                "Use Fingerprint Instead",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
