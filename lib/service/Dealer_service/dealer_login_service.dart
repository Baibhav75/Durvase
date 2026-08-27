

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/Dealer_Model/dealer_login_model.dart';
import 'dealer_session_manager.dart';

class DealerLoginResult {
  final bool success;
  final String message;
  final DealerModel? dealer;

  DealerLoginResult({required this.success, required this.message, this.dealer});
}

class DealerService {
  static const String _baseUrl = 'https://durvasaayurved.online/api/dealerlogin';

  // ---------- API CALL ----------
  static Future<DealerLoginResult> login({
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
        return DealerLoginResult(success: false, message: 'Sign in failed. Try again.');
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'Success') {
        final dealer = DealerModel.fromJson(data);
        await DealerSessionManager.saveLoginData(dealer); // 👈 unified session storage
        return DealerLoginResult(success: true, message: data['message'] ?? 'Login successful', dealer: dealer);
      } else {
        return DealerLoginResult(success: false, message: data['message'] ?? 'Login failed. Try again.');
      }
    } catch (e) {
      return DealerLoginResult(success: false, message: 'Something went wrong. Try again.');
    }
  }

  // ---------- CONVENIENCE PASS-THROUGHS ----------
  static Future<DealerModel?> getSavedDealer() => DealerSessionManager.getLoginData();

  static Future<String?> getSavedDealerId() => DealerSessionManager.getDealerId();

  static Future<bool> isLoggedIn() => DealerSessionManager.isLoggedIn();

  static Future<void> logout() => DealerSessionManager.logout();
}