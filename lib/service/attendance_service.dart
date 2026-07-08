// attendance_service.dart
import 'dart:convert';
import 'dart:async'; // This imports TimeoutException
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class AttendanceService {
  static const String baseUrl = 'https://durvasaayurved.com/api/attendance';

  static Future<Map<String, dynamic>> submitAttendance({
    required String employeeId,
    required String employeeName,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    required double checkInLatitude,
    required double checkInLongitude,
    required double checkOutLatitude,
    required double checkOutLongitude,
    required String locationName,
    required Duration workDuration,
    required File? checkInImage,
    required File? checkOutImage,
    String? checkInCityName,
    String? checkOutCityName,
    String? checkOutLocationName,
  }) async {
    try {
      print(
        '📤 Submitting attendance for employee: $employeeId ($employeeName)',
      );

      // Convert images to base64
      String? checkInImageBase64;
      String? checkOutImageBase64;

      if (checkInImage != null) {
        final bytes = await checkInImage.readAsBytes();
        checkInImageBase64 = base64Encode(bytes);
        print('📸 Check-in image converted to base64 (${bytes.length} bytes)');
      }

      if (checkOutImage != null) {
        final bytes = await checkOutImage.readAsBytes();
        checkOutImageBase64 = base64Encode(bytes);
        print('📸 Check-out image converted to base64 (${bytes.length} bytes)');
      }

      // Date formatting functions
      String formatDateTimeISO(DateTime dateTime) {
        return dateTime.toIso8601String();
      }

      String formatDateTimeSimple(DateTime dateTime) {
        return "${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}:${_padZero(dateTime.second)}";
      }

      String formatJustDate(DateTime dateTime) {
        return "${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}";
      }

      // Try combination 1: Complete data with separate locations and images
      Map<String, dynamic> attendanceData = {
        'employee_id': employeeId,
        'EmpId': employeeId,
        'employee_name': employeeName,
        'date': formatJustDate(checkInTime),
        'check_in_time': formatDateTimeSimple(checkInTime),
        'check_out_time': formatDateTimeSimple(checkOutTime),
        'check_in_latitude': checkInLatitude.toString(),
        'check_in_longitude': checkInLongitude.toString(),
        'check_out_latitude': checkOutLatitude.toString(),
        'check_out_longitude': checkOutLongitude.toString(),
        'work_duration': _formatDurationForAPI(workDuration),
        'location_name': locationName,
        'status': 'checked_out',
        'check_in_image_base64': checkInImageBase64 ?? "",
        'check_out_image_base64': checkOutImageBase64 ?? "",
        if (checkInCityName != null) 'check_in_city': checkInCityName,
        if (checkOutCityName != null) 'check_out_city': checkOutCityName,
        if (checkOutLocationName != null) 'check_out_location': checkOutLocationName,
        if (checkOutLocationName != null) 'CheckOutLocation': checkOutLocationName,
      };

      print('🔍 Trying field combination 1 (complete data)...');
      var result = await _makeApiCall(attendanceData);
      if (result['success'] == true) {
        // Save successful submission to prevent duplicates
        await _saveLastSubmission(employeeId, checkOutTime);
        return result;
      }

      // Try combination 2: Without separate location fields
      attendanceData = {
        'employee_id': employeeId,
        'EmpId': employeeId,
        'employee_name': employeeName,
        'date': formatJustDate(checkInTime),
        'check_in_time': formatDateTimeISO(checkInTime),
        'check_out_time': formatDateTimeISO(checkOutTime),
        'latitude': checkOutLatitude
            .toString(), // Use checkout location as primary
        'longitude': checkOutLongitude.toString(),
        'work_duration': _formatDurationForAPI(workDuration),
        'location_name': locationName,
        'status': 'checked_out',
        'image_base64':
        checkOutImageBase64 ??
            checkInImageBase64 ??
            "", // Prefer checkout image
        if (checkInCityName != null) 'check_in_city': checkInCityName,
        if (checkOutCityName != null) 'check_out_city': checkOutCityName,
        if (checkOutLocationName != null) 'check_out_location': checkOutLocationName,
        if (checkOutLocationName != null) 'CheckOutLocation': checkOutLocationName,
      };

      print('🔍 Trying field combination 2 (single location)...');
      result = await _makeApiCall(attendanceData);
      if (result['success'] == true) {
        await _saveLastSubmission(employeeId, checkOutTime);
        return result;
      }

      // Try combination 3: Different field naming convention
      attendanceData = {
        'EmployeeId': employeeId,
        'EmpId': employeeId,
        'EmployeeName': employeeName,
        'Date': formatJustDate(checkInTime),
        'CheckInTime': formatDateTimeISO(checkInTime),
        'CheckOutTime': formatDateTimeISO(checkOutTime),
        'CheckInLatitude': checkInLatitude,
        'CheckInLongitude': checkInLongitude,
        'CheckOutLatitude': checkOutLatitude,
        'CheckOutLongitude': checkOutLongitude,
        'WorkDuration': _formatDurationForAPI(workDuration),
        'LocationName': locationName,
        'Status': 'checked_out',
        'CheckInImage': checkInImageBase64 ?? "",
        'CheckOutImage': checkOutImageBase64 ?? "",
        if (checkInCityName != null) 'CheckInCity': checkInCityName,
        if (checkOutCityName != null) 'CheckOutCity': checkOutCityName,
        if (checkOutLocationName != null) 'CheckOutLocation': checkOutLocationName,
        if (checkOutLocationName != null) 'check_out_location': checkOutLocationName,
      };

      print('🔍 Trying field combination 3 (PascalCase)...');
      result = await _makeApiCall(attendanceData);
      if (result['success'] == true) {
        await _saveLastSubmission(employeeId, checkOutTime);
        return result;
      }

      // Try combination 4: Minimal required fields with checkout focus
      attendanceData = {
        'employee_id': employeeId,
        'EmpId': employeeId,
        'date': formatJustDate(checkInTime),
        'check_in_time': formatDateTimeSimple(checkInTime),
        'check_out_time': formatDateTimeSimple(checkOutTime),
        'latitude': checkOutLatitude.toString(),
        'longitude': checkOutLongitude.toString(),
        'image_base64': checkOutImageBase64 ?? "", // Only checkout image
        if (checkInCityName != null) 'check_in_city': checkInCityName,
        if (checkOutCityName != null) 'check_out_city': checkOutCityName,
        if (checkOutLocationName != null) 'check_out_location': checkOutLocationName,
        if (checkOutLocationName != null) 'CheckOutLocation': checkOutLocationName,
      };

      print('🔍 Trying field combination 4 (minimal with checkout focus)...');
      result = await _makeApiCall(attendanceData);

      if (result['success'] == true) {
        await _saveLastSubmission(employeeId, checkOutTime);
      }

      return result;
    } catch (e) {
      print('❌ API Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method for check-in only (if needed)
  static Future<Map<String, dynamic>> submitCheckIn({
    required String employeeId,
    required String employeeName,
    required DateTime checkInTime,
    required double latitude,
    required double longitude,
    required String locationName,
    required File? capturedImage,
  }) async {
    try {
      print('📤 Submitting check-in for employee: $employeeId ($employeeName)');
      
      String? imageBase64;
      if (capturedImage != null) {
        final bytes = await capturedImage.readAsBytes();
        imageBase64 = base64Encode(bytes);
        print('📸 Check-in image converted to base64 (${bytes.length} bytes)');
      }

      String formatDateTimeISO(DateTime dateTime) {
        return dateTime.toIso8601String();
      }

      String formatDateTimeSimple(DateTime dateTime) {
        return "${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)} ${_padZero(dateTime.hour)}:${_padZero(dateTime.minute)}:${_padZero(dateTime.second)}";
      }

      String formatJustDate(DateTime dateTime) {
        return "${dateTime.year}-${_padZero(dateTime.month)}-${_padZero(dateTime.day)}";
      }

      // Try combination 1: Complete data with explicit check_in fields
      Map<String, dynamic> checkInData = {
        'employee_id': employeeId,
        'EmpId': employeeId,
        'employee_name': employeeName,
        'date': formatJustDate(checkInTime),
        'check_in_time': formatDateTimeSimple(checkInTime),
        'check_in_latitude': latitude.toString(),
        'check_in_longitude': longitude.toString(),
        'location_name': locationName,
        'check_in_location': locationName,
        'status': 'checked_in',
        'check_in_image_base64': imageBase64 ?? "",
      };

      print('🔍 Trying field combination 1 for check-in...');
      var result = await _makeApiCall(checkInData);
      if (result['success'] == true) return result;

      // Try combination 2: General location fields
      checkInData = {
        'employee_id': employeeId,
        'EmpId': employeeId,
        'employee_name': employeeName,
        'date': formatJustDate(checkInTime),
        'check_in_time': formatDateTimeISO(checkInTime),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'location_name': locationName,
        'check_in_location': locationName,
        'status': 'checked_in',
        'image_base64': imageBase64 ?? "",
      };

      print('🔍 Trying field combination 2 for check-in...');
      result = await _makeApiCall(checkInData);
      if (result['success'] == true) return result;

      // Try combination 3: PascalCase naming convention
      checkInData = {
        'EmployeeId': employeeId,
        'EmpId': employeeId,
        'EmployeeName': employeeName,
        'Date': formatJustDate(checkInTime),
        'CheckInTime': formatDateTimeISO(checkInTime),
        'CheckInLatitude': latitude.toString(),
        'CheckInLongitude': longitude.toString(),
        'LocationName': locationName,
        'CheckInLocation': locationName,
        'Status': 'checked_in',
        'CheckInImage': imageBase64 ?? "",
      };

      print('🔍 Trying field combination 3 for check-in...');
      result = await _makeApiCall(checkInData);
      return result;
      
    } catch (e) {
      print('❌ Check-in API Error: $e');
      return {'success': false, 'message': 'Check-in failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> _makeApiCall(
      Map<String, dynamic> data,
      ) async {
    try {
      // Remove empty image fields to reduce payload size
      final cleanData = Map<String, dynamic>.from(data);
      if (cleanData['image_base64'] == "") cleanData.remove('image_base64');
      if (cleanData['check_in_image_base64'] == "")
        cleanData.remove('check_in_image_base64');
      if (cleanData['check_out_image_base64'] == "")
        cleanData.remove('check_out_image_base64');
      if (cleanData['CheckInImage'] == "") cleanData.remove('CheckInImage');
      if (cleanData['CheckOutImage'] == "") cleanData.remove('CheckOutImage');

      print('📡 Sending API request to: $baseUrl/add');
      print('📡 Data keys: ${cleanData.keys.join(', ')}');
      print(
        '📡 Has check-in image: ${cleanData.containsKey('check_in_image_base64') || cleanData.containsKey('CheckInImage')}',
      );
      print(
        '📡 Has check-out image: ${cleanData.containsKey('check_out_image_base64') || cleanData.containsKey('CheckOutImage')}',
      );
      print(
        '📡 Check-in location: ${cleanData['check_in_latitude'] ?? cleanData['CheckInLatitude'] ?? cleanData['latitude']}, ${cleanData['check_in_longitude'] ?? cleanData['CheckInLongitude'] ?? cleanData['longitude']}',
      );
      print(
        '📡 Check-out location: ${cleanData['check_out_latitude'] ?? cleanData['CheckOutLatitude'] ?? cleanData['latitude']}, ${cleanData['check_out_longitude'] ?? cleanData['CheckOutLongitude'] ?? cleanData['longitude']}',
      );

      final response = await http
          .post(
        Uri.parse('$baseUrl/add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(cleanData),
      )
          .timeout(const Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Handle different success response formats
        if (responseData is Map) {
          final message =
              responseData['message'] ??
                  responseData['Message'] ??
                  'Attendance submitted successfully';

          return {'success': true, 'message': message, 'data': responseData};
        } else {
          return {
            'success': true,
            'message': 'Attendance submitted successfully',
            'data': responseData,
          };
        }
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage =
            errorResponse['ExceptionMessage'] ??
                errorResponse['Message'] ??
                errorResponse['error'] ??
                'API request failed with status ${response.statusCode}';

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
          'errorDetails': errorResponse,
        };
      }
    } on http.ClientException catch (e) {
      print('❌ HTTP Client Exception: $e');
      return {'success': false, 'message': 'Network connection failed: $e'};
    } on SocketException catch (e) {
      print('❌ Socket Exception: $e');
      return {'success': false, 'message': 'Network unavailable: $e'};
    } on TimeoutException catch (e) {
      print('❌ Timeout Exception: $e');
      return {'success': false, 'message': 'Request timeout: $e'};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  static String _padZero(int number) => number.toString().padLeft(2, '0');

  static String _formatDurationForAPI(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${_padZero(hours)}:${_padZero(minutes)}:${_padZero(seconds)}';
  }

  // Method to get attendance history
  static Future<Map<String, dynamic>> getAttendanceHistory(
      String employeeId,
      ) async {
    try {
      final response = await http
          .get(
        Uri.parse('https://durvasaayurved.com/api/AttendanceHistory/History?EmpId=$employeeId'),
        headers: {'Accept': 'application/json'},
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch history: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error fetching history: $e'};
    }
  }

  // Save last successful submission to prevent duplicates
  static Future<void> _saveLastSubmission(
      String employeeId,
      DateTime checkOutTime,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_attendance_submission_$employeeId',
        checkOutTime.toIso8601String(),
      );
      print('✅ Saved last attendance submission for employee: $employeeId');
    } catch (e) {
      print('⚠️ Failed to save last submission timestamp: $e');
    }
  }

  // Check if attendance was recently submitted
  static Future<bool> wasRecentlySubmitted(String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSubmissionStr = prefs.getString(
        'last_attendance_submission_$employeeId',
      );

      if (lastSubmissionStr != null) {
        final lastSubmission = DateTime.parse(lastSubmissionStr);
        final now = DateTime.now();
        final difference = now.difference(lastSubmission);

        // If last submission was within the last 5 minutes, consider it recent
        return difference.inMinutes < 5;
      }

      return false;
    } catch (e) {
      print('⚠️ Error checking recent submission: $e');
      return false;
    }
  }
}
