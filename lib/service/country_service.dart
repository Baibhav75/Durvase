import 'dart:convert';

import 'package:http/http.dart' as http;

import '/service/Api_constants.dart';
import '../model/country_model.dart';

class CountryService {
  /// Fetch all countries from API
  Future<List<CountryModel>> getAllCountries() async {
    try {
      final uri = Uri.parse(ApiConstants.getAllCountry);

      print('🌍 Country API URL: $uri');

      final response = await http.get(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🌍 Country API Status: ${response.statusCode}');
      print('🌍 Country API Response: ${response.body}');

      // Check HTTP status
      if (response.statusCode != 200) {
        throw Exception(
          'Server Error: ${response.statusCode}',
        );
      }

      // Sanitize response before decoding
      final sanitizedBody = _sanitizeJson(response.body);

      if (sanitizedBody.isEmpty) {
        throw Exception('Empty response received from server');
      }

      final dynamic decoded = jsonDecode(sanitizedBody);

      // API response is an object
      if (decoded is Map<String, dynamic>) {
        final countryResponse = CountryResponse.fromMap(decoded);

        // Check API-level success
        if (countryResponse.header != null &&
            countryResponse.header!.success == false) {
          throw Exception(
            countryResponse.header!.message ??
                'Failed to fetch countries',
          );
        }

        return countryResponse.data;
      }

      // API response is directly a list
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) => CountryModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      // Unexpected response format
      throw Exception(
        'Invalid country API response format',
      );
    } on FormatException catch (e) {
      print('❌ Country JSON Error: $e');

      throw Exception(
        'Invalid JSON response received from country API',
      );
    } catch (e) {
      print('❌ Country API Error: $e');

      throw Exception(
        'Failed to fetch countries: $e',
      );
    }
  }

  /// Sanitizes invalid JSON returned by backend.
  ///
  /// Handles cases such as:
  /// "CountryId": ,
  /// "CountryName": ,
  /// and trailing commas before } or ].
  String _sanitizeJson(String rawJson) {
    String sanitized = rawJson.trim();

    // 1. Replace empty JSON values with null.
    //
    // Example:
    // "CountryId": ,
    // becomes:
    // "CountryId": null
    sanitized = sanitized.replaceAllMapped(
      RegExp(r':\s*(?=[,\}\]])'),
          (match) => ': null',
    );

    sanitized = sanitized.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
          (match) => match.group(1) ?? '',
    );

    return sanitized;
  }
}