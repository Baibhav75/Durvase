import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/edit_employee_profile_response.dart';
import 'api_serviceProfile.dart';
import 'session_manager.dart';

class EditEmployeeProfileService {
  static const String baseUrl = 'https://durvasaayurved.online/api';

  /// Update / Edit Employee (MR) Profile via multipart form-data
  static Future<EditEmployeeProfileResponse> editEmployeeProfile({
    String? empId,
    String? employeeId,
    int? id,
    String? employeeCode,
    String? userId,
    String? password,
    String? joinDate,
    String? gender,
    String? name,
    String? fatherName,
    String? address,
    String? mobile,
    String? mobileAlt,
    String? email,
    String? postOffice,
    String? country,
    String? state,
    String? district,
    String? block,
    String? employeeType,
    String? emergenceNo,
    String? billedGroup,
    File? profileImageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/EditEmployeeProfile');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';

      // 1. Resolve EmpId and EmployeeId so they are always the same value
      final resolvedEmpId = (empId != null && empId.trim().isNotEmpty)
          ? empId.trim()
          : (employeeId != null && employeeId.trim().isNotEmpty)
              ? employeeId.trim()
              : (employeeCode != null && employeeCode.trim().isNotEmpty)
                  ? employeeCode.trim()
                  : (id != null ? id.toString() : '');

      request.fields['EmpId'] = resolvedEmpId;
      request.fields['EmployeeId'] = resolvedEmpId;

      if (id != null) {
        request.fields['Id'] = id.toString();
      }
      if (employeeCode != null && employeeCode.trim().isNotEmpty) {
        request.fields['EmployeeCode'] = employeeCode.trim();
      } else if (resolvedEmpId.isNotEmpty) {
        request.fields['EmployeeCode'] = resolvedEmpId;
      }

      if (userId != null && userId.trim().isNotEmpty) {
        request.fields['UserId'] = userId.trim();
      }
      if (password != null && password.trim().isNotEmpty) {
        request.fields['Password'] = password.trim();
      }
      if (joinDate != null && joinDate.trim().isNotEmpty) {
        request.fields['JoinDate'] = joinDate.trim();
      }
      if (gender != null && gender.trim().isNotEmpty) {
        request.fields['Gender'] = gender.trim();
      }

      if (name != null && name.trim().isNotEmpty) {
        request.fields['Name'] = name.trim();
        request.fields['FullName'] = name.trim();
      }
      if (fatherName != null) {
        request.fields['FatherName'] = fatherName.trim();
        request.fields['FathersName'] = fatherName.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        request.fields['Address'] = address.trim();
      }

      if (mobile != null && mobile.trim().isNotEmpty) {
        request.fields['Mobile'] = mobile.trim();
      }
      if (mobileAlt != null && mobileAlt.trim().isNotEmpty) {
        request.fields['MobileAlt'] = mobileAlt.trim();
      }
      if (email != null && email.trim().isNotEmpty) {
        request.fields['Email'] = email.trim();
      }

      if (postOffice != null && postOffice.trim().isNotEmpty) {
        request.fields['PostOffice'] = postOffice.trim();
      }
      if (country != null && country.trim().isNotEmpty) {
        request.fields['Country'] = country.trim();
      }
      if (state != null && state.trim().isNotEmpty) {
        request.fields['State'] = state.trim();
      }
      if (district != null && district.trim().isNotEmpty) {
        request.fields['District'] = district.trim();
      }
      if (block != null && block.trim().isNotEmpty) {
        request.fields['Block'] = block.trim();
      }
      if (employeeType != null && employeeType.trim().isNotEmpty) {
        request.fields['EmployeeType'] = employeeType.trim();
      }
      if (emergenceNo != null && emergenceNo.trim().isNotEmpty) {
        request.fields['EmergenceNo'] = emergenceNo.trim();
      }
      if (billedGroup != null && billedGroup.trim().isNotEmpty) {
        request.fields['BilledGroup'] = billedGroup.trim();
      }

      // Profile image file upload
      if (profileImageFile != null && await profileImageFile.exists()) {
        // Add as Image field (matching backend model property)
        request.files.add(
          await http.MultipartFile.fromPath(
            'Image',
            profileImageFile.path,
          ),
        );
      }

      debugPrint('📤 Sending EditEmployeeProfile request for EmpId: $empId');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 EditEmployeeProfile Response Status: ${response.statusCode}');
      debugPrint('📥 EditEmployeeProfile Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final result = EditEmployeeProfileResponse.fromJson(responseData);

        if (result.success) {
          // Clear profile cache so freshly updated data is loaded
          if (mobile != null && mobile.trim().isNotEmpty) {
            ApiService.clearProfileCache(mobile.trim());
          }

          // Update session login data if present
          try {
            final currentLoginData = await SessionManager.getLoginData();
            if (currentLoginData != null) {
              if (name != null && name.trim().isNotEmpty) {
                currentLoginData.name = name.trim();
              }
              if (email != null && email.trim().isNotEmpty) {
                currentLoginData.email = email.trim();
              }
              if (mobile != null && mobile.trim().isNotEmpty) {
                currentLoginData.mobile = mobile.trim();
              }
              await SessionManager.saveLoginData(currentLoginData);
            }
          } catch (e) {
            debugPrint('Notice: Session sync after profile edit: $e');
          }
        }

        return result;
      } else {
        String errorMsg = 'Server responded with status code ${response.statusCode}';
        try {
          final Map<String, dynamic> errData = jsonDecode(response.body);
          if (errData['message'] != null) {
            errorMsg = errData['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error updating MR employee profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
