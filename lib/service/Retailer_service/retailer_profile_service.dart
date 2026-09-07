import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../model/Retailer_model/edit_retailer_model.dart';
import '../../model/Retailer_model/retailer_profile_model.dart';
import '../../model/Retailer_model/retailer_team_model.dart';
import '../../model/Retailer_model/asm_list_model.dart';
import '../Api_constants.dart';

class RetailerProfileService {
  /// Fetch Visiter / Retailer Profile by Visiter ID
  static Future<RetailerProfileResponse> getRetailerProfile(String visiterId) async {
    final cleanId = visiterId.trim();
    final candidateUrls = [
      'https://durvasaayurved.com/api/visiterprofile?visiterID=$cleanId',
      'https://durvasaayurved.com/api/visiterprofile?visiterId=$cleanId',
      '${ApiConstants.baseUrl}/api/visiterprofile?visiterID=$cleanId',
      'https://durvasaayurved.com/api/retailerprofile?retailerID=$cleanId',
      '${ApiConstants.baseUrl}/api/retailerprofile?retailerID=$cleanId',
    ];

    http.Response? lastResponse;

    for (final url in candidateUrls.toSet()) {
      try {
        final uri = Uri.parse(url);
        debugPrint('📤 Fetching Visiter Profile from URL: $uri');

        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 12));

        debugPrint('📥 Status: ${response.statusCode} from $url');
        debugPrint('📥 Response: ${response.body}');

        lastResponse = response;

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final profileResponse = RetailerProfileResponse.fromJson(decoded);
            if (profileResponse.data != null) {
              return profileResponse;
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching profile from $url: $e');
      }
    }

    if (lastResponse != null && lastResponse.statusCode == 200) {
      try {
        final decoded = jsonDecode(lastResponse.body);
        if (decoded is Map<String, dynamic>) {
          return RetailerProfileResponse.fromJson(decoded);
        }
      } catch (_) {}
    }

