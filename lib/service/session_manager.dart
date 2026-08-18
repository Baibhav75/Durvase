import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/TodoModel.dart';
import '../model/TodoModel1.dart';
import 'api_serviceProfile.dart';

class SessionManager {
  static const String _prefsKey = 'employee_login_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _legacyUserIdKey = 'userId';
  static const String _empIdKey = 'emp_id';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _mobileKey = 'mobile';
  static const String _employeeTypeKey = 'employee_type';

  // Saved credentials keys (for auto-fill / remember login)
  static const String _savedMobileKey = 'saved_login_mobile';
  static const String _savedPasswordKey = 'saved_login_password';
  static const String _savedRoleKey = 'saved_login_role';

  /// Save login data and synchronize all individual session keys
  static Future<bool> saveLoginData(TodoModel userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ensure employeeType is correctly preserved for ASM / Employee
      if (userData.asmId != null && userData.asmId!.isNotEmpty) {
        userData.employeeType ??= 'ASM';
      }

      final userMap = userData.toJson();
      final jsonString = jsonEncode(userMap);

      if (jsonString.isEmpty) {
        debugPrint('Warning: Empty JSON string when saving login data');
        return false;
      }

      // Save primary session flags and JSON payload
      final bool savedData = await prefs.setString(_prefsKey, jsonString);
      final bool savedFlag = await prefs.setBool(_isLoggedInKey, true);

      // Save individual fields for fast and reliable access across all pages
      final empId = userData.empId ?? userData.asmId ?? '';
      if (empId.isNotEmpty) {
        await prefs.setString(_empIdKey, empId);
        await prefs.setString(_userIdKey, empId);
        await prefs.setString(_legacyUserIdKey, empId);
      }

      if (userData.name != null && userData.name!.isNotEmpty) {
        await prefs.setString(_nameKey, userData.name!);
      }
      if (userData.email != null && userData.email!.isNotEmpty) {
        await prefs.setString(_emailKey, userData.email!);
      }
      if (userData.mobile != null && userData.mobile!.isNotEmpty) {
        await prefs.setString(_mobileKey, userData.mobile!);
      }
      if (userData.employeeType != null && userData.employeeType!.isNotEmpty) {
        await prefs.setString(_employeeTypeKey, userData.employeeType!);
      }

      debugPrint(
        '✅ SharedPreferences save result - Data: $savedData, Flag: $savedFlag, EmpId: $empId, Role: ${userData.employeeType}',
      );
      return savedData && savedFlag;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving login data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Save login ID and password for auto-filling and persistent credentials
  static Future<void> saveCredentials(
    String mobile,
    String password, {
    String role = 'Employee',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedMobileKey, mobile);
      await prefs.setString(_savedPasswordKey, password);
      await prefs.setString(_savedRoleKey, role);
      debugPrint('✅ Saved credentials for $role (Mobile: $mobile)');
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  /// Retrieve saved login ID and password
  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'mobile': prefs.getString(_savedMobileKey),
        'password': prefs.getString(_savedPasswordKey),
        'role': prefs.getString(_savedRoleKey),
      };
    } catch (e) {
      debugPrint('Error retrieving saved credentials: $e');
      return {'mobile': null, 'password': null, 'role': null};
    }
  }

  /// Clear saved credentials if needed
  static Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedMobileKey);
      await prefs.remove(_savedPasswordKey);
      await prefs.remove(_savedRoleKey);
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  /// Retrieve login data with robust parsing and automatic recovery fallback
  static Future<TodoModel?> getLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;

      // 1. Try retrieving and parsing the full JSON string
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonString);
          if (decoded is Map<String, dynamic>) {
            final model = TodoModel.fromJson(decoded);
            if (_hasValidUserData(model)) {
              return model;
            }
          }
        } catch (parseError) {
          debugPrint('Warning: Error parsing stored login JSON: $parseError');
        }
      }

      // 2. Resilient Fallback: If JSON is absent or malformed but user is logged in,
      // recover TodoModel from individual saved preferences
      final storedEmpId = prefs.getString(_empIdKey) ??
          prefs.getString(_userIdKey) ??
          prefs.getString(_legacyUserIdKey);

      if (isLoggedInFlag && storedEmpId != null && storedEmpId.isNotEmpty) {
        debugPrint('Recovering session from individual stored preferences...');
        final recoveredModel = TodoModel(
          status: 'success',
          empId: storedEmpId,
          name: prefs.getString(_nameKey),
          email: prefs.getString(_emailKey),
          mobile: prefs.getString(_mobileKey),
          employeeType: prefs.getString(_employeeTypeKey),
        );

        // Re-persist recovered JSON for subsequent calls
        await saveLoginData(recoveredModel);
        return recoveredModel;
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('Error retrieving login data: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Check if a valid login session exists
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedInFlag) return false;

      // Verify that at least one identifying session field exists
      final hasJson = (prefs.getString(_prefsKey)?.isNotEmpty ?? false);
      final hasEmpId = (prefs.getString(_empIdKey)?.isNotEmpty ?? false) ||
          (prefs.getString(_userIdKey)?.isNotEmpty ?? false) ||
          (prefs.getString(_legacyUserIdKey)?.isNotEmpty ?? false);

      return hasJson || hasEmpId;
    } catch (e, stackTrace) {
      debugPrint('Error checking login status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Helper to check if model has minimum required data
  static bool _hasValidUserData(TodoModel model) {
    return (model.empId != null && model.empId!.isNotEmpty) ||
        (model.mobile != null && model.mobile!.isNotEmpty) ||
        (model.name != null && model.name!.isNotEmpty);
  }

  /// Clear all login and user data (logout)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all session-specific values
      await prefs.remove(_prefsKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_legacyUserIdKey);
      await prefs.remove(_empIdKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_mobileKey);
      await prefs.remove(_employeeTypeKey);

      await prefs.setBool(_isLoggedInKey, false);

      // Clear in-memory profile cache
      ApiService.clearProfileCache();

      debugPrint('================================');
      debugPrint('✅ LOGOUT COMPLETE: Session cleared');
      debugPrint('is_logged_in: ${prefs.getBool(_isLoggedInKey)}');
      debugPrint('================================');
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  /// Synchronize profile details from Data1 (profile API response)
  static Future<void> saveUserProfile(Data1 employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = employee.userId ?? employee.empId ?? employee.employeeId ?? '';
      final empId = employee.empId ?? employee.employeeId ?? employee.userId ?? '';
      final name = employee.name ?? '';
      final email = employee.email ?? '';
      final mobile = employee.mobile ?? '';
      final employeeType = employee.employeeType ?? '';

      if (userId.isNotEmpty) {
        await prefs.setString(_userIdKey, userId);
        await prefs.setString(_legacyUserIdKey, userId);
      }
      if (empId.isNotEmpty) {
        await prefs.setString(_empIdKey, empId);
      }
      if (name.isNotEmpty) {
        await prefs.setString(_nameKey, name);
      }
      if (email.isNotEmpty) {
        await prefs.setString(_emailKey, email);
      }
      if (mobile.isNotEmpty) {
        await prefs.setString(_mobileKey, mobile);
      }
      if (employeeType.isNotEmpty) {
        await prefs.setString(_employeeTypeKey, employeeType);
      }

      // Also update the cached TodoModel JSON
      final currentData = await getLoginData();
      if (currentData != null) {
        if (name.isNotEmpty) currentData.name = name;
        if (email.isNotEmpty) currentData.email = email;
        if (mobile.isNotEmpty) currentData.mobile = mobile;
        if (employeeType.isNotEmpty) currentData.employeeType = employeeType;
        if (empId.isNotEmpty) currentData.empId = empId;
        await prefs.setString(_prefsKey, jsonEncode(currentData.toJson()));
      }
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // --- Convenience Getters ---
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) ??
        prefs.getString(_legacyUserIdKey) ??
        prefs.getString(_empIdKey);
  }

  static Future<String?> getEmpId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empIdKey) ??
        prefs.getString(_userIdKey) ??
        prefs.getString(_legacyUserIdKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getEmployeeType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeTypeKey);
  }
}
