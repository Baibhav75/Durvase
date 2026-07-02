// service/visit_history_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/visit_history_model.dart';

class VisitHistoryService {
  static const String baseUrl = 'https://durvasaayurved.online/api';
  static const int timeoutSeconds = 30;

  // Method to get visitor list
  static Future<VisitHistory_model?> getVisitorList(String empMobile) async {
    try {
      print('📤 Fetching visit history for mobile: $empMobile');

      final response = await http
          .get(
        Uri.parse('$baseUrl/VisitorList?Emp_mobile=$empMobile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return VisitHistory_model.fromJson(data);
      } else {
        print('❌ API Error: ${response.statusCode}');
        return null;
      }
    } on http.ClientException catch (e) {
      print('❌ HTTP Client Exception: $e');
      return null;
    } on FormatException catch (e) {
      print('❌ JSON Format Exception: $e');
      return null;
    } catch (e) {
      print('❌ General Exception: $e');
      return null;
    }
  }
}