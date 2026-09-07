import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/asm_doctor_model.dart';

class DoctorService {
  static const String _byVisitForUrl = 'https://durvasaayurved.com/api/GetVisiteByvisitFor';

  static Future<DoctorResponseModel> fetchDoctorVisitors() async {
    try {
      final uri = Uri.parse(_byVisitForUrl).replace(queryParameters: {'visitFor': 'Doctor'});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DoctorResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load doctor visits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching doctor visits: $e');
    }
  }
}