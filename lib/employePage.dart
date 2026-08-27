import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_colors.dart';
import 'AsmAdministister/asmHomePage.dart';
import 'employeehomepage.dart';
import 'model/TodoModel.dart';
import 'service/api_service.dart';
import 'service/app_security_service.dart';
import 'service/session_manager.dart';

enum LoginRole { none, employee, ams }

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  // Current active role (none = role selection, employee = employee login, ams = ams login)
  LoginRole _selectedRole = LoginRole.none;

  // Biometric State
  bool _isFingerprintEnabled = false;
  bool _isBiometricAuthenticating = false;

  // Employee Login Controllers & State
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // AMS Login Controllers & State
  final TextEditingController _amsMobileController = TextEditingController();
  final TextEditingController _amsPasswordController = TextEditingController();
  bool _amsObscurePassword = true;
  bool _amsIsLoading = false;
  final _amsFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkFingerprintStatus();
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
      debugPrint('Error checking fingerprint status on login: $e');
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

          if (isAsm) {
            _navigateToAsmHomePage(sessionData);
          } else {
            _navigateToHomePage(sessionData);
          }
        } else {
          // Session expired or absent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No active session found. Please enter your mobile number and password to log in.',
              ),
              backgroundColor: AppColors.darkGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4),
            ),
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

  Future<void> _loadSavedCredentials() async {
    try {
      final creds = await SessionManager.getSavedCredentials();
      final mobile = creds['mobile'];
      final password = creds['password'];
      final role = creds['role'];

      if (mounted && mobile != null && password != null && mobile.isNotEmpty) {
        setState(() {
          if (role == 'ASM') {
            _amsMobileController.text = mobile;
            _amsPasswordController.text = password;
          } else {
            _mobileController.text = mobile;
            _passwordController.text = password;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  // ==========================================
  // EMPLOYEE LOGIN LOGIC (Preserved Exactly)
  // ==========================================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mobile = _mobileController.text.trim();
      final password = _passwordController.text.trim();

      final response = await ApiService.loginEmployee(mobile, password);

      final todoModel = TodoModel.fromJson(response);

      if (todoModel.status?.toLowerCase() == 'success') {
        todoModel.employeeType ??= 'Employee';
        todoModel.mobile ??= mobile;

        // 1. Save session data
        final saveResult = await SessionManager.saveLoginData(todoModel);

        // 2. Save ID & Password
        await SessionManager.saveCredentials(mobile, password, role: 'Employee');

        if (!mounted) return;

        if (saveResult) {
          _navigateToHomePage(todoModel);
        } else {
          _showErrorDialog('Login successful but session could not be saved.');
          _navigateToHomePage(todoModel);
        }
      } else {
        if (mounted) {
          _showErrorDialog(todoModel.message ?? 'Login failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHomePage(TodoModel userData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeHomePage(
          userData: userData,
          userId: userData.empId?.toString() ?? '',
        ),
      ),
    );
  }

  void _navigateToAsmHomePage(TodoModel userData) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AsmhomepageHomePage(
          userData: userData,
          userId: userData.empId?.toString() ?? userData.asmId?.toString() ?? '',
        ),
      ),
    );
  }

  // ==========================================
  // AMS LOGIN LOGIC (Calls ApiService.loginAsm)
  // ==========================================
  Future<void> _loginAms() async {
    if (!_amsFormKey.currentState!.validate()) return;

    setState(() => _amsIsLoading = true);

    try {
      final mobile = _amsMobileController.text.trim();
      final password = _amsPasswordController.text.trim();

      final response = await ApiService.loginAsm(mobile, password);

      final todoModel = TodoModel.fromJson(response);

      if (todoModel.status?.toLowerCase() == 'success') {
        // Ensure ASM attributes are guaranteed to be saved
        todoModel.employeeType ??= 'ASM';
        todoModel.mobile ??= mobile;
        todoModel.empId ??= todoModel.asmId ?? mobile;
        todoModel.asmId ??= todoModel.empId;

        // 1. Save session data for auto-login & splash routing
        final saveResult = await SessionManager.saveLoginData(todoModel);

        // 2. Save ID & Password for ASM
        await SessionManager.saveCredentials(mobile, password, role: 'ASM');

        if (!mounted) return;

        if (saveResult) {
          _navigateToAsmHomePage(todoModel);
        } else {
          _showErrorDialog('Login successful but session could not be saved.');
          _navigateToAsmHomePage(todoModel);
        }
      } else {
        if (mounted) {
          _showErrorDialog(todoModel.message ?? 'AMS Login failed');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('AMS Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _amsIsLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Login Failed',
          style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.purple, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return 'Please enter mobile number';
    if (value.length != 10) return 'Please enter a valid 10-digit mobile number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryGreen, AppColors.darkGreen],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: size.height * 0.30,
                  floating: false,
                  pinned: true,
                  leading: _selectedRole != LoginRole.none
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          tooltip: 'Back to Role Selection',
                          onPressed: () {
                            setState(() {
                              _selectedRole = LoginRole.none;
                            });
                          },
                        )
                      : null,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/appiconwithoutbackground.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Container(
              decoration: const BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      final slideAnimation = Tween<Offset>(
                        begin: const Offset(0.05, 0.0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: slideAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _selectedRole == LoginRole.none
                        ? _buildRoleSelectionView(constraints)
                        : _selectedRole == LoginRole.employee
                            ? _buildEmployeeLoginForm(constraints)
                            : _buildAmsLoginForm(constraints),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ==========================================
  // 1. ROLE SELECTION VIEW (AMS & Employee Cards)
  // ==========================================
  Widget _buildRoleSelectionView(BoxConstraints constraints) {
    return SingleChildScrollView(
      key: const ValueKey('role_selection_view'),
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 64,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Choose Your Role",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  "Select the portal you wish to access",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Quick Fingerprint Login (Only when enabled)
              if (_isFingerprintEnabled) ...[
                _buildFingerprintLoginCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "OR LOGIN WITH CREDENTIALS",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // AMS Role Card
              _buildRoleCard(
                title: "AMS",
                badgeText: "Management",
                subtitle: "Asset & Management System access for administrators",
                icon: Icons.admin_panel_settings_rounded,
                gradientColors: const [AppColors.primaryGreen, AppColors.deepGold],
                onTap: () {
                  setState(() {
                    _selectedRole = LoginRole.ams;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Employee Role Card
              _buildRoleCard(
                title: "Employee",
                badgeText: "Field & Staff",
                subtitle: "Daily attendance, tasks, doctor visits & orders",
                icon: Icons.badge_rounded,
                gradientColors: const [AppColors.primaryGreen, AppColors.secondaryGreen],
                onTap: () {
                  setState(() {
                    _selectedRole = LoginRole.employee;
                  });
                },
              ),

              const Spacer(),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    "Durvasa Ayurved Enterprise Portal",
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

  // Helper Widget for Selectable Role Cards
  Widget _buildFingerprintLoginCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isBiometricAuthenticating ? null : _loginWithFingerprint,
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.lightGold.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                  child: _isBiometricAuthenticating
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded, color: AppColors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Login with Fingerprint",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryGold, width: 0.8),
                            ),
                            child: Text(
                              "FAST",
                              style: GoogleFonts.poppins(
                                color: AppColors.lightGold,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Touch fingerprint sensor to enter your account",
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.lightGold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget for Selectable Role Cards
  Widget _buildRoleCard({
    required String title,
    required String badgeText,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: gradientColors.first.withOpacity(0.12),
          highlightColor: gradientColors.first.withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.last.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 18),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF222222),
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: gradientColors.first.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.poppins(
                                color: gradientColors.first,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Arrow Action
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: gradientColors.first,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. EMPLOYEE LOGIN FORM (Preserved Design & Logic)
  // ==========================================
  Widget _buildEmployeeLoginForm(BoxConstraints constraints) {
    return SingleChildScrollView(
      key: const ValueKey('employee_login_form'),
      padding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 64,
        ),
        child: IntrinsicHeight(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Switch Role Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Employee Login",
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedRole = LoginRole.none),
                      icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.primaryGreen),
                      label: Text(
                        "Change",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Sign in with your registered mobile number",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // Mobile Field
                Text(
                  "Mobile Number",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: _validateMobile,
                    style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.phone_android, color: AppColors.primaryGreen, size: 20),
                      ),
                      hintText: "Enter 10-digit mobile number",
                      hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.6)),
                      counterText: "",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                Text(
                  "Password",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.lock_outline, color: AppColors.primaryGreen, size: 20),
                      ),
                      hintText: "Enter your password",
                      hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.white,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.35),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                            ],
                          ),
                        ),
                ),

                // Fingerprint Login Option (Only when enabled)
                if (_isFingerprintEnabled) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isBiometricAuthenticating ? null : _loginWithFingerprint,
                      icon: _isBiometricAuthenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                            )
                          : const Icon(Icons.fingerprint_rounded, size: 22, color: AppColors.primaryGreen),
                      label: Text(
                        "Login with Fingerprint",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Footer Text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Secure Employee Login",
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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

  // ==========================================
  // 3. AMS LOGIN FORM (Asset & Management System)
  // ==========================================
  Widget _buildAmsLoginForm(BoxConstraints constraints) {
    return SingleChildScrollView(
      key: const ValueKey('ams_login_form'),
      padding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight - 64,
        ),
        child: IntrinsicHeight(
          child: Form(
            key: _amsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Switch Role Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "AMS Portal Login",
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedRole = LoginRole.none),
                      icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.deepGold),
                      label: Text(
                        "Change",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepGold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Sign in to Asset & Management System",
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),

                // AMS Mobile Field
                Text(
                  "Mobile Number",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepGold.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _amsMobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: _validateMobile,
                    style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.phone_android, color: AppColors.deepGold, size: 20),
                      ),
                      hintText: "Enter 10-digit mobile number",
                      hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.6)),
                      counterText: "",
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.deepGold, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // AMS Password Field
                Text(
                  "Password",
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepGold.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _amsPasswordController,
                    obscureText: _amsObscurePassword,
                    validator: _validatePassword,
                    style: GoogleFonts.poppins(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.lock_outline, color: AppColors.deepGold, size: 20),
                      ),
                      hintText: "Enter password",
                      hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppColors.white,
                      suffixIcon: IconButton(
                        icon: Icon(_amsObscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textSecondary, size: 20),
                        onPressed: () => setState(() => _amsObscurePassword = !_amsObscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.deepGold, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 1)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.error, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // AMS Login Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepGold.withOpacity(0.35),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _amsIsLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.deepGold,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _loginAms,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In to AMS",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                            ],
                          ),
                        ),
                ),

                // Fingerprint Login Option (Only when enabled)
                if (_isFingerprintEnabled) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isBiometricAuthenticating ? null : _loginWithFingerprint,
                      icon: _isBiometricAuthenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deepGold),
                            )
                          : const Icon(Icons.fingerprint_rounded, size: 22, color: AppColors.deepGold),
                      label: Text(
                        "Login with Fingerprint",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepGold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.deepGold, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Footer Text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Secure AMS Portal Access",
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
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

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _amsMobileController.dispose();
    _amsPasswordController.dispose();
    super.dispose();
  }
}

