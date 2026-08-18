import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/Asmattendance_history_model.dart';

class AttendanceHistoryService {
  static const String baseUrl =
      'https://durvasaayurved.online/api';

  Future<List<AttendanceHistoryModel>> getAttendanceHistory(
    String empId,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/GetASMAttendance?EmpId=${Uri.encodeComponent(empId.trim())}',
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];

          return data
              .map(
                (item) => AttendanceHistoryModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }

        // If success is false but message says no records found, return empty list
        final msg = (responseData['message'] ?? '').toString().toLowerCase();
        if (msg.contains('no attendance') || msg.contains('not found') || msg.contains('no record')) {
          return [];
        }

        throw Exception(
          responseData['message'] ?? 'Failed to fetch attendance',
        );
      } else if (response.statusCode == 404) {
        // Backend returns 404 with JSON when employee has no attendance punches yet
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final msg = (responseData['message'] ?? '').toString().toLowerCase();
          if (responseData['success'] == false ||
              msg.contains('no attendance') ||
              msg.contains('not found') ||
              msg.contains('no record')) {
            return [];
          }
        } catch (_) {
          return [];
        }
        return [];
      }

      throw Exception(
        'Server Error: ${response.statusCode}',
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains('no attendance') ||
          e.toString().toLowerCase().contains('not found')) {
        return [];
      }
      throw Exception(
        'Failed to fetch attendance history: $e',
      );
    }
  }
}