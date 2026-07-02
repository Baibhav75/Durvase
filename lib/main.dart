import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'homepage.dart';
import '/employeehomepage.dart';
import 'model/TodoModel.dart';
import 'service/session_manager.dart';
import '/service/shared_prefs_debug.dart';
import 'debug_work_area.dart'; // Add this import
import 'test_field_allotted.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Durvasa Ayurved',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/debug': (context) => WorkAreaDebugPage(
          employeeId:
          ModalRoute.of(context)?.settings.arguments as String? ??
              'EMP785291',
        ), // Accept employeeId as argument
        '/test-field': (context) =>
        const TestFieldAllottedPage(), // Add test page route
      },
    );
  }
}

// -------------------- Splash Screen --------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Wait for 3 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 3));

      // Check if user is logged in with error handling
      bool isLoggedIn = false;
      try {
        isLoggedIn = await SessionManager.isLoggedIn();
      } catch (e) {
        print('Error checking login status in SessionManager: $e');
        // Fallback to direct SharedPreferences check
        try {
          final prefs = await SharedPreferences.getInstance();
          isLoggedIn = prefs.getBool('is_logged_in') ?? false;
          if (isLoggedIn) {
            // Double-check by trying to get the data
            final jsonString = prefs.getString('employee_login_data');
            isLoggedIn = jsonString != null && jsonString.isNotEmpty;
          }
        } catch (fallbackError) {
          print('Fallback SharedPreferences check also failed: $fallbackError');
          isLoggedIn = false;
        }
      }

      if (isLoggedIn) {
        // Try to get saved user data
        TodoModel? userData;
        try {
          userData = await SessionManager.getLoginData();
        } catch (e) {
          print('Error getting login data from SessionManager: $e');
          // Fallback to direct SharedPreferences retrieval
          try {
            final prefs = await SharedPreferences.getInstance();
            final jsonString = prefs.getString('employee_login_data');
            if (jsonString != null && jsonString.isNotEmpty) {
              final jsonMap = jsonDecode(jsonString);
              if (jsonMap is Map<String, dynamic>) {
                userData = TodoModel.fromJson(jsonMap);
              }
            }
          } catch (fallbackError) {
            print('Fallback data retrieval also failed: $fallbackError');
          }
        }

        if (userData != null) {
          // Navigate to Employee Home Page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeHomePage(userData: userData!),
              ),
            );
          }
        } else {
          // If user data is not available, go to Home Page
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        }
      } else {
        // Not logged in, go to Home Page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error in splash screen: $e');
      print('Stack trace: $stackTrace');
      // Handle any errors and navigate to HomePage as fallback
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/durvasa_logo.png', width: 200)),
    );
  }
}
