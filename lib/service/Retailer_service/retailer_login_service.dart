import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/Retailer_model/retailer_login_model.dart';
import 'retailer_session_manager.dart';

class RetailerLoginResult {
  final bool success;
  final String message;
  final RetailerModel? retailer;

  RetailerLoginResult({
    required this.success,
    required this.message,
    this.retailer,
  });
}

class RetailerService {
  static const String _primaryUrl = 'https://durvasaayurved.com/api/visiterlogin';

  /// Sign in Retailer using mobile and password
  static Future<RetailerLoginResult> login({
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

      debugPrint('📤 [RetailerLogin] Request URL: $uri');

      http.Response response;
      try {
        // Try POST first
        response = await http.post(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
      } catch (postErr) {
        debugPrint('⚠️ [RetailerLogin] POST failed, trying GET fallback: $postErr');
        // Fallback to GET
        response = await http.get(
          uri,
          headers: {
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 15));
      }

      debugPrint('📥 [RetailerLogin] Status: ${response.statusCode}');
      debugPrint('📥 [RetailerLogin] Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Try GET if POST returned method not allowed or error status
        try {
          final getResponse = await http.get(
            uri,
            headers: {'Accept': 'application/json'},
          ).timeout(const Duration(seconds: 10));
          if (getResponse.statusCode == 200) {
            response = getResponse;
          }
        } catch (_) {}
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        return RetailerLoginResult(
          success: false,
          message: 'Sign in failed (Server code ${response.statusCode}). Please check credentials.',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final status = decoded['status']?.toString().toLowerCase() ?? '';
        final hasVisiterId = decoded['VisiterID'] != null &&
            decoded['VisiterID'].toString().trim().isNotEmpty;
        final isSuccess = status == 'success' || hasVisiterId;

        if (isSuccess) {
          final retailer = RetailerModel.fromJson(decoded);
          await RetailerSessionManager.saveLoginData(retailer);

          return RetailerLoginResult(
            success: true,
            message: decoded['message']?.toString() ?? 'Login Successfully !!!',
            retailer: retailer,
          );
        } else {
          return RetailerLoginResult(
            success: false,
            message: decoded['message']?.toString() ?? 'Invalid mobile number or password.',
          );
        }
      }

      return RetailerLoginResult(
        success: false,
        message: 'Invalid server response format. Please try again.',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [RetailerLogin] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return RetailerLoginResult(
        success: false,
        message: 'Unable to connect to server. Please check your internet connection.',
      );
    }
  }

  // ---------- CONVENIENCE PASS-THROUGHS ----------
  static Future<RetailerModel?> getSavedRetailer() => RetailerSessionManager.getLoginData();

  static Future<String?> getSavedVisiterId() => RetailerSessionManager.getVisiterId();

  static Future<String?> getSavedRetailerId() => RetailerSessionManager.getRetailerId();

  static Future<bool> isLoggedIn() => RetailerSessionManager.isLoggedIn();

  static Future<void> logout() => RetailerSessionManager.logout();
}