import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Dealer_Model/dealer_login_model.dart';

class DealerSessionManager {
  static const String _prefsKey = 'dealer_login_data';
  static const String _isLoggedInKey = 'dealer_is_logged_in';
  static const String _dealerIdKey = 'dealer_id';
  static const String _nameKey = 'dealer_name';
  static const String _emailKey = 'dealer_email';
  static const String _mobileKey = 'dealer_mobile';
  static const String _gstKey = 'dealer_gst';
  static const String _addressKey = 'dealer_address';

  static const String _savedMobileKey = 'saved_dealer_mobile';
  static const String _savedPasswordKey = 'saved_dealer_password';

  /// Save login data and synchronize all individual session keys
  static Future<bool> saveLoginData(DealerModel dealer) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = jsonEncode(dealer.toJson());
      if (jsonString.isEmpty) {
        debugPrint('Warning: Empty JSON string when saving dealer login data');
        return false;
      }

      final bool savedData = await prefs.setString(_prefsKey, jsonString);
      final bool savedFlag = await prefs.setBool(_isLoggedInKey, true);

      if (dealer.dealerId.isNotEmpty) {
        await prefs.setString(_dealerIdKey, dealer.dealerId);
      }
      if (dealer.name.isNotEmpty) {
        await prefs.setString(_nameKey, dealer.name);
      }
      if (dealer.email.isNotEmpty) {
        await prefs.setString(_emailKey, dealer.email);
      }
      if (dealer.phone.isNotEmpty) {
        await prefs.setString(_mobileKey, dealer.phone);
      }
      if (dealer.gstNumber.isNotEmpty) {
        await prefs.setString(_gstKey, dealer.gstNumber);
      }
      if (dealer.businessAddress.isNotEmpty) {
        await prefs.setString(_addressKey, dealer.businessAddress);
      }

      debugPrint(
        '✅ Dealer session saved - Data: $savedData, Flag: $savedFlag, DealerID: ${dealer.dealerId}',
      );
      return savedData && savedFlag;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving dealer login data: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Save credentials for auto-fill
  static Future<void> saveCredentials(String mobile, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedMobileKey, mobile);
      await prefs.setString(_savedPasswordKey, password);
    } catch (e) {
      debugPrint('Error saving dealer credentials: $e');
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
      debugPrint('Error retrieving saved dealer credentials: $e');
      return {'mobile': null, 'password': null};
    }
  }

  static Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedMobileKey);
      await prefs.remove(_savedPasswordKey);
    } catch (e) {
      debugPrint('Error clearing dealer credentials: $e');
    }
  }

  /// Retrieve login data with robust parsing and fallback recovery
  static Future<DealerModel?> getLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedInFlag = prefs.getBool(_isLoggedInKey) ?? false;

      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonString);
          if (decoded is Map<String, dynamic>) {
            final model = DealerModel.fromJson(decoded);
            if (_hasValidUserData(model)) {
              return model;
            }
          }
        } catch (parseError) {
          debugPrint('Warning: Error parsing stored dealer login JSON: $parseError');
        }
      }

      // Fallback: recover from individual keys
      final storedDealerId = prefs.getString(_dealerIdKey);
      if (isLoggedInFlag && storedDealerId != null && storedDealerId.isNotEmpty) {
        debugPrint('Recovering dealer session from individual stored preferences...');
        final recoveredModel = DealerModel(
          dealerId: storedDealerId,
          name: prefs.getString(_nameKey) ?? '',
          email: prefs.getString(_emailKey) ?? '',
          phone: prefs.getString(_mobileKey) ?? '',
          gstNumber: prefs.getString(_gstKey) ?? '',
          businessAddress: prefs.getString(_addressKey) ?? '',
        );

        await saveLoginData(recoveredModel);
        return recoveredModel;
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('Error retrieving dealer login data: $e');
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
      final hasDealerId = (prefs.getString(_dealerIdKey)?.isNotEmpty ?? false);

      return hasJson || hasDealerId;
    } catch (e, stackTrace) {
      debugPrint('Error checking dealer login status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static bool _hasValidUserData(DealerModel model) {
    return model.dealerId.isNotEmpty || model.phone.isNotEmpty || model.name.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_prefsKey);
      await prefs.remove(_dealerIdKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_mobileKey);
      await prefs.remove(_gstKey);
      await prefs.remove(_addressKey);

      await prefs.setBool(_isLoggedInKey, false);

      debugPrint('================================');
      debugPrint('✅ DEALER LOGOUT COMPLETE: Session cleared');
      debugPrint('================================');
    } catch (e) {
      debugPrint('Dealer logout error: $e');
      rethrow;
    }
  }

  // --- Convenience Getters ---
  static Future<String?> getDealerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dealerIdKey);
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