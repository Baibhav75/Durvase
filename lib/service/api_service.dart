import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://durvasaayurved.online/api';

  // Employee Login API method
  static Future<Map<String, dynamic>> loginEmployee(
    String mobile,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Login/Get?mobile=$mobile&password=$password'),
        headers: {'Content-Type': 'application/json'},
      );//https://durvasaayurved.online/api/Login/Get?mobile=9876543219&password=123456

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ASM Login API method
  static Future<Map<String, dynamic>> loginAsm(
    String mobile,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/asmlogin?mobile=$mobile&password=$password'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login ASM. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

