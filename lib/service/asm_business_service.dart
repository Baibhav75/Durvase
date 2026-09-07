// lib/service/visitor_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/asm_business_model.dart';

class VisitorService {
  static const String _baseUrl = 'https://durvasaayurved.com/api/GetAllVisiters';

  static Future<VisitorResponseModel> fetchAllVisitors() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return VisitorResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load visitors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching visitors: $e');
    }
  }
}