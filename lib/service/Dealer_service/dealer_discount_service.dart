import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Api_constants.dart';
import '../../model/Retailer_model/discount_model.dart';

class DealerDiscountService {
  /// Applies or updates a discount percentage for a visitor/retailer.
  /// API: POST https://durvasaayurved.com/api/VisiterOfferDiscount
  /// Payload: { "VisiterId": "...", "DiscountPercentage": 25.0 }
  static Future<Map<String, dynamic>> applyProductOfferDiscount({
    required String retailerId,
    required double discountPercentage,
  }) async {
    try {
      final cleanId = retailerId.trim();
      if (cleanId.isEmpty) {
        return {
          'status': false,
          'message': 'Visiter ID is required.',
          'response': null,
        };
      }

      if (discountPercentage <= 0) {
        return {
          'status': false,
          'message': 'Discount percentage must be greater than 0.',
          'response': null,
        };
      }

      final url = Uri.parse(ApiConstants.productOfferDiscount);
      final requestPayload = VisiterOfferDiscountRequest(
        visiterId: cleanId,
        discountPercentage: discountPercentage,
      );
      final bodyData = requestPayload.toJson();

      debugPrint("========================================");
      debugPrint("📤 [Discount API] POST URL: $url");
      debugPrint("📤 [Discount API] Body: ${jsonEncode(bodyData)}");
      debugPrint("========================================");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyData),
      ).timeout(const Duration(seconds: 20));

      debugPrint("📥 [Discount API] StatusCode: ${response.statusCode}");
      debugPrint("📥 [Discount API] ResponseBody: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final offerResponse = VisiterOfferDiscountResponse.fromJson(
          decoded is Map<String, dynamic> ? decoded : {},
          statusCode: response.statusCode,
        );

        final String msg = offerResponse.message ??
            'Discount percentage saved successfully for the visiter.';

        return {
          'status': true,
          'message': msg,
          'data': decoded,
          'response': offerResponse,
        };
      } else {
        String msg = 'Failed to apply discount (Error ${response.statusCode})';
        VisiterOfferDiscountResponse? offerResponse;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            offerResponse = VisiterOfferDiscountResponse.fromJson(decoded, statusCode: response.statusCode);
            if (offerResponse.message != null && offerResponse.message!.isNotEmpty) {
              msg = offerResponse.message!;
            }
          }
        } catch (_) {}

        return {
          'status': false,
          'message': msg,
          'response': offerResponse,
        };
      }
    } catch (e) {
      debugPrint("❌ [Discount API] Exception: $e");
      return {
        'status': false,
        'message': 'Connection error: $e',
        'response': null,
      };
    }
  }
}
