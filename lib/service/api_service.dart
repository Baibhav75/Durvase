import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/amr_assine_field_model.dart';
import '../model/my_order_modelplace.dart';
import '/model/asm_work_report_model.dart';
import '../model/mr_work_report_model.dart';
import 'Api_constants.dart';
import '../model/Retailer_model/retailer_profile_model.dart';
import '../model/Retailer_model/edit_retailer_model.dart';
import '../model/Retailer_model/asm_list_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../model/user_address_model.dart';

class ApiService {
  // Get ASM List
  static Future<AsmListResponse> getASMList() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getAsmList),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String rawBody = response.body;
        // Fix trailing empty key-values
        String sanitized = rawBody.replaceAll(RegExp(r':\s*,'), ': null,');
        sanitized = sanitized.replaceAllMapped(
          RegExp(r':\s*(\r?\n|\r|\})'),
          (match) => ': null${match.group(1)}',
        );

        final decoded = jsonDecode(sanitized);
        if (decoded is Map<String, dynamic>) {
          return AsmListResponse.fromJson(decoded);
        } else if (decoded is List) {
          return AsmListResponse(
            header: AsmHeader(success: true, totalCount: decoded.length),
            data: decoded.whereType<Map<String, dynamic>>().map((e) => AsmItem.fromJson(e)).toList(),
          );
        }
      }
      throw Exception('Failed to load ASM list (Status: ${response.statusCode})');
    } catch (e) {
      throw Exception('Error loading ASM list: $e');
    }
  }
  // Employee Login API
  static Future<Map<String, dynamic>> loginEmployee(
      String mobile,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/Login/Get'
              '?mobile=$mobile&password=$password',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to login. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ASM Login API
  static Future<Map<String, dynamic>> loginAsm(
      String mobile,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/asmlogin'
              '?mobile=$mobile&password=$password',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to login ASM. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get ASM Assigned Districts
  static Future<AmrAssineFieldResponse> getASM(
      String empId,
      ) async {
    try {
      final uri = Uri.parse(
        ApiConstants.getASM,
      ).replace(
        queryParameters: {
          'EmpId': empId,
        },
      );

      print('ASM API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('ASM API Status: ${response.statusCode}');
      print('ASM API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
        jsonDecode(response.body);

        return AmrAssineFieldResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to fetch ASM data. '
              'Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('ASM API Error: $e');

      throw Exception(
        'Failed to fetch ASM data: $e',
      );
    }
  }
  Future<bool> submitWorkReport(
      ASMWorkReportModel report,
      ) async {
    try {
      final url = Uri.parse(
        ApiConstants.submitASMWorkReport,
      );

      final requestBody = report.toJson();

      debugPrint('========================================');
      debugPrint('📤 ASM WORK REPORT API');
      debugPrint('METHOD: POST');
      debugPrint('URL: $url');
      debugPrint('BODY: ${jsonEncode(requestBody)}');
      debugPrint('========================================');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('📥 STATUS CODE: ${response.statusCode}');
      debugPrint('📥 RESPONSE: ${response.body}');
      debugPrint('========================================');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        debugPrint('✅ ASM Work Report Submitted Successfully');
        return true;
      }

      throw Exception(
        'Server Error: ${response.statusCode}\n'
            '${response.body}',
      );
    } catch (e) {
      debugPrint('❌ ASM Work Report Error: $e');
      rethrow;
    }
  }

  // ============================================================
  // MR Work Report Submit API
  // ============================================================
  Future<bool> submitMRWorkReport(
    MRWorkReportModel report,
  ) async {
    try {
      final url = Uri.parse(
        ApiConstants.submitMRWorkReport,
      );

      final requestBody = report.toJson();

      debugPrint('========================================');
      debugPrint('📤 MR WORK REPORT API');
      debugPrint('METHOD: POST');
      debugPrint('URL: $url');
      debugPrint('BODY: ${jsonEncode(requestBody)}');
      debugPrint('========================================');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('📥 STATUS CODE: ${response.statusCode}');
      debugPrint('📥 RESPONSE: ${response.body}');
      debugPrint('========================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ MR Work Report Submitted Successfully');
        return true;
      }

      throw Exception(
        'Server Error: ${response.statusCode}\n${response.body}',
      );
    } catch (e) {
      debugPrint('❌ MR Work Report Error: $e');
      rethrow;
    }
  }
  // Get Retailer Profile
  static Future<RetailerProfileResponse> getRetailerProfile(
      String visiterID,
      ) async {
    try {
      final cleanId = visiterID.trim();
      final uri = Uri.parse(
        'https://durvasaayurved.com/api/visiterprofile',
      ).replace(
        queryParameters: {
          'visiterID': cleanId,
        },
      );

      debugPrint('📤 Retailer Profile URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        return RetailerProfileResponse.fromJson(
          jsonDecode(response.body),
        );
      }

      throw Exception(
        'Failed to fetch retailer profile: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Retailer Profile Error: $e');
      rethrow;
    }
  }

  // Edit Retailer Profile API
  static Future<EditRetailerResponse> editRetailerProfile(
      EditRetailerModel model,
      ) async {
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
  static Future<Map<String, dynamic>> placeOrder({
    required String productId,
    String? retailerId,
    String? dealerId,
    String? asmId,
    required String userId,
    required String shippingAddress,
    required String paymentMode,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.placeOrder);

      final body = {
        "ProductID": productId,
        "RetailerId": retailerId ?? "",
        "DealerId": dealerId ?? "",
        if (asmId != null && asmId.isNotEmpty) "AsmId": asmId,
        if (asmId != null && asmId.isNotEmpty) "ASMId": asmId,
        "UserId": userId,
        "ShippingAddress": shippingAddress,
        "PaymenMode": paymentMode,
      };

      debugPrint("========================================");
      debugPrint("📤 PLACE ORDER API");
      debugPrint("URL: $url");
      debugPrint("BODY: ${jsonEncode(body)}");
      debugPrint("========================================");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      debugPrint("📥 Status: ${response.statusCode}");
      debugPrint("📥 Response: ${response.body}");

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      throw Exception(
        "Place Order Error: ${response.statusCode}\n${response.body}",
      );
    } catch (e) {
      debugPrint("❌ Place Order API Error: $e");
      rethrow;
    }
  }
  static Future<List<MyOrderModel>> getMyOrders({
    required String idType,
    required String idValue,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.getMyOrders).replace(
        queryParameters: {
          'idType': idType,
          'idValue': idValue,
        },
      );

      debugPrint("======================================");
      debugPrint("📦 MY ORDERS API");
      debugPrint("URL: $uri");
      debugPrint("ID TYPE: $idType");
      debugPrint("ID VALUE: $idValue");
      debugPrint("======================================");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("📥 STATUS: ${response.statusCode}");
      debugPrint("📥 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map((item) => MyOrderModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (decoded is Map) {
          final list = decoded['data'] ?? decoded['Data'] ?? decoded['orders'] ?? decoded['Orders'];
          if (list is List) {
            return list
                .map((item) => MyOrderModel.fromJson(Map<String, dynamic>.from(item)))
                .toList();
          }
        }

        return [];
      }

      throw Exception(
        "Failed to fetch orders. "
            "Status Code: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint("❌ My Orders API Error: $e");
      throw Exception("Failed to fetch orders: $e");
    }
  }

  // Get Address Retailer / Dealer by Visiter ID
  static Future<UserAddressResponse?> getAddressByVisiterId(String visiterId) async {
    try {
      final cleanId = visiterId.trim();
      if (cleanId.isEmpty) return null;

      final uri = Uri.parse(ApiConstants.getByAddressRetailerDealer).replace(
        queryParameters: {
          'visiterId': cleanId,
        },
      );

      debugPrint("======================================");
      debugPrint("📍 GET USER ADDRESS API");
      debugPrint("URL: $uri");
      debugPrint("VisiterId: $cleanId");
      debugPrint("======================================");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("📍 User Address Status: ${response.statusCode}");
      debugPrint("📍 User Address Response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return UserAddressResponse.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error fetching user address by visiterId: $e");
      return null;
    }
  }

  // Get All Retailers List
  static Future<GetAllRetailerResponse> getAllRetailers() async {
    try {
      final uri = Uri.parse(ApiConstants.getAllRetailer);
      debugPrint("======================================");
      debugPrint("📦 GET ALL RETAILERS API");
      debugPrint("URL: $uri");
      debugPrint("======================================");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("📥 All Retailers Status: ${response.statusCode}");
      debugPrint("📥 All Retailers Response: ${response.body}");

      if (response.statusCode == 200) {
        String rawBody = response.body;
        // Fix trailing empty key-values
        String sanitized = rawBody.replaceAll(RegExp(r':\s*,'), ': null,');
        sanitized = sanitized.replaceAllMapped(
          RegExp(r':\s*(\r?\n|\r|\})'),
          (match) => ': null${match.group(1)}',
        );

        final decoded = jsonDecode(sanitized);
        GetAllRetailerResponse result;
        if (decoded is Map<String, dynamic>) {
          result = GetAllRetailerResponse.fromJson(decoded);
        } else if (decoded is List) {
          result = GetAllRetailerResponse(
            header: RetailerHeader(success: true, totalCount: decoded.length),
            data: decoded
                .whereType<Map<String, dynamic>>()
                .map((e) => RetailerItem.fromJson(e))
                .toList(),
          );
        } else {
          result = GetAllRetailerResponse();
        }

        // Print Country, State, District, Block, Address for each parsed Retailer
        for (int i = 0; i < result.data.length; i++) {
          final item = result.data[i];
          debugPrint("---------------------------------------------");
          debugPrint("📍 Retailer [${i + 1}] ID: ${item.visiterId ?? item.id}");
          debugPrint('   "Country": "${item.country}"');
          debugPrint('   "State": "${item.state}"');
          debugPrint('   "District": "${item.district}"');
          debugPrint('   "Block": "${item.block}"');
          debugPrint('   "Address": "${item.address}"');
          debugPrint("---------------------------------------------");
        }

        return result;
      }
      throw Exception('Failed to load retailers list (Status: ${response.statusCode})');
    } catch (e) {
      debugPrint("❌ Error loading retailers: $e");
      throw Exception('Error loading retailers: $e');
    }
  }
}


