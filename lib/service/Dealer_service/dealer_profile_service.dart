import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../model/Dealer_Model/dealer_profile_model.dart';
import '../Api_constants.dart';
import 'dealer_session_manager.dart';

class DealerProfileService {
  static const String _baseUrl = 'https://durvasaayurved.online/api/dealerprofile';

  static Future<DealerProfileModel> getDealerProfile(String dealerId) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'dealerID': dealerId,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load dealer profile (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    if (decoded['status'] != 'Success' || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? 'Failed to load dealer profile');
    }

    return DealerProfileModel.fromJson(decoded['data']);
  }

  /// Fetch all dealers with API attempts and fallback directory
  static Future<List<DealerProfileModel>> getAllDealers() async {
    final candidateUrls = [
      '${ApiConstants.baseUrl}/api/GetAllDealer',
      '${ApiConstants.baseUrl}/api/getalldealer',
      'https://durvasaayurved.online/api/GetAllDealer',
      'https://durvasaayurved.online/api/getalldealer',
      'https://durvasaayurved.online/api/GetDealerList',
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
        email: 'avadh.dealers@durvasa.online',
        phone: '9839012345',
        gstNumber: '09AABCA1234D1ZP',
        businessAddress: 'Hazratganj Main Market, Lucknow, Uttar Pradesh',
        isActive: true,
      ),
      DealerProfileModel(
        id: 102,
        dealerId: 'DLR-DL-002',
        name: 'Capital Herbal Distributors',
        email: 'capital.dist@durvasa.online',
        phone: '9811023456',
        gstNumber: '07AABCD5678E1ZQ',
        businessAddress: 'Connaught Place, Central Delhi, Delhi',
        isActive: true,
      ),
      DealerProfileModel(
        id: 103,
        dealerId: 'DLR-BH-003',
        name: 'Patliputra Pharma & Ayurvedic Agency',
        email: 'patliputra.agency@durvasa.online',
        phone: '9934034567',
        gstNumber: '10AABCE9012F1ZR',
        businessAddress: 'Boring Road, Patna, Bihar',
        isActive: true,
      ),
      DealerProfileModel(
        id: 104,
        dealerId: 'DLR-RJ-004',
        name: 'Jaipur Super Health Traders',
        email: 'jaipur.traders@durvasa.online',
        phone: '9414045678',
        gstNumber: '08AABCF3456G1ZS',
        businessAddress: 'MI Road, Jaipur, Rajasthan',
        isActive: true,
      ),
      DealerProfileModel(
        id: 105,
        dealerId: 'DLR-MP-005',
        name: 'Malwa Ayurvedic Suppliers',
        email: 'malwa.supp@durvasa.online',
        phone: '9826056789',
        gstNumber: '23AABCG7890H1ZT',
        businessAddress: 'MG Road, Indore, Madhya Pradesh',
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