import 'dart:convert';
import 'package:http/http.dart' as http;
import '/service/Api_constants.dart';
import '../model/block_model.dart';

class BlockService {
  Future<List<BlockModel>> getBlocksByDistrictId(int districtId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.getAllBlock}?districtId=$districtId',
      );

      print('🌍 Block API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🌍 Block API Status: ${response.statusCode}');
      print('🌍 Block API Response: ${response.body}');

      if (response.statusCode == 200) {
        final sanitizedBody = _sanitizeJson(response.body);
        final dynamic decoded = jsonDecode(sanitizedBody);

        if (decoded is Map<String, dynamic>) {
          final blockResponse = BlockResponse.fromMap(decoded);

          if (blockResponse.header != null &&
              blockResponse.header!.success == false) {
            throw Exception(
              blockResponse.header!.message ?? 'Failed to fetch blocks',
            );
          }

          return blockResponse.data;
        } else if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (item) => BlockModel.fromMap(
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
      print('❌ Block API Error: $e');

      throw Exception(
        'Failed to fetch blocks: $e',
      );
    }
  }

  /// Sanitizes invalid JSON returned by backend (e.g. `"BlockId": ,` or trailing commas)
  String _sanitizeJson(String rawJson) {
    String sanitized = rawJson.trim();

    // 1. Replace empty value patterns like `"BlockId": ,` or `"key": }` with null
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
