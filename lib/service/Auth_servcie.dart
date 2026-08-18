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
      "https://durvasaayurved.online/api";

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
    final response = await http.get(
      Uri.parse(
        "$baseUrl/CheckOut/Checkout?UserID=$userId",
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return CheckoutResponse.fromJson(jsonData);
    }

    throw Exception("Failed to load checkout");
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
        resolvedUserId = (await SessionManager.getUserId()) ?? '';
      }

      if (resolvedUserId.isEmpty) {
        return {
          'status': false,
          'message': 'User ID not found. Please log in again.',
        };
      }

      final url = Uri.parse(
        "$baseUrl/AddToCart/AddToCart?ProductID=$productId&UserID=$resolvedUserId&Qty=$qty",
      );

      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bool isSuccess = jsonData['status'] == true;
        final String msg = jsonData['message'] ??
            (isSuccess ? 'Added to cart successfully' : 'Failed to add to cart');
        return {
          'status': isSuccess,
          'message': msg,
          'data': jsonData['data'],
        };
      } else {
        return {
          'status': false,
          'message': 'Server error (${response.statusCode})',
        };
      }
    } catch (e) {
      debugPrint("AddToCart Error: $e");
      return {
        'status': false,
        'message': 'Connection error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getCart(String userId) async {
    try {
      String resolvedUserId = userId.trim();
      if (resolvedUserId.isEmpty) {
        resolvedUserId = (await SessionManager.getUserId()) ?? '';
      }

      if (resolvedUserId.isEmpty) {
        return {
          'status': false,
          'message': 'User ID not found',
          'data': [],
        };
      }

      final url = Uri.parse("$baseUrl/GetCart/Cart?UserId=$resolvedUserId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return {
            'status': true,
            'message': jsonData['message'] ?? '',
            'data': jsonData['data'] is List ? jsonData['data'] : [],
          };
        } else {
          return {
            'status': false,
            'message': jsonData['message'] ?? 'Your cart is empty',
            'data': [],
          };
        }
      } else {
        return {
          'status': false,
          'message': 'Server error (${response.statusCode})',
          'data': [],
        };
      }
    } catch (e) {
      debugPrint("GetCart Error: $e");
      return {
        'status': false,
        'message': 'Connection error: $e',
        'data': [],
      };
    }
  }
}


