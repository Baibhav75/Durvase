import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Retailer_model/retailer_login_model.dart';
import '../session_manager.dart';

class RetailerSessionManager {
  static const String _prefsKey = 'retailer_login_data';
  static const String _isLoggedInKey = 'retailer_is_logged_in';
  static const String _visiterIdKey = 'retailer_visiter_id';
  static const String _legacyRetailerIdKey = 'retailer_id';
  static const String _loginDataKey = 'retailer_login_data_id';
  static const String _personNameKey = 'retailer_person_name';
  static const String _businessNameKey = 'retailer_business_name';
  static const String _nameKey = 'retailer_name';
  static const String _emailKey = 'retailer_email';
  static const String _mobileKey = 'retailer_mobile';
  static const String _addressKey = 'retailer_address';
  static const String _photoKey = 'retailer_photo';
  static const String _profileKey = 'retailer_profile';
  static const String _empTypeKey = 'retailer_emp_type';
  static const String _visitForKey = 'retailer_visit_for';
  static const String _purposeKey = 'retailer_purpose';

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

      final String vId = retailer.visiterId.isNotEmpty ? retailer.visiterId : retailer.retailerId;

      if (vId.isNotEmpty) {
        await prefs.setString(_visiterIdKey, vId);
        await prefs.setString(_legacyRetailerIdKey, vId);
        // Sync with central SessionManager
        await SessionManager.saveRetailerId(vId);
      }
      if (retailer.loginData.isNotEmpty) {
        await prefs.setString(_loginDataKey, retailer.loginData);
      }
      if (retailer.personName.isNotEmpty) {
        await prefs.setString(_personNameKey, retailer.personName);
      }
      if (retailer.businessName.isNotEmpty) {
        await prefs.setString(_businessNameKey, retailer.businessName);
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
      if (retailer.address.isNotEmpty) {
        await prefs.setString(_addressKey, retailer.address);
      }
      if (retailer.photo.isNotEmpty) {
        await prefs.setString(_photoKey, retailer.photo);
        await prefs.setString(_profileKey, retailer.photo);
      }
      if (retailer.empType.isNotEmpty) {
        await prefs.setString(_empTypeKey, retailer.empType);
      }
      if (retailer.visitFor.isNotEmpty) {
        await prefs.setString(_visitForKey, retailer.visitFor);
      }
      if (retailer.purpose.isNotEmpty) {
        await prefs.setString(_purposeKey, retailer.purpose);
      }

      debugPrint(
        '✅ Retailer session saved - Data: $savedData, Flag: $savedFlag, VisiterID: $vId',
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
      final storedVisiterId = prefs.getString(_visiterIdKey) ?? prefs.getString(_legacyRetailerIdKey);
      if (isLoggedInFlag && storedVisiterId != null && storedVisiterId.isNotEmpty) {
        debugPrint('Recovering retailer session from individual stored preferences...');
        final recoveredModel = RetailerModel(
          visiterId: storedVisiterId,
          loginData: prefs.getString(_loginDataKey) ?? '',
          personName: prefs.getString(_personNameKey) ?? '',
          businessName: prefs.getString(_businessNameKey) ?? '',
          name: prefs.getString(_nameKey) ?? '',
          email: prefs.getString(_emailKey) ?? '',
          phone: prefs.getString(_mobileKey) ?? '',
          address: prefs.getString(_addressKey) ?? '',
          photo: prefs.getString(_photoKey) ?? prefs.getString(_profileKey) ?? '',
          empType: prefs.getString(_empTypeKey) ?? '',
          visitFor: prefs.getString(_visitForKey) ?? '',
          purpose: prefs.getString(_purposeKey) ?? 'Retailer',
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
      final hasVisiterId = (prefs.getString(_visiterIdKey)?.isNotEmpty ?? false) ||
          (prefs.getString(_legacyRetailerIdKey)?.isNotEmpty ?? false);

      return hasJson || hasVisiterId;
    } catch (e, stackTrace) {
      debugPrint('Error checking retailer login status: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  static bool _hasValidUserData(RetailerModel model) {
    return model.visiterId.isNotEmpty || model.phone.isNotEmpty || model.name.isNotEmpty || model.personName.isNotEmpty;
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_prefsKey);
      await prefs.remove(_visiterIdKey);
      await prefs.remove(_legacyRetailerIdKey);
      await prefs.remove(_loginDataKey);
      await prefs.remove(_personNameKey);
      await prefs.remove(_businessNameKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_mobileKey);
      await prefs.remove(_addressKey);
      await prefs.remove(_photoKey);
      await prefs.remove(_profileKey);
      await prefs.remove(_empTypeKey);
      await prefs.remove(_visitForKey);
      await prefs.remove(_purposeKey);

      await prefs.setBool(_isLoggedInKey, false);

      // Also clear central SessionManager retailer ID
      await SessionManager.clearRetailerId();

      debugPrint('================================');
      debugPrint('✅ RETAILER LOGOUT COMPLETE: Session cleared');
      debugPrint('================================');
    } catch (e) {
      debugPrint('Retailer logout error: $e');
      rethrow;
    }
  }

  // --- Convenience Getters ---
  static Future<String?> getVisiterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_visiterIdKey) ?? prefs.getString(_legacyRetailerIdKey);
  }

  static Future<String?> getRetailerId() async {
    return getVisiterId();
  }

  static Future<String?> getPersonName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_personNameKey) ?? prefs.getString(_nameKey);
  }

  static Future<String?> getBusinessName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessNameKey);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? prefs.getString(_personNameKey) ?? prefs.getString(_businessNameKey);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileKey);
  }

  static Future<String?> getPhone() async {
    return getMobile();
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  static Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey) ?? prefs.getString(_profileKey);
  }

  static Future<String?> getPurpose() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_purposeKey);
  }

  static Future<String?> getEmpType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empTypeKey);
  }

  static Future<String?> getVisitFor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_visitForKey);
  }

  static Future<String?> getLoginDataId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginDataKey);
  }
}