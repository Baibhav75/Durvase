import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/banner_model.dart';
import '../model/checkout_model.dart';
import '../model/getcategory_model.dart';
import '../model/getsubcategory_model.dart';
import '../model/latest_product_model.dart';
import '../model/order_summary_model.dart';
import '../model/product_model.dart';
import 'Api_constants.dart';
import 'session_manager.dart';

class AuthService {
  static const String baseUrl =
      "https://durvasaayurved.com/api";

  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/GetCategories/Categories"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final result = CategoryResponse.fromJson(jsonData);

      if (result.status) {
        return result.data;
      }

      throw Exception(result.message);
    }

    throw Exception("Failed to load categories");
  }

  Future<List<SubCategory>> getSubCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/GetSubCategories/SubCategories"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final result = SubCategoryResponse.fromJson(jsonData);

      if (result.status) {
        return result.data;
      }

      throw Exception(result.message);
    }

    throw Exception("Failed to load subcategories");
  }

  Future<List<Product>> getProducts(String catId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/GetProductList/ProductList?categoryid=$catId"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final result = ProductResponse.fromJson(jsonData);

      if (result.status) {
        return result.data;
      }

      throw Exception(result.message);
    }

    throw Exception("Failed to load products");
  }

  Future<ProductDetailsData?> getProductDetails(String productId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/GetProductDetails/ProductDetails?ProductID=$productId"),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final result = ProductDetailsResponse.fromJson(jsonData);

      if (result.status) {
        return result.data;
      }

      throw Exception(result.message);
    }

    throw Exception("Failed to load product details");
  }
  Future<CheckoutResponse?> getCheckout(String userId) async {
    try {
      String resolvedUserId = userId.trim();
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getUserId()) ?? '';
      }

      if (resolvedUserId.isEmpty) {
        debugPrint("GetCheckout: UserId is empty");
        return null;
      }

      final url = Uri.parse("$baseUrl/CheckOut/Checkout?UserID=$resolvedUserId");
      debugPrint("GetCheckout URL: $url");
      final response = await http.get(url);
      debugPrint("GetCheckout StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return CheckoutResponse.fromJson(jsonData);
      }
      return null;
    } catch (e, stack) {
      debugPrint("GetCheckout Exception: $e\n$stack");
      return null;
    }
  }

  Future<OrderSummaryResponse?> getOrderSummary(String userId) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/OrderSummary1/OrderSummary?UserId=$userId",
      ),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return OrderSummaryResponse.fromJson(jsonData);
    }

    throw Exception("Failed to load Order Summary");
  }


  Future<List<BannerItem>> getBannerImages() async {
    final response = await http.get(
      Uri.parse(ApiConstants.getBannerImage),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final bannerModel = BannerModel.fromJson(jsonData);

      if (bannerModel.status) {
        return bannerModel.data;
      }
    }

    return [];
  }
  Future<List<LatestProduct>> getLatestProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.latestProducts),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        final latestProductModel =
        LatestProductModel.fromJson(jsonData);

        if (latestProductModel.status) {
          return latestProductModel.data;
        }
      }

      return [];
    } catch (e) {
      debugPrint("Latest Product Error : $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String productId,
    int qty = 1,
  }) async {
    try {
      String resolvedUserId = userId.trim();
      if (resolvedUserId.isEmpty) {
        resolvedUserId = await SessionManager.getEffectiveUserId();
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getVisiterId()) ?? '';
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getRetailerId()) ?? '';
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getUserId()) ?? '';
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getEmpId()) ?? '';
      }

      if (resolvedUserId.isEmpty) {
        return {
          'status': false,
          'message': 'User session not found. Please log in to add items to cart.',
        };
      }

      // Real URL: https://durvasaayurved.com/api/AddToCart?ProductID=Product_ID1878&UserID=EMP855297
      final cleanProductId = productId.trim();
      final url = Uri.parse(
        "$baseUrl/AddToCart?ProductID=${Uri.encodeComponent(cleanProductId)}&UserID=${Uri.encodeComponent(resolvedUserId)}",
      );

      debugPrint("========================================");
      debugPrint("📤 [AddToCart API] POST URL: $url");
      debugPrint("========================================");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint("📥 [AddToCart API] StatusCode: ${response.statusCode}");
      debugPrint("📥 [AddToCart API] ResponseBody: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic>) {
          final res = AddToCartResponse.fromJson(jsonData);
          return {
            'status': res.status,
            'message': res.message,
            'data': jsonData['data'] ?? jsonData['Data'],
          };
        }

        return {
          'status': true,
          'message': 'Product added to cart successfully.',
        };
      } else {
        String errMsg = 'Failed to add to cart (${response.statusCode})';
        try {
          final dynamic jsonData = jsonDecode(response.body);
          if (jsonData is Map<String, dynamic>) {
            final res = AddToCartResponse.fromJson(jsonData);
            errMsg = res.message;
          }
        } catch (_) {}

        return {
          'status': false,
          'message': errMsg,
        };
      }
    } catch (e) {
      debugPrint("❌ [AddToCart API] Error: $e");
      return {
        'status': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // getCard service
  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      String resolvedUserId = userId.trim();

      if (resolvedUserId.isEmpty) {
        resolvedUserId = await SessionManager.getEffectiveUserId();
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getVisiterId()) ?? '';
      }
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getRetailerId()) ?? '';
      }

      if (resolvedUserId.isEmpty) {
        return {
          'status': false,
          'message': 'User ID not found',
          'data': [],
        };
      }

      final url = Uri.parse(
        "$baseUrl/GetCart/Cart?UserId=${Uri.encodeComponent(resolvedUserId)}",
      );

      debugPrint("📤 [GetCart API] URL: $url");

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint("📥 [GetCart API] StatusCode: ${response.statusCode}");
      debugPrint("GetCart Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
        jsonDecode(response.body);

        if (jsonData['status'] == true && jsonData['data'] != null) {
          final List<dynamic> cartData =
          jsonData['data'] is List ? jsonData['data'] : [];

          // Read Cart ID from every item
          for (final item in cartData) {
            debugPrint("Cart ID: ${item['ID']}");
            debugPrint("Product ID: ${item['ProductID']}");
            debugPrint("Product Name: ${item['ProductName']}");
          }

          return {
            'status': true,
            'message': jsonData['message'] ?? '',
            'CartCount': jsonData['CartCount'] ?? 0,
            'data': cartData,
          };
        }

        return {
          'status': false,
          'message': jsonData['message'] ?? 'Your cart is empty',
          'data': [],
        };
      }

      return {
        'status': false,
        'message': 'Server error (${response.statusCode})',
        'data': [],
      };
    } catch (e) {
      debugPrint("GetCart Error: $e");

      return {
        'status': false,
        'message': 'Connection error: $e',
        'data': [],
      };
    }
  }

  Future<Map<String, dynamic>> deleteCartItem(dynamic cartId) async {
    try {
      if (cartId == null || cartId.toString().trim().isEmpty) {
        return {
          'status': false,
          'message': 'Invalid Cart ID',
        };
      }

      final cleanId = cartId.toString().trim();

      final url = Uri.parse(
        '$baseUrl/DeleteCart?ID=$cleanId',
      );

      debugPrint('========================================');
      debugPrint('🗑️ DELETE CART API CALL');
      debugPrint('Method: GET');
      debugPrint('URL: $url');
      debugPrint('Cart ID: $cleanId');
      debugPrint('========================================');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Status Code: ${response.statusCode}');
      debugPrint('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.trim().isEmpty) {
          return {
            'status': true,
            'message': 'Item deleted successfully',
          };
        }

        final jsonData = jsonDecode(response.body);

        final bool success =
            jsonData['status'] == true ||
                jsonData['Status'] == true ||
                jsonData['success'] == true;

        return {
          'status': success,
          'message': jsonData['message'] ??
              jsonData['Message'] ??
              (success
                  ? 'Item deleted successfully'
                  : 'Failed to delete item'),
        };
      }

      return {
        'status': false,
        'message': 'Server error (${response.statusCode})',
      };
    } catch (e) {
      debugPrint('❌ DeleteCart Exception: $e');

      return {
        'status': false,
        'message': 'Connection error: $e',
      };
    }
  }
}


