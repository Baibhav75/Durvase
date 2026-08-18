import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/Api_constants.dart';
import '../model/district_model.dart';

class DistrictService {
  Future<List<DistrictModel>> getDistrictsByStateId(int stateId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.getAllDistrict}?stateId=$stateId',
      );

      print('🌍 District API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🌍 District API Status: ${response.statusCode}');
      print('🌍 District API Response: ${response.body}');

      if (response.statusCode == 200) {
        final sanitizedBody = _sanitizeJson(response.body);
        final dynamic decoded = jsonDecode(sanitizedBody);

        if (decoded is Map<String, dynamic>) {
          final districtResponse = DistrictResponse.fromMap(decoded);

          if (districtResponse.header != null &&
              districtResponse.header!.success == false) {
            throw Exception(
              districtResponse.header!.message ?? 'Failed to fetch districts',
            );
          }

          return districtResponse.data;
        } else if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (item) => DistrictModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }

        return [];
      }

      throw Exception(
        'Server Error: ${response.statusCode}',
      );
    } catch (e) {
      print('❌ District API Error: $e');

      throw Exception(
        'Failed to fetch districts: $e',
      );
    }
  }

  /// Sanitizes invalid JSON returned by backend (e.g. `"DistrictId": ,` or trailing commas)
  String _sanitizeJson(String rawJson) {
    String sanitized = rawJson.trim();

    // 1. Replace empty value patterns like `"DistrictId": ,` or `"key": }` with null
    sanitized = sanitized.replaceAllMapped(
      RegExp(r':\s*(?=[,\}\]])'),
      (match) => ': null',
    );

    // 2. Remove trailing commas before closing braces/brackets like `, }` or `, ]`
    sanitized = sanitized.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1) ?? '',
    );

    return sanitized;
  }
}
