import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DealerEditProfileService {
  static const String _baseUrl =
      'https://durvasaayurved.com/api/editdealerprofile';

  static Future<Map<String, dynamic>> updateProfile({
    required String dealerId,
    required String empType,
    required String empMobile,
    required String visitFor,
    required String country,
    required String state,
    required String district,
    required String block,
    required String businessName,
    required String personName,
    required String mobile,
    required String address,
    required String purpose,
    required String reVisited,
    required String visitDate,
    required String remark,
    required String empName,
    required String revisitDate,
    required String password,
    required String employeeId,
    File? imageFile, required Password,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_baseUrl),
      );

      // Dealer Details
      request.fields['DealerID'] = dealerId;
      request.fields['Emp_Type'] = empType;
      request.fields['Emp_Mobile'] = empMobile;

      // Visit Details
      request.fields['Visit_for'] = visitFor;
      request.fields['Country'] = country;
      request.fields['State'] = state;
      request.fields['District'] = district;
      request.fields['Block'] = block;

      // Business Details
      request.fields['Business_Name'] = businessName;
      request.fields['Person_Name'] = personName;
      request.fields['Mobile'] = mobile;
      request.fields['Address'] = address;

      // Purpose / Visit Status
      request.fields['Purpose'] = purpose;
      request.fields['Re_visited'] = reVisited;
      request.fields['VisitDate'] = visitDate;
      request.fields['Remark'] = remark;
      request.fields['Emp_Name'] = empName;
      request.fields['RevisitDate'] = revisitDate;

      // Login / Employee Details
      request.fields['Password'] = password;
      request.fields['EmployeeId'] = employeeId;

      // Profile image if selected
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Profile',
            imageFile.path,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message':
          'Update failed. Try again. (${response.statusCode})',
        };
      }

      final decoded = jsonDecode(response.body);

      final isSuccess =
          decoded['status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message': decoded['message']?.toString() ??
            (isSuccess
                ? 'Profile updated successfully!'
                : 'Update failed. Try again.'),
      };
    } catch (e) {
      print("Update Profile Error: $e");

      return {
        'success': false,
        'message': 'Something went wrong. Try again.',
      };
    }
  }
}