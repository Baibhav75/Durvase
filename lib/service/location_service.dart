import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/mr_model.dart'; // Import MrModel instead
import '/model/visit_history_model.dart';
class LocationService {
  static const String baseUrl = 'https://durvasaayurved.online/API/';

  static Future<MrModel?> getWorkAreaMR(String employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/WorkAreaMR?EmployeeId=$employeeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return MrModel.fromJson(data);
      } else {
        throw Exception('Failed to load work area: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load work area: $e');
    }
  }
}
