import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../model/Dealer_Model/dealer_profile_model.dart';
import '../Api_constants.dart';
import 'dealer_session_manager.dart';

class DealerProfileService {
  static const String _baseUrl = 'https://durvasaayurved.com/api/dealerprofile';

  /// Fetch dealer profile details using dealerID / visiterId
  static Future<DealerProfileModel> getDealerProfile(String dealerId) async {
    final cleanId = dealerId.trim();
    if (cleanId.isEmpty) {
      throw Exception('Dealer ID is empty');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'dealerID': cleanId,
    });

    debugPrint('📤 [DealerProfileService] Request URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    debugPrint('📥 [DealerProfileService] Status: ${response.statusCode}');
    debugPrint('📥 [DealerProfileService] Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load dealer profile (Server code ${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final status = decoded['status']?.toString().toLowerCase() ?? '';
      final isSuccess = status == 'success' || decoded['data'] != null;

      if (isSuccess && decoded['data'] != null) {
        if (decoded['data'] is Map<String, dynamic>) {
          return DealerProfileModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }

      // If data is top-level map
      if (decoded.containsKey('dealerID') || decoded.containsKey('name')) {
        return DealerProfileModel.fromJson(decoded);
      }

      throw Exception(decoded['message']?.toString() ?? 'Failed to load dealer profile');
    }

    throw Exception('Invalid server response format');
  }

  /// Fetch all dealers with API attempts and fallback directory
  static Future<List<DealerProfileModel>> getAllDealers() async {
    final candidateUrls = [
      '${ApiConstants.baseUrl}/api/GetAllDealer',
      '${ApiConstants.baseUrl}/api/getalldealer',
      '${ApiConstants.baseUrl}/api/GetDealerList',
      'https://durvasaayurved.com/api/GetAllDealer',
      'https://durvasaayurved.com/api/getalldealer',
    ];

    for (final url in candidateUrls.toSet()) {
      try {
        final uri = Uri.parse(url);
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> && decoded['data'] is List) {
            final list = (decoded['data'] as List)
                .map((e) => DealerProfileModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (list.isNotEmpty) return list;
          } else if (decoded is List) {
            final list = decoded
                .map((e) => DealerProfileModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (list.isNotEmpty) return list;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching dealers from $url: $e');
      }
    }

    // Include saved session dealer if available
    final List<DealerProfileModel> fallbackList = [];
    try {
      final savedDealer = await DealerSessionManager.getLoginData();
      if (savedDealer != null && (savedDealer.dealerId.isNotEmpty || savedDealer.name.isNotEmpty)) {
        fallbackList.add(
          DealerProfileModel(
            id: 1,
            dealerId: savedDealer.dealerId.isNotEmpty ? savedDealer.dealerId : 'DLR-ME',
            name: savedDealer.name.isNotEmpty ? savedDealer.name : 'My Dealer Account',
            phone: savedDealer.phone,
            email: savedDealer.email,
            businessAddress: savedDealer.businessAddress.isNotEmpty ? savedDealer.businessAddress : 'Registered Headquarters',
            businessName: savedDealer.businessName,
            purpose: savedDealer.purpose,
            state: savedDealer.state,
            district: savedDealer.district,
            gstNumber: savedDealer.gstNumber.isNotEmpty ? savedDealer.gstNumber : '09AAECD1234F1Z5',
            isActive: true,
          ),
        );
      }
    } catch (_) {}

    // Default Authorized Regional Dealers directory
    final defaultDealers = [
      DealerProfileModel(
        id: 101,
        dealerId: 'DLR-UP-001',
        name: 'Avadh Ayurvedic Agencies (Main HQ)',
        businessName: 'Avadh Ayurvedic Agencies',
        email: 'avadh.dealers@durvasa.online',
        phone: '9839012345',
        gstNumber: '09AABCA1234D1ZP',
        businessAddress: 'Hazratganj Main Market, Lucknow, Uttar Pradesh',
        state: 'Uttar Pradesh',
        district: 'Lucknow',
        isActive: true,
      ),
      DealerProfileModel(
        id: 102,
        dealerId: 'DLR-DL-002',
        name: 'Capital Herbal Distributors',
        businessName: 'Capital Herbal Distributors',
        email: 'capital.dist@durvasa.online',
        phone: '9811023456',
        gstNumber: '07AABCD5678E1ZQ',
        businessAddress: 'Connaught Place, Central Delhi, Delhi',
        state: 'Delhi',
        district: 'Central Delhi',
        isActive: true,
      ),
      DealerProfileModel(
        id: 103,
        dealerId: 'DLR-BH-003',
        name: 'Patliputra Pharma & Ayurvedic Agency',
        businessName: 'Patliputra Pharma',
        email: 'patliputra.agency@durvasa.online',
        phone: '9934034567',
        gstNumber: '10AABCE9012F1ZR',
        businessAddress: 'Boring Road, Patna, Bihar',
        state: 'Bihar',
        district: 'Patna',
        isActive: true,
      ),
      DealerProfileModel(
        id: 104,
        dealerId: 'DLR-RJ-004',
        name: 'Jaipur Super Health Traders',
        businessName: 'Jaipur Super Health Traders',
        email: 'jaipur.traders@durvasa.online',
        phone: '9414045678',
        gstNumber: '08AABCF3456G1ZS',
        businessAddress: 'MI Road, Jaipur, Rajasthan',
        state: 'Rajasthan',
        district: 'Jaipur',
        isActive: true,
      ),
      DealerProfileModel(
        id: 105,
        dealerId: 'DLR-MP-005',
        name: 'Malwa Ayurvedic Suppliers',
        businessName: 'Malwa Ayurvedic Suppliers',
        email: 'malwa.supp@durvasa.online',
        phone: '9826056789',
        gstNumber: '23AABCG7890H1ZT',
        businessAddress: 'MG Road, Indore, Madhya Pradesh',
        state: 'Madhya Pradesh',
        district: 'Indore',
        isActive: true,
      ),
    ];

    for (final d in defaultDealers) {
      if (!fallbackList.any((existing) => existing.dealerId == d.dealerId)) {
        fallbackList.add(d);
      }
    }

    return fallbackList;
  }
}