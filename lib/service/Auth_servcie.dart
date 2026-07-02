import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/getcategory_model.dart';
import '../model/getsubcategory_model.dart';
import '../model/product_model.dart';

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
}