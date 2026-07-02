import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://durvasaayurved.online/API';

  // Login API method
  static Future<Map<String, dynamic>> loginEmployee(
      String mobile,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Login?mobile=$mobile&password=$password'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
