import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/TodoModel.dart';

class SessionManager {
  static const String _prefsKey = 'employee_login_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save login data
  static Future<bool> saveLoginData(TodoModel userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(userData.toJson());

      // Ensure we're not saving empty data
      if (jsonString.isEmpty) {
        print('Warning: Empty JSON string when saving login data');
        return false;
      }

      // Save both values and verify
      final bool savedData = await prefs.setString(_prefsKey, jsonString);
      final bool savedFlag = await prefs.setBool(_isLoggedInKey, true);

      print(
        'SharedPreferences save result - Data: $savedData, Flag: $savedFlag',
      );
      return savedData && savedFlag;
    } catch (e, stackTrace) {
      // Print error in debug mode only
      // In release mode, we silently fail
      print('Error saving login data: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Retrieve login data
  static Future<TodoModel?> getLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      print('Is logged in: $isLoggedIn');

      if (!isLoggedIn) {
        return null;
      }

      final jsonString = prefs.getString(_prefsKey);
      print('Retrieved JSON string: $jsonString');

      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final jsonMap = jsonDecode(jsonString);
          // Validate that we have the required fields
          if (jsonMap is Map<String, dynamic>) {
            return TodoModel.fromJson(jsonMap);
          } else {
            print(
              'Invalid JSON format: expected Map<String, dynamic>, got ${jsonMap.runtimeType}',
            );
          }
        } catch (parseError, stackTrace) {
          // If parsing fails, clear the invalid data
          print('Error parsing login data: $parseError');
          print('Stack trace: $stackTrace');
          await _clearInvalidData(prefs);
          return null;
        }
      }
      return null;
    } catch (e, stackTrace) {
      // In release mode, we silently fail and return null
      print('Error retrieving login data: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Also verify that we have valid data
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      print('SharedPreferences isLoggedIn check: $isLoggedIn');

      if (isLoggedIn) {
        // Double-check by trying to get the data
        final jsonString = prefs.getString(_prefsKey);
        final hasValidData = jsonString != null && jsonString.isNotEmpty;
        print('Has valid data: $hasValidData');
        return hasValidData;
      }
      return false;
    } catch (e, stackTrace) {
      // In case of any error, assume user is not logged in
      print('Error checking login status: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Clear login data (logout)
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('Successfully logged out');
    } catch (e, stackTrace) {
      // Silently fail in release mode
      print('Error during logout: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Clear invalid data
  static Future<void> _clearInvalidData(SharedPreferences prefs) async {
    try {
      await prefs.remove(_prefsKey);
      await prefs.setBool(_isLoggedInKey, false);
      print('Cleared invalid login data');
    } catch (e, stackTrace) {
      // Ignore errors
      print('Error clearing invalid data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Debug method to check what's stored (only for debugging)
  static Future<Map<String, dynamic>> debugGetStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final jsonString = prefs.getString(_prefsKey);

      return {
        'isLoggedIn': isLoggedIn,
        'jsonData': jsonString,
        'hasData': jsonString != null && jsonString.isNotEmpty,
      };
    } catch (e, stackTrace) {
      return {
        'isLoggedIn': false,
        'jsonData': null,
        'hasData': false,
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      };
    }
  }
}
