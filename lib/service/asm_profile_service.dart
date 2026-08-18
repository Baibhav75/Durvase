import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/asm_profile_model.dart';

class AsmProfileService {
  static const String baseUrl = 'https://durvasaayurved.online/api';

  /// Fetch ASM Profile details
  static Future<AsmProfileModel> getAsmProfile(int asmId) async {
    final uri = Uri.parse('$baseUrl/ASMProfile?ASMId=$asmId');

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch ASM profile (${response.statusCode})',
        );
      }

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] != true) {
        throw Exception(
          responseData['message']?.toString() ?? 'Unable to fetch ASM profile',
        );
      }

      final data = responseData['data'];

      if (data == null || data is! Map<String, dynamic>) {
        throw Exception('ASM profile data is empty or invalid');
      }

      return AsmProfileModel.fromMap(data);
    } catch (e) {
      debugPrint('ASM Profile Fetch Error: $e');
      throw Exception('ASM Profile API Error: $e');
    }
  }

  /// Update / Edit ASM Profile via multipart form-data
  static Future<Map<String, dynamic>> editAsmProfile({
    required int asmId,
    required String name,
    required String mobile,
    String? password,
    required String email,
    String? region,
    String? area,
    String? fathersName,
    String? address,
    String? emergenceNo,
    String? billedGroup,
    File? profileImageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/EditASMProfile');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';

      // Required and optional fields matching Postman body spec
      request.fields['AsmId'] = asmId.toString();
      request.fields['Name'] = name.trim();
      request.fields['FullName'] = name.trim();
      request.fields['Mobile'] = mobile.trim();
      if (password != null && password.trim().isNotEmpty) {
        request.fields['Password'] = password.trim();
      }
      request.fields['Email'] = email.trim();
      request.fields['Region'] = (region ?? '').trim();
      request.fields['Area'] = (area ?? '').trim();
      request.fields['FathersName'] = (fathersName ?? '').trim();
      request.fields['FatherName'] = (fathersName ?? '').trim();
      request.fields['Address'] = (address ?? '').trim();
      if (emergenceNo != null && emergenceNo.trim().isNotEmpty) {
        request.fields['EmergenceNo'] = emergenceNo.trim();
      }
      if (billedGroup != null && billedGroup.trim().isNotEmpty) {
        request.fields['BilledGroup'] = billedGroup.trim();
      }

      // Profile image file upload
      if (profileImageFile != null && await profileImageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'ProfileImage',
            profileImageFile.path,
          ),
        );
      }

      debugPrint('📤 Sending EditASMProfile request for AsmId: $asmId');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 EditASMProfile Response Status: ${response.statusCode}');
      debugPrint('📥 EditASMProfile Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Server responded with status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error updating ASM profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
