import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class VisitorService {
  static const String baseUrl = 'https://durvasaayurved.com/api';
  static const int timeoutSeconds = 30;

  // Submit visitor data as multipart/form-data
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

    // Password and Visit Date
    required String password,
    required String visitDate,

    File? imageFile,
    String? photoBase64,
    String? photo,
    String? reVisitDate,
    String? visiterId,
    String? employeeId,
    String? message,
  }) async {
    try {
      final resolvedEmployeeId =
      (employeeId != null && employeeId.trim().isNotEmpty)
          ? employeeId.trim()
          : empId.trim();

      final uri = Uri.parse('$baseUrl/visitor/add');

      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';

      // =========================
      // BASIC EMPLOYEE INFORMATION
      // =========================

      request.fields['Emp_Name'] = empName;
      request.fields['Emp_Type'] = empType;
      request.fields['Emp_Mobile'] = empMobile;
      request.fields['Emp_Id'] = empId;
      request.fields['EmployeeId'] = resolvedEmployeeId;

      // =========================
      // VISIT INFORMATION
      // =========================

      request.fields['Visit_for'] = visitFor;
      request.fields['VisitDate'] = visitDate;
      request.fields['Password'] = password;

      // =========================
      // LOCATION
      // =========================

      request.fields['Country'] = country;
      request.fields['State'] = state;
      request.fields['District'] = district;
      request.fields['Block'] = block;

      // =========================
      // BUSINESS / PERSON
      // =========================

      request.fields['Business_Name'] = businessName;
      request.fields['Person_Name'] = personName;
      request.fields['Mobile'] = mobile;
      request.fields['Address'] = address;
      request.fields['Purpose'] = purpose;

      // =========================
      // RE-VISIT
      // =========================

      request.fields['Re_visited'] = reVisited;

      if (reVisitDate != null && reVisitDate.trim().isNotEmpty) {
        request.fields['RevisitDate'] = reVisitDate;
      }

      // =========================
      // REMARK
      // =========================

      request.fields['Remark'] = remark;

      // =========================
      // OPTIONAL VISITOR DATA
      // =========================

      request.fields['VisiterId'] = visiterId ?? "";
      request.fields['Photo'] = photo ?? "";
      request.fields['PhotoBase64'] = photoBase64 ?? "";

      if (message != null && message.trim().isNotEmpty) {
        request.fields['message'] = message;
      }

      // =========================
      // IMAGE FILE
      // =========================

      if (imageFile != null && await imageFile.exists()) {
        final multipartFile = await http.MultipartFile.fromPath(
          'Photo',
          imageFile.path,
        );

        request.files.add(multipartFile);
      }

      // =========================
      // DEBUG LOG
      // =========================

      print('📤 Sending visitor data');
      print('➡️ URL: $uri');
      print('➡️ Fields: ${request.fields}');
      print('➡️ Files: ${request.files.length}');

      // =========================
      // API REQUEST
      // =========================

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: timeoutSeconds),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('✅ API Status: ${response.statusCode}');
      print('📥 API Response: ${response.body}');

      // =========================
      // SUCCESS
      // =========================

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData;

        try {
          responseData = json.decode(response.body);
        } catch (_) {
          responseData = {'message': response.body};
        }

        final String? status = responseData is Map
            ? responseData['status']?.toString()
            : null;

        final String? responseMessage = responseData is Map
            ? (responseData['message']?.toString() ??
            responseData['Message']?.toString())
            : response.body;

        final bool isSuccess =
            status?.toLowerCase() == 'success' ||
                (responseMessage?.toLowerCase().contains('success') ?? false) ||
                response.statusCode == 200;

        return {
          'success': isSuccess,
          'message': responseMessage ?? 'Visit submitted successfully!',
          'data': responseData,
          'statusCode': response.statusCode,
        };
      }

      // =========================
      // CLIENT ERROR
      // =========================

      if (response.statusCode >= 400 && response.statusCode < 500) {
        try {
          final errorData = json.decode(response.body);

          return {
            'success': false,
            'message':
            errorData['message']?.toString() ??
                errorData['Message']?.toString() ??
                'Invalid request (${response.statusCode}).',
            'error': errorData,
            'statusCode': response.statusCode,
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Error (${response.statusCode}): ${response.body}',
            'statusCode': response.statusCode,
          };
        }
      }

      // =========================
      // SERVER ERROR
      // =========================

      return {
        'success': false,
        'message':
        'Server error (${response.statusCode}). Please try again later.',
        'statusCode': response.statusCode,
      };
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

  // =========================
  // GET VISITOR LIST
  // =========================

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
      }

      return {
        'success': false,
        'message': 'Failed to load visitor list: ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('❌ Error fetching visitor list: $e');

      return {'success': false, 'message': 'Failed to load visitor list: $e'};
    }
  }
}
