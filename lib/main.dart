import 'package:flutter/material.dart';
import 'dart:async';
import '/widgets/SplashScreen.dart';
import 'AsmAdministister/asmHomePage.dart';
import 'homepage.dart';
import 'employePage.dart';
import 'employeehomepage.dart';
import 'model/TodoModel.dart';
import 'service/session_manager.dart';
import 'debug_work_area.dart';
import 'test_field_allotted.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

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
        '/login': (context) => const HomePage(),
        '/employee-login': (context) => const EmployeeLoginPage(),
        '/debug': (context) => WorkAreaDebugPage(
          employeeId:
          ModalRoute.of(context)?.settings.arguments as String? ??
              'EMP785291',
        ),
        '/test-field': (context) => const TestFieldAllottedPage(),
      },
    );
  }
}

// -------------------- Splash Screen --------------------
