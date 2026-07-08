import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/mr_model.dart';

class WorkAreaDebugHelper {
  static const String baseUrl = 'https://durvasaayurved.com/API/';

  // Test API directly with detailed logging
  static Future<Map<String, dynamic>> testWorkAreaAPI(String employeeId) async {
    try {
      final url = '$baseUrl/WorkAreaMR?EmployeeId=$employeeId';
      print('🧪 Testing API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('🧪 Response Status: ${response.statusCode}');
      print('🧪 Response Headers: ${response.headers}');
      print('🧪 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('🧪 Parsed Data: $data');

        // Try to parse with MrModel
        try {
          final MrModel model = MrModel.fromJson(data);
          print('🧪 MrModel parsed successfully');
          print('🧪 Message: ${model.message}');
          print('🧪 Data count: ${model.datas1?.length ?? 0}');

          if (model.datas1 != null) {
            for (int i = 0; i < model.datas1!.length; i++) {
              var area = model.datas1![i];
              print(
                '🧪 Area $i: State=${area.state}, District=${area.district}, Block=${area.blockName}',
              );
            }
          }
        } catch (e) {
          print('🧪 Error parsing with MrModel: $e');
        }

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
          'rawBody': response.body,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'HTTP ${response.statusCode}',
          'rawBody': response.body,
        };
      }
    } catch (e) {
      print('🧪 API Test Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create sample work area data for testing
  static List<Datas1> createSampleWorkAreas() {
    return [
      Datas1(
        id: 1,
        empId: 'EMP001',
        empName: 'Test Employee',
        stateId: 1,
        state: 'Bihar',
        districtId: 1,
        district: 'Patna',
        blockId: 1,
        blockName: 'Patna Sadar',
        status: 'Active',
        createDate: '2024-01-01',
        updateDate: null,
        employeeId: 'EMP001',
      ),
      Datas1(
        id: 2,
        empId: 'EMP001',
        empName: 'Test Employee',
        stateId: 1,
        state: 'Bihar',
        districtId: 2,
        district: 'Gaya',
        blockId: 2,
        blockName: 'Gaya Sadar',
        status: 'Active',
        createDate: '2024-01-01',
        updateDate: null,
        employeeId: 'EMP001',
      ),
    ];
  }

  // Check if employee has valid work areas
  static bool hasValidWorkAreas(List<Datas1>? workAreas) {
    if (workAreas == null || workAreas.isEmpty) return false;

    for (var area in workAreas) {
      if (area.state != null &&
          area.state!.isNotEmpty &&
          area.district != null &&
          area.district!.isNotEmpty &&
          area.blockName != null &&
          area.blockName!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
