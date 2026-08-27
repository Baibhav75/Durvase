import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Retailer_model/retailer_login_model.dart';

class RetailerSessionManager {
  static const String _prefsKey = 'retailer_login_data';
  static const String _isLoggedInKey = 'retailer_is_logged_in';
  static const String _retailerIdKey = 'retailer_id';
  static const String _nameKey = 'retailer_name';
  static const String _emailKey = 'retailer_email';
  static const String _mobileKey = 'retailer_mobile';
  static const String _addressKey = 'retailer_address';
  static const String _profileKey = 'retailer_profile';

  static const String _savedMobileKey = 'saved_retailer_mobile';
  static const String _savedPasswordKey = 'saved_retailer_password';

  /// Save login data and synchronize all individual session keys
  static Future<bool> saveLoginData(RetailerModel retailer) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = jsonEncode(retailer.toJson());
      if (jsonString.isEmpty) {
        debugPrint('Warning: Empty JSON string when saving retailer login data');
        return false;
      }

      final bool savedData = await prefs.setString(_prefsKey, jsonString);
      final bool savedFlag = await prefs.setBool(_isLoggedInKey, true);

      if (retailer.retailerId.isNotEmpty) {
        await prefs.setString(_retailerIdKey, retailer.retailerId);
      }
      if (retailer.name.isNotEmpty) {
        await prefs.setString(_nameKey, retailer.name);
      }
      if (retailer.email.isNotEmpty) {
        await prefs.setString(_emailKey, retailer.email);
      }
      if (retailer.phone.isNotEmpty) {
        await prefs.setString(_mobileKey, retailer.phone);
      }
      if (retailer.businessAddress.isNotEmpty) {
        await prefs.setString(_addressKey, retailer.businessAddress);
      }
      if (retailer.profile.isNotEmpty) {
        await prefs.setString(_profileKey, retailer.profile);
      }

      debugPrint(
        '✅ Retailer session saved - Data: $savedData, Flag: $savedFlag, RetailerID: ${retailer.retailerId}',
      );
      return savedData && savedFlag;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving retailer login data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static Future<void> saveCredentials(String mobile, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedMobileKey, mobile);
      await prefs.setString(_savedPasswordKey, password);
    } catch (e) {
      debugPrint('Error saving retailer credentials: $e');
    }
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'mobile': prefs.getString(_savedMobileKey),
        'password': prefs.getString(_savedPasswordKey),
      };
    } catch (e) {
      debugPrint('Error retrieving saved retailer credentials: $e');
      return {'mobile': null, 'password': null};
    }
  }

  static Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedMobileKey);
      await prefs.remove(_savedPasswordKey);
    } catch (e) {
      debugPrint('Error clearing retailer credentials: $e');
    }
  }

  /// Retrieve login data with robust parsing and fallback recovery
  static Future<RetailerModel?> getLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;

      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonString);
          if (decoded is Map<String, dynamic>) {
            final model = RetailerModel.fromJson(decoded);
            if (_hasValidUserData(model)) {
              return model;
            }
          }
        } catch (parseError) {
          debugPrint('Warning: Error parsing stored retailer login JSON: $parseError');
        }
      }

      // Fallback: recover from individual keys
      final storedRetailerId = prefs.getString(_retailerIdKey);
      if (isLoggedInFlag && storedRetailerId != null && storedRetailerId.isNotEmpty) {
        debugPrint('Recovering retailer session from individual stored preferences...');
        final recoveredModel = RetailerModel(
          retailerId: storedRetailerId,
          name: prefs.getString(_nameKey) ?? '',
          email: prefs.getString(_emailKey) ?? '',
          phone: prefs.getString(_mobileKey) ?? '',
          businessAddress: prefs.getString(_addressKey) ?? '',
          profile: prefs.getString(_profileKey) ?? '',
        );

        await saveLoginData(recoveredModel);
        return recoveredModel;
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('Error retrieving retailer login data: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;
      if (!isLoggedInFlag) return false;

      final hasJson = (prefs.getString(_prefsKey)?.isNotEmpty ?? false);
      final hasRetailerId = (prefs.getString(_retailerIdKey)?.isNotEmpty ?? false);

      return hasJson || hasRetailerId;
    } catch (e, stackTrace) {
      debugPrint('Error checking retailer login status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static bool _hasValidUserData(RetailerModel model) {
    return model.retailerId.isNotEmpty || model.phone.isNotEmpty || model.name.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_prefsKey);
      await prefs.remove(_retailerIdKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_mobileKey);
      await prefs.remove(_addressKey);
      await prefs.remove(_profileKey);

      await prefs.setBool(_isLoggedInKey, false);

      debugPrint('================================');
      debugPrint('✅ RETAILER LOGOUT COMPLETE: Session cleared');
      debugPrint('================================');
    } catch (e) {
      debugPrint('Retailer logout error: $e');
      rethrow;
    }
  }

  // --- Convenience Getters ---
  static Future<String?> getRetailerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_retailerIdKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }
}