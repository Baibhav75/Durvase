// work_area_unified_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/work_area_model.dart';

class WorkAreaUnifiedService {
  static const String baseUrl = 'https://durvasaayurved.com/API';

  static Future<List<WorkAreaModel>> getWorkAreas(String employeeId) async {
    try {
      print('🔍 Fetching unified work areas for employee: $employeeId');

      final response = await http.get(
        Uri.parse('$baseUrl/WorkAreaMR?EmployeeId=$employeeId'),
      );

      print('📥 Unified API Response status: ${response.statusCode}');
      print('📥 Unified API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        return _parseResponse(jsonResponse);
      } else {
        throw Exception(
          'Failed to load work areas. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Unified API Error: $e');
      throw Exception('Failed to load work areas: $e');
    }
  }

  static List<WorkAreaModel> _parseResponse(dynamic jsonResponse) {
    if (jsonResponse is Map<String, dynamic>) {
      // Handle the actual API response format which has a "datas1" array
      if (jsonResponse.containsKey('datas1') &&
          jsonResponse['datas1'] is List) {
        final dataList = jsonResponse['datas1'] as List;
        print('📊 Found datas1 array with ${dataList.length} items');
        return dataList.map<WorkAreaModel>((item) {
          // Convert the Datas1 format to WorkAreaModel format
          print('📋 Processing datas1 item: $item');
          if (item is Map<String, dynamic>) {
            final convertedItem = {
              'Block':
              item['BlockName'] ??
                  item['blockName'] ??
                  item['Block'] ??
                  item['block'] ??
                  'N/A',
              'District': item['District'] ?? item['district'] ?? 'N/A',
              'State': item['State'] ?? item['state'] ?? 'N/A',
            };
            print('🔄 Converted item: $convertedItem');
            return WorkAreaModel.fromJson(convertedItem);
          }
          return WorkAreaModel.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      }
    }

    // Return empty list if no valid data found
    return [];
  }

  // Extract unique states from work areas
  static List<String> getUniqueStates(List<WorkAreaModel> workAreas) {
    final states = <String>{};
    for (var area in workAreas) {
      if (area.state != 'N/A') {
        states.add(area.state);
      }
    }
    return states.toList();
  }

  // Extract unique districts for a specific state
  static List<String> getUniqueDistricts(
      List<WorkAreaModel> workAreas,
      String state,
      ) {
    final districts = <String>{};
    for (var area in workAreas) {
      if (area.state == state && area.district != 'N/A') {
        districts.add(area.district);
      }
    }
    return districts.toList();
  }

  // Extract unique blocks for a specific state and district
  static List<String> getUniqueBlocks(
      List<WorkAreaModel> workAreas,
      String state,
      String district,
      ) {
    final blocks = <String>{};
    for (var area in workAreas) {
      if (area.state == state &&
          area.district == district &&
          area.block != 'N/A') {
        blocks.add(area.block);
      }
    }
    return blocks.toList();
  }
}
