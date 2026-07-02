import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'employeehomepage.dart';
import 'model/TodoModel.dart';
import 'service/api_service.dart';
import 'service/session_manager.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginEmployee(
        _mobileController.text.trim(),
        _passwordController.text.trim(),
      );

      final todoModel = TodoModel.fromJson(response);

      try {
        final pref = await SharedPreferences.getInstance();
        await pref.setString("userId", todoModel.empId.toString());
      } catch (e) {
        debugPrint('Error saving userId: $e');
      }

      if (todoModel.status?.toLowerCase() == 'success') {
        bool saveResult = false;
        try {
          saveResult = await SessionManager.saveLoginData(todoModel);
        } catch (e) {
          try {
            final pref = await SharedPreferences.getInstance();
            await pref.setString("employee_login_data", todoModel.toJson().toString());
            await pref.setBool("is_logged_in", true);
            saveResult = true;
          } catch (_) {}
        }

        if (saveResult) {
          _navigateToHomePage(todoModel);
        } else {
          _showErrorDialog('Login successful but session could not be saved.');
          _navigateToHomePage(todoModel);
        }
      } else {
        _showErrorDialog(todoModel.message ?? 'Login failed');
      }
    } catch (e) {
      _showErrorDialog('Login failed: $e');
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
        builder: (context) => EmployeeHomePage(userData: userData),
      ),
    );
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
            child: Text('OK', style: GoogleFonts.poppins(color: Colors.purple, fontWeight: FontWeight.w600)),
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
      backgroundColor: const Color(0xFF6A11CB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
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
                  expandedHeight: size.height * 0.35,
                  floating: false,
                  pinned: true,
                  iconTheme: const IconThemeData(color: Colors.white),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/logo3.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Durvasa",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Employee Portal",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
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
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 64, // 32 top + 32 bottom padding
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Welcome Back",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF333333),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "Sign in to continue",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Mobile Field
                              Text(
                                "Mobile Number",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF333333),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
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
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(Icons.phone_android, color: Colors.purple[700], size: 20),
                                    ),
                                    hintText: "Enter 10-digit mobile number",
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 2)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              Text(
                                "Password",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF333333),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.1),
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
                                    color: const Color(0xFF333333),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(Icons.lock_outline, color: Colors.purple[700], size: 20),
                                    ),
                                    hintText: "Enter your password",
                                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: Colors.white,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500], size: 20),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2)),
                                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 2)),
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
                                      color: const Color(0xFF6A11CB).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6A11CB),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 3,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6A11CB),
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
                                                color: Colors.white,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                              ),

                              const Spacer(),

                              // Footer Text
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    "Secure Employee Login",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[500],
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
                },
              ),
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
    super.dispose();
  }
}
