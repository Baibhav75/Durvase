import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/Api_constants.dart';
import '../model/country_model.dart';

class CountryService {
  Future<List<CountryModel>> getAllCountries() async {
    try {
      final uri = Uri.parse(
        ApiConstants.getAllCountry,
      );

      print('🌍 Country API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🌍 Country API Status: ${response.statusCode}');
      print('🌍 Country API Response: ${response.body}');

      if (response.statusCode == 200) {
        final sanitizedBody = _sanitizeJson(response.body);
        final dynamic decoded = jsonDecode(sanitizedBody);

        if (decoded is Map<String, dynamic>) {
          final countryResponse = CountryResponse.fromMap(decoded);

          if (countryResponse.header != null &&
              countryResponse.header!.success == false) {
            throw Exception(
              countryResponse.header!.message ?? 'Failed to fetch countries',
            );
          }

          return countryResponse.data;
        } else if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (item) => CountryModel.fromMap(
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
      print('❌ Country API Error: $e');

      throw Exception(
        'Failed to fetch countries: $e',
      );
    }
  }

  /// Sanitizes invalid JSON returned by backend (e.g. `"CountryId": ,` or trailing commas)
  String _sanitizeJson(String rawJson) {
    String sanitized = rawJson.trim();

    // 1. Replace empty value patterns like `"CountryId": ,` or `"key": }` with null
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