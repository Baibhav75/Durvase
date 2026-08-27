import 'dart:convert';
import 'package:ayarwadeapps/service/Retailer_service/retailer_session_manager.dart';
import 'package:http/http.dart' as http;

import '../../model/Retailer_model/retailer_login_model.dart';

class RetailerLoginResult {
  final bool success;
  final String message;
  final RetailerModel? retailer;

  RetailerLoginResult({required this.success, required this.message, this.retailer});
}

class RetailerService {
  static const String _baseUrl = 'https://durvasaayurved.online/api/retailerslogin';

  static Future<RetailerLoginResult> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'mobile': mobile,
        'password': password,
      });

      final response = await http.post(uri);

      if (response.statusCode != 200) {
        return RetailerLoginResult(success: false, message: 'Sign in failed. Try again.');
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'Success') {
        final retailer = RetailerModel.fromJson(data);
        await RetailerSessionManager.saveLoginData(retailer);
        return RetailerLoginResult(success: true, message: data['message'] ?? 'Login successful', retailer: retailer);
      } else {
        return RetailerLoginResult(success: false, message: data['message'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      return RetailerLoginResult(success: false, message: 'Something went wrong. Try again.');
    }
  }

  static Future<RetailerModel?> getSavedRetailer() => RetailerSessionManager.getLoginData();

  static Future<String?> getSavedRetailerId() => RetailerSessionManager.getRetailerId();

  static Future<bool> isLoggedIn() => RetailerSessionManager.isLoggedIn();

  static Future<void> logout() => RetailerSessionManager.logout();
}