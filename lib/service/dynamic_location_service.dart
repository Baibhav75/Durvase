import 'dart:convert';
import 'package:http/http.dart' as http;
import '/model/location_dart_model.dart';

class DynamicLocationService {
  static const String baseUrl = 'https://durvasaayurved.online/API/';

  // Fetch location data based on employee ID
  static Future<LocationDataModel?> getLocationData(String employeeId) async {
    if (employeeId.isEmpty) {
      throw Exception('Employee ID is required');
    }

    try {
      print('📤 Fetching location data for employee: $employeeId');

      final response = await http.get(
        Uri.parse('${baseUrl}WorkAreaMR?EmployeeId=$employeeId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Location API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(
          '🔍 Location API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
        );

        // Transform the API response to our location data model
        return _transformToLocationDataModel(data);
      } else {
        throw Exception(
          'Failed to load location data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getLocationData: $e');
      throw Exception('Failed to load location data: $e');
    }
  }

  // Transform the MrModel response to LocationDataModel
  static LocationDataModel _transformToLocationDataModel(
      Map<String, dynamic> apiResponse,
      ) {
    final locationData = LocationDataModel();
    final statesMap = <String, LocationItem>{};
    final districtsMap = <String, LocationItem>{};

    if (apiResponse['datas1'] != null) {
      // Group data by state, district, and block
      for (var item in apiResponse['datas1']) {
        final stateName = item['State'] as String?;
        final districtName = item['District'] as String?;
        final blockName = item['BlockName'] as String?;

        if (stateName != null && stateName.isNotEmpty) {
          // Add state if not exists
          if (!statesMap.containsKey(stateName)) {
            statesMap[stateName] = LocationItem(
              id: item['StateId'] as int?,
              name: stateName,
              districts: [],
            );
          }

          // Add district if not exists and district name is valid
          if (districtName != null && districtName.isNotEmpty) {
            final districtKey = '$stateName-$districtName';
            if (!districtsMap.containsKey(districtKey)) {
              final districtItem = LocationItem(
                id: item['DistrictId'] as int?,
                name: districtName,
                blocks: [],
              );
              districtsMap[districtKey] = districtItem;

              // Add district to state
              statesMap[stateName]!.districts ??= [];
              statesMap[stateName]!.districts!.add(districtItem);
            }

            // Add block if not exists and block name is valid
            if (blockName != null && blockName.isNotEmpty) {
              final blockItem = LocationItem(
                id: item['BlockId'] as int?,
                name: blockName,
              );

              // Add block to district
              districtsMap[districtKey]!.blocks ??= [];
              districtsMap[districtKey]!.blocks!.add(blockItem);
            }
          }
        }
      }
    }

    locationData.states = statesMap.values.toList();
    locationData.message = apiResponse['message'] as String?;

    return locationData;
  }
}
