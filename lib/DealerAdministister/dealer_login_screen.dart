import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../service/Dealer_service/dealer_login_service.dart';
import '../service/Dealer_service/dealer_session_manager.dart';
import 'dealer_dashboard_screen.dart';

class DealerLoginPage extends StatefulWidget {
  const DealerLoginPage({super.key});

  @override
  State<DealerLoginPage> createState() => _DealerLoginPageState();
}

class _DealerLoginPageState extends State<DealerLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _mobileError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await DealerSessionManager.getSavedCredentials();
    if (!mounted) return;
    if (credentials['mobile'] != null && credentials['mobile']!.isNotEmpty) {
      setState(() {
        _mobileController.text = credentials['mobile']!;
        if (credentials['password'] != null) {
          _passwordController.text = credentials['password']!;
        }
      });
    }
  }

  bool _validate() {
    setState(() {
      _mobileError = null;
      _passwordError = null;
    });

    bool isValid = true;
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    if (mobile.isEmpty) {
      setState(() => _mobileError = 'Enter your 10-digit mobile number');
      isValid = false;
    } else if (mobile.length != 10) {
      setState(() => _mobileError = 'Please enter a valid 10-digit mobile number');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Enter your password');
      isValid = false;
    } else if (password.length < 3) {
      setState(() => _passwordError = 'Password is too short');
      isValid = false;
    }

    return isValid;
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();

    if (!_validate()) return;

    setState(() => _isLoading = true);

    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    final result = await DealerService.login(
      mobile: mobile,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (_rememberMe) {
        await DealerSessionManager.saveCredentials(mobile, password);
      } else {
        await DealerSessionManager.clearCredentials();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DealerDashboardPage()),
      );
    } else {
      _showCustomSnackBar(result.message, isError: true);
    }
  }

  void _showCustomSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Top Bar with Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Durvasa Ayurved',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content to prevent keyboard overflow
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Brand Logo Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Hero(
                          tag: 'app_logo_dealer',
                          child: Image.asset(
                            'assets/appiconwithoutbackground.png',
                            height: (size.height * 0.16).clamp(110.0, 160.0),
                            width: (size.height * 0.16).clamp(110.0, 160.0),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                size: 54,
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Form Container
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: size.height * 0.65,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x2A000000),
                              blurRadius: 18,
                              offset: Offset(0, -4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Dealer Portal Login',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Text(
                                'Sign in to access your dealer dashboard & orders',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Mobile Number Field
                            _buildLabel('Mobile Number'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _mobileController,
                              focusNode: _mobileFocusNode,
                              hint: 'Enter 10-digit mobile number',
                              icon: Icons.smartphone_rounded,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              errorText: _mobileError,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onChanged: (val) {
                                if (_mobileError != null) {
                                  setState(() => _mobileError = null);
                                }
                              },
                              onSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_passwordFocusNode);
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password Field
                            _buildLabel('Password'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              hint: 'Enter your account password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              errorText: _passwordError,
                              onChanged: (val) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                              onSubmitted: (_) => _handleSignIn(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Remember Me & Help
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() => _rememberMe = !_rememberMe);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppColors.primaryGreen,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          onChanged: (val) {
                                            setState(() => _rememberMe = val ?? true);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  disabledBackgroundColor:
                                      AppColors.primaryGreen.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                  shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryGold,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign In to Dealer Portal',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: AppColors.primaryGold,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Security Footer
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    color: AppColors.secondaryGreen,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Encrypted & Authorized Dealer Portal Access',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : focusNode.hasFocus
                      ? AppColors.primaryGold
                      : AppColors.lightGold.withOpacity(0.7),
              width: hasError || focusNode.hasFocus ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppColors.error.withOpacity(0.08)
                    : AppColors.primaryGreen.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
              prefixIcon: Icon(
                icon,
                color: focusNode.hasFocus ? AppColors.primaryGreen : AppColors.primaryGold,
                size: 20,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: InputBorder.none,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}