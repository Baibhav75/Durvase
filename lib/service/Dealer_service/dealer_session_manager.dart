import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Dealer_Model/dealer_login_model.dart';
import '../session_manager.dart';

class DealerSessionManager {
  static const String _prefsKey = 'dealer_login_data';
  static const String _isLoggedInKey = 'dealer_is_logged_in';
  static const String _dealerIdKey = 'dealer_id';
  static const String _loginDataKey = 'dealer_login_data_id';
  static const String _visiterIdKey = 'dealer_visiter_id';
  static const String _nameKey = 'dealer_name';
  static const String _emailKey = 'dealer_email';
  static const String _mobileKey = 'dealer_mobile';
  static const String _businessNameKey = 'dealer_business_name';
  static const String _addressKey = 'dealer_address';
  static const String _purposeKey = 'dealer_purpose';
  static const String _photoKey = 'dealer_photo';
  static const String _stateKey = 'dealer_state';
  static const String _districtKey = 'dealer_district';
  static const String _gstKey = 'dealer_gst';

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
      if (dealer.loginData.isNotEmpty) {
        await prefs.setString(_loginDataKey, dealer.loginData);
      }
      if (dealer.visiterId.isNotEmpty) {
        await prefs.setString(_visiterIdKey, dealer.visiterId);
        // Also synchronize with global SessionManager for ordering / visiting compatibility
        await SessionManager.saveVisiterId(dealer.visiterId);
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
      if (dealer.businessName.isNotEmpty) {
        await prefs.setString(_businessNameKey, dealer.businessName);
      }
      if (dealer.businessAddress.isNotEmpty) {
        await prefs.setString(_addressKey, dealer.businessAddress);
      }
      if (dealer.purpose.isNotEmpty) {
        await prefs.setString(_purposeKey, dealer.purpose);
      }
      if (dealer.photo.isNotEmpty) {
        await prefs.setString(_photoKey, dealer.photo);
      }
      if (dealer.state.isNotEmpty) {
        await prefs.setString(_stateKey, dealer.state);
      }
      if (dealer.district.isNotEmpty) {
        await prefs.setString(_districtKey, dealer.district);
      }
      if (dealer.gstNumber.isNotEmpty) {
        await prefs.setString(_gstKey, dealer.gstNumber);
      }

      debugPrint(
        '✅ Dealer session saved - Data: $savedData, Flag: $savedFlag, DealerID: ${dealer.dealerId}, VisiterId: ${dealer.visiterId}',
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
      final storedDealerId = prefs.getString(_dealerIdKey) ?? prefs.getString(_visiterIdKey) ?? prefs.getString(_loginDataKey);
      if (isLoggedInFlag && storedDealerId != null && storedDealerId.isNotEmpty) {
        debugPrint('Recovering dealer session from individual stored preferences...');
        final recoveredModel = DealerModel(
          dealerId: storedDealerId,
          loginData: prefs.getString(_loginDataKey) ?? '',
          visiterId: prefs.getString(_visiterIdKey) ?? storedDealerId,
          name: prefs.getString(_nameKey) ?? '',
          email: prefs.getString(_emailKey) ?? '',
          phone: prefs.getString(_mobileKey) ?? '',
          businessName: prefs.getString(_businessNameKey) ?? '',
          businessAddress: prefs.getString(_addressKey) ?? '',
          purpose: prefs.getString(_purposeKey) ?? 'Dealer',
          photo: prefs.getString(_photoKey) ?? '',
          state: prefs.getString(_stateKey) ?? '',
          district: prefs.getString(_districtKey) ?? '',
          gstNumber: prefs.getString(_gstKey) ?? '',
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
      final hasDealerId = (prefs.getString(_dealerIdKey)?.isNotEmpty ?? false) ||
          (prefs.getString(_visiterIdKey)?.isNotEmpty ?? false) ||
          (prefs.getString(_loginDataKey)?.isNotEmpty ?? false);

      return hasJson || hasDealerId;
    } catch (e, stackTrace) {
      debugPrint('Error checking dealer login status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static bool _hasValidUserData(DealerModel model) {
    return model.dealerId.isNotEmpty || model.visiterId.isNotEmpty || model.phone.isNotEmpty || model.name.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_prefsKey);
      await prefs.remove(_dealerIdKey);
      await prefs.remove(_loginDataKey);
      await prefs.remove(_visiterIdKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_mobileKey);
      await prefs.remove(_businessNameKey);
      await prefs.remove(_addressKey);
      await prefs.remove(_purposeKey);
      await prefs.remove(_photoKey);
      await prefs.remove(_stateKey);
      await prefs.remove(_districtKey);
      await prefs.remove(_gstKey);

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
    return prefs.getString(_dealerIdKey) ?? prefs.getString(_visiterIdKey);
  }

  static Future<String?> getVisiterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_visiterIdKey) ?? prefs.getString(_dealerIdKey);
  }

  static Future<String?> getLoginDataId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginDataKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getBusinessName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessNameKey);
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  static Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey);
  }

  static Future<String?> getState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stateKey);
  }

  static Future<String?> getDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_districtKey);
  }

  static Future<String?> getPurpose() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purposeKey);
  }
}