import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/location_Model.dart';

class MrService {
  static Future<location_Model?> getWorkAreaMR(String employeeId) async {
    try {
      // Replace with your actual API endpoint
      final response = await http.get(
        Uri.parse(
          'https://your-api-url.com/api/workarea?EmployeeId=$employeeId',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return location_Model.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in MrService: $e');
      rethrow;
    }
  }
}
