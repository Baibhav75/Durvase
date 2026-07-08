// work_area_service.dart - SIMPLER VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/model/work_area_model.dart';

class WorkAreaService {
  static const String baseUrl = 'https://durvasaayurved.com/API';

  static Future<List<WorkAreaModel>> getWorkAreas(String employeeId) async {
    try {
      print('🔍 Fetching work areas for employee: $employeeId');

      final response = await http.get(
        Uri.parse('$baseUrl/WorkAreaMR?EmployeeId=$employeeId'),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        print('🔍 Response type: ${jsonResponse.runtimeType}');
        print('🔍 Response content: $jsonResponse');

        return _parseResponse(jsonResponse);
      } else {
        throw Exception(
          'Failed to load work areas. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Failed to load work areas: $e');
    }
  }

  static List<WorkAreaModel> _parseResponse(dynamic jsonResponse) {
    try {
      if (jsonResponse is List) {
        print('✅ Response is a List with ${jsonResponse.length} items');
        return jsonResponse.map<WorkAreaModel>((item) {
          print('📋 Processing list item: $item');
          return WorkAreaModel.fromJson(Map<String, dynamic>.from(item as Map));
        }).toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        print('✅ Response is a Map with keys: ${jsonResponse.keys}');

        // Handle the actual API response format which has a "datas1" array
        if (jsonResponse.containsKey('datas1') &&
            jsonResponse['datas1'] is List) {
          final dataList = jsonResponse['datas1'] as List;
          print('📊 Found datas1 array with ${dataList.length} items');
          return dataList.map<WorkAreaModel>((item) {
            // Convert the Datas1 format to WorkAreaModel format
            print('📋 Processing datas1 item: $item');
            if (item is Map<String, dynamic>) {
              return WorkAreaModel.fromJson(item);
            }
            return WorkAreaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          }).toList();
        }
        // Check if this is a single work area object
        else if (jsonResponse.containsKey('Block') ||
            jsonResponse.containsKey('District') ||
            jsonResponse.containsKey('State')) {
          print('📌 Found single work area object');
          return [WorkAreaModel.fromJson(jsonResponse)];
        }
        // Check for common wrapper structures
        else if (jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          final dataList = jsonResponse['data'] as List;
          print('📊 Found data array with ${dataList.length} items');
          return dataList.map<WorkAreaModel>((item) {
            print('📋 Processing data item: $item');
            return WorkAreaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          }).toList();
        } else {
          // Try to find any list in the map
          for (var key in jsonResponse.keys) {
            if (jsonResponse[key] is List) {
              print('✅ Found list in key: $key');
              final listData = jsonResponse[key] as List;
              return listData.map<WorkAreaModel>((item) {
                print('📋 Processing $key item: $item');
                return WorkAreaModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                );
              }).toList();
            }
          }
          print(
            '⚠️ No work area data found. Available keys: ${jsonResponse.keys}',
          );
          return [];
        }
      } else {
        print('⚠️ Unexpected response format: ${jsonResponse.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
      return [];
    }
  }
}
