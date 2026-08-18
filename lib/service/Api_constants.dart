import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? '';

  static String get getBannerImage =>
      "$baseUrl/api/GetBannerImage/GetBannerImage";

  static String get latestProducts =>
      "$baseUrl/api/LattestProductDetails/LatestProducts";

  // Country List
  static String get getAllCountry =>
      "$baseUrl/api/GetAllCountry";

  // State List (by CountryId)
  static String get getAllState =>
      "$baseUrl/api/GetAllState";

  // District List (by StateId)
  static String get getAllDistrict =>
      "$baseUrl/api/GetAllDistrict";

  // Block List (by DistrictId)
  static String get getAllBlock =>
      "$baseUrl/api/GetAllBlock";
}