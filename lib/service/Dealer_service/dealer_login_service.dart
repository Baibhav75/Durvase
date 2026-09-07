import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../model/Dealer_Model/dealer_login_model.dart';
import 'dealer_session_manager.dart';

class DealerLoginResult {
  final bool success;
  final String message;
  final DealerModel? dealer;

  DealerLoginResult({
    required this.success,
    required this.message,
    this.dealer,
  });
}

class DealerService {
  static const String _primaryUrl = 'https://durvasaayurved.com/api/dealer/login';
  static const String _fallbackUrl = 'https://durvasaayurved.com/api/dealerlogin';

  // ---------- API CALL ----------
  static Future<DealerLoginResult> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final cleanMobile = mobile.trim();
      final cleanPassword = password.trim();

      final uri = Uri.parse(_primaryUrl).replace(queryParameters: {
        'mobile': cleanMobile,
        'password': cleanPassword,
      });

      debugPrint('📤 [DealerLogin] Request URL: $uri');

      http.Response response;
      try {
        // Try POST on primary endpoint first
        response = await http.post(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
      } catch (postErr) {
        debugPrint('⚠️ [DealerLogin] POST failed, trying GET: $postErr');
        // Fallback to GET on primary endpoint
        response = await http.get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
      }

      debugPrint('📥 [DealerLogin] Status: ${response.statusCode}');
      debugPrint('📥 [DealerLogin] Body: ${response.body}');

      // If status is not 200/201, try GET or fallback endpoint
      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final getResponse = await http.get(
            uri,
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 10));
          if (getResponse.statusCode == 200 || getResponse.statusCode == 201) {
            response = getResponse;
          } else {
            // Try legacy fallback endpoint
            final fallbackUri = Uri.parse(_fallbackUrl).replace(queryParameters: {
              'mobile': cleanMobile,
              'password': cleanPassword,
            });
            final fbResponse = await http.post(
              fallbackUri,
              headers: {'Accept': 'application/json'},
            ).timeout(const Duration(seconds: 10));
            if (fbResponse.statusCode == 200 || fbResponse.statusCode == 201) {
              response = fbResponse;
            }
          }
        } catch (_) {}
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        return DealerLoginResult(
          success: false,
          message: 'Sign in failed (Server code ${response.statusCode}). Please check your credentials.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final status = decoded['status']?.toString().toLowerCase() ?? '';
        final hasVisiterId = decoded['VisiterId'] != null && decoded['VisiterId'].toString().trim().isNotEmpty;
        final hasLoginData = decoded['LoginData'] != null && decoded['LoginData'].toString().trim().isNotEmpty;
        final hasDealerId = decoded['DealerID'] != null && decoded['DealerID'].toString().trim().isNotEmpty;

        final isSuccess = status == 'success' || hasVisiterId || hasLoginData || hasDealerId;

        if (isSuccess) {
          final dealer = DealerModel.fromJson(decoded);
          await DealerSessionManager.saveLoginData(dealer);
          await DealerSessionManager.saveCredentials(cleanMobile, cleanPassword);

          return DealerLoginResult(
            success: true,
            message: decoded['message']?.toString() ?? 'Login Successfully !!!',
            dealer: dealer,
          );
        } else {
          return DealerLoginResult(
            success: false,
            message: decoded['message']?.toString() ?? 'Invalid mobile number or password.',
          );
        }
      }

      return DealerLoginResult(
        success: false,
        message: 'Invalid server response format. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [DealerLogin] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return DealerLoginResult(
        success: false,
        message: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  // ---------- CONVENIENCE PASS-THROUGHS ----------
  static Future<DealerModel?> getSavedDealer() => DealerSessionManager.getLoginData();

  static Future<String?> getSavedDealerId() => DealerSessionManager.getDealerId();

  static Future<String?> getSavedVisiterId() => DealerSessionManager.getVisiterId();

  static Future<bool> isLoggedIn() => DealerSessionManager.isLoggedIn();

  static Future<void> logout() => DealerSessionManager.logout();
}