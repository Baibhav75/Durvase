// service/visitor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class VisitorService {
  static const String baseUrl = 'https://durvasaayurved.online/api';
  static const int timeoutSeconds = 30;

  // Method to submit visitor data
  static Future<Map<String, dynamic>> submitVisitorData({
    required String empType,
    required String empMobile,
    required String empName,
    required String empId,
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
    required String remark,
    String? photoBase64,
    String? reVisitDate,
  }) async {
    try {
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        "Emp_Type": empType,
        "Emp_Mobile": empMobile,
        "Emp_Name": empName,
        "Emp_Id": empId,
        "Visit_for": visitFor,
        "Country": country,
        "State": state,
        "District": district,
        "Block": block,
        "Business_Name": businessName,
        "Person_Name": personName,
        "Mobile": mobile,
        "Address": address,
        "Purpose": purpose,
        "Re_visited": reVisited,
        "Remark": remark,
        "PhotoBase64": photoBase64 ?? "",
      };

      if (reVisitDate != null) {
        requestBody["RevisitDate"] = reVisitDate;
      }

      print('📤 Sending visitor data to API...');
      print('   -> RevisitDate being sent: $reVisitDate');
      // Truncate photo for clean logging
      final logBody = Map<String, dynamic>.from(requestBody);
      if (logBody["PhotoBase64"] != "") logBody["PhotoBase64"] = "[BASE64_IMAGE]";
      print('Request Body: ${json.encode(logBody)}');

      final response = await http
          .post(
        Uri.parse('$baseUrl/visitor/add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('✅ API Response Status: ${response.statusCode}');
      print('📥 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the API returned success in its response
        // The API returns status: "Success" for success, "Duplicate" for duplicate mobile, etc.
        final String? status = responseData['status']?.toString();
        final String? message = responseData['message']?.toString();

        final bool isSuccess = status?.toLowerCase() == 'success' ||
            (message?.toLowerCase().contains('success') ?? false);

        return {
          'success': isSuccess,
          'message':
          responseData['message']?.toString() ??
              (isSuccess
                  ? 'Visit submitted successfully!'
                  : 'Visit submission completed.'),
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Client error
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message':
          errorData['message']?.toString() ??
              'Invalid request. Please check your data.',
          'error': errorData,
          'statusCode': response.statusCode,
        };
      } else {
        // Server error
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
          'statusCode': response.statusCode,
        };
      }
    } on http.ClientException catch (e) {
      print('❌ HTTP Client Exception: $e');
      return {
        'success': false,
        'message': 'Network connection failed. Please check your internet.',
        'error': e.toString(),
      };
    } on FormatException catch (e) {
      print('❌ JSON Format Exception: $e');
      return {
        'success': false,
        'message': 'Data format error. Please try again.',
        'error': e.toString(),
      };
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    }
  }

  // Method to get visitor list (for completeness)
  static Future<Map<String, dynamic>> getVisitorList(String empMobile) async {
    try {
      print('📤 Fetching visitor list for: $empMobile');

      final response = await http
          .get(
        Uri.parse('$baseUrl/VisitorList?Emp_mobile=$empMobile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      print('✅ Visitor List API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['Message'] ?? 'Data loaded successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load visitor list: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error fetching visitor list: $e');
      return {'success': false, 'message': 'Failed to load visitor list: $e'};
    }
  }
}
