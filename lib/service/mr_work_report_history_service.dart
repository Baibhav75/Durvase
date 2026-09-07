// service/mr_work_report_history_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/mr_work_report_history_model.dart';
import 'session_manager.dart';

class MRWorkReportHistoryService {
  static const String baseUrl = 'https://durvasaayurved.com/api';
  static const int timeoutSeconds = 30;

  /// Fetch MR Work Report History for a given employee ID.
  /// If [empId] is not provided or empty, retrieves it automatically from [SessionManager].
  static Future<MRWorkReportHistoryModel> getWorkReportHistory([String? empId]) async {
    try {
      String resolvedEmpId = (empId != null && empId.trim().isNotEmpty) ? empId.trim() : '';

      if (resolvedEmpId.isEmpty) {
        resolvedEmpId = await SessionManager.getEmpId() ?? '';
      }

      if (resolvedEmpId.isEmpty) {
        final loginData = await SessionManager.getLoginData();
        resolvedEmpId = loginData?.empId ?? loginData?.asmId ?? '';
      }

      if (resolvedEmpId.isEmpty) {
        throw Exception('Employee ID not found in session. Please login again.');
      }

      final uri = Uri.parse('$baseUrl/MRWorkReportHistory?empId=$resolvedEmpId');
      debugPrint('📤 Fetching MR Work Report History from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      debugPrint('📥 Response Status [MRWorkReportHistory]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return MRWorkReportHistoryModel.fromJson(decoded);
        } else if (decoded is List) {
          return MRWorkReportHistoryModel.fromJson({
            'Header': {
              'success': true,
              'totalCount': decoded.length,
              'EmpId': resolvedEmpId,
            },
            'data': decoded,
          });
        } else {
          throw Exception('Invalid data format received from server.');
        }
      } else {
        throw Exception('Failed to load work report history (Status: ${response.statusCode}).');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in MRWorkReportHistoryService: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