    throw Exception(
      'Failed to fetch retailer profile (${lastResponse?.statusCode ?? "Connection error"}).',
    );
  }


  /// Update / Edit Retailer Profile
  static Future<EditRetailerResponse> editRetailerProfile(EditRetailerModel model) async {
    final candidateUrls = [
      ApiConstants.editRetailerProfile,
      '${ApiConstants.baseUrl}/api/EditRetailerProfile',
      '${ApiConstants.baseUrl}/api/editretailerprofile',
      '${ApiConstants.baseUrl}/api/editretailersprofile',
      'https://durvasaayurved.com/api/editretailerprofile',
      'https://durvasaayurved.com/api/EditRetailerProfile',
    ];

    final payload = jsonEncode(model.toJson());
    debugPrint('📤 Edit Retailer Profile Payload: $payload');

    http.Response? lastResponse;

    for (final url in candidateUrls.toSet()) {
      try {
        final uri = Uri.parse(url);
        debugPrint('📤 Trying Edit Retailer Profile URL: $uri');

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: payload,
        );

        debugPrint('📥 Status: ${response.statusCode} from $url');
        debugPrint('📥 Response: ${response.body}');

        lastResponse = response;

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return EditRetailerResponse.fromJson(decoded);
          }
          return EditRetailerResponse(
            status: 'Success',
            message: 'Profile updated successfully',
          );
        }

        // If not 404 (e.g. 400 validation error), do not keep retrying other URLs
        if (response.statusCode != 404) {
          try {
            final decoded = jsonDecode(response.body);
            if (decoded is Map<String, dynamic>) {
              return EditRetailerResponse.fromJson(decoded);
            }
          } catch (_) {}
          break;
        }
      } catch (e) {
        debugPrint('⚠️ Error trying $url: $e');
      }
    }

    if (lastResponse != null) {
      try {
        final decoded = jsonDecode(lastResponse.body);
        final msg = decoded['Message'] ?? decoded['message'] ?? lastResponse.body;
        throw Exception(msg);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to update retailer profile (${lastResponse.statusCode})');
      }
    }

    throw Exception('Unable to reach server. Please check your network connection.');
  }

  /// Fetch All Retailers from API
  static Future<GetAllRetailerResponse> getAllRetailers() async {
    final candidateUrls = [
      ApiConstants.getAllRetailer,
      '${ApiConstants.baseUrl}/api/GetAllRetailer',
      '${ApiConstants.baseUrl}/api/getallretailer',
      'https://durvasaayurved.com/api/GetAllRetailer',
      'https://durvasaayurved.com/api/getallretailer',
    ];

    for (final url in candidateUrls.toSet()) {
      try {
        final uri = Uri.parse(url);
        debugPrint('📤 Fetching All Retailers from URL: $uri');

        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        debugPrint('📥 Status: ${response.statusCode} from $url');

        if (response.statusCode == 200) {
          final decoded = _sanitizeAndDecodeJson(response.body);
          if (decoded is Map<String, dynamic>) {
            return GetAllRetailerResponse.fromJson(decoded);
          } else if (decoded is List) {
            return GetAllRetailerResponse(
              header: RetailerHeader(success: true, totalCount: decoded.length),
              data: decoded.map((e) => RetailerItem.fromJson(e as Map<String, dynamic>)).toList(),
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching retailers from $url: $e');
      }
    }

    throw Exception('Failed to load retailers list from server.');
  }

  /// Fetch All ASM List from API (https://durvasaayurved.com/api/ASMlist)
  static Future<AsmListResponse> getAsmList() async {
    final candidateUrls = [
      ApiConstants.getAsmList,
      '${ApiConstants.baseUrl}/api/ASMlist',
      '${ApiConstants.baseUrl}/api/asmlist',
      'https://durvasaayurved.com/api/ASMlist',
      'https://durvasaayurved.com/api/asmlist',
    ];

    for (final url in candidateUrls.toSet()) {
      try {
        final uri = Uri.parse(url);
        debugPrint('📤 Fetching All ASM from URL: $uri');

        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        debugPrint('📥 ASM API Status: ${response.statusCode} from $url');
        debugPrint('📥 ASM API Raw Body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = _sanitizeAndDecodeJson(response.body);
          if (decoded is Map<String, dynamic>) {
            return AsmListResponse.fromJson(decoded);
          } else if (decoded is List) {
            return AsmListResponse(
              header: AsmHeader(success: true, totalCount: decoded.length),
              data: decoded.whereType<Map<String, dynamic>>().map((e) => AsmItem.fromJson(e)).toList(),
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching ASM list from $url: $e');
      }
    }

    throw Exception('Failed to load ASM team list from server.');
  }

  /// Robust JSON sanitizer that fixes empty values like `"Id": ,` sent by server
  static dynamic _sanitizeAndDecodeJson(String rawBody) {
    try {
      return jsonDecode(rawBody);
    } catch (_) {
      try {
        // Fix missing values after colon: "key": , -> "key": null,
        String sanitized = rawBody.replaceAll(RegExp(r':\s*,'), ': null,');
        // Fix trailing empty key-values: "key": \n -> "key": null\n or "key": } -> "key": null}
        sanitized = sanitized.replaceAllMapped(
          RegExp(r':\s*(\r?\n|\r|\})'),
          (match) => ': null${match.group(1)}',
        );

        return jsonDecode(sanitized);
      } catch (e) {
        // Direct fallback: extract only the "data" array if Header is completely malformed
        final dataMatch = RegExp(r'"data"\s*:\s*(\[\s*\{.*?\}\s*\])', dotAll: true).firstMatch(rawBody);
        if (dataMatch != null && dataMatch.group(1) != null) {
          try {
            final dataList = jsonDecode(dataMatch.group(1)!);
            return {'Header': {'success': true}, 'data': dataList};
          } catch (_) {}
        }
        rethrow;
      }
    }
  }
}
