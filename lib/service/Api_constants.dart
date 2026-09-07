import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String _defaultBaseUrl = 'https://durvasaayurved.com';
  
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.trim().isNotEmpty) {
      return envUrl.trim();
    }
    return _defaultBaseUrl;
  }

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

  // assine area
  static String get getASM =>
      '$baseUrl/api/WorkAreaASM/GetASM';

  // ASM Work Report
  static String get submitASMWorkReport =>
      "$baseUrl/api/PostASMWorkReport/Submit";

  // MR Work Report
  static String get submitMRWorkReport =>
      "$baseUrl/api/PostMRWorkReport/Submit";

  // Retailer Profile
  static String get retailerProfile =>
      "$baseUrl/api/retailerprofile";

  // Edit Retailer Profile
  static String get editRetailerProfile =>
      "$baseUrl/api/editretailerprofile";

  // Get All Retailers
  static String get getAllRetailer =>
      "$baseUrl/api/GetAllRetailer";

  // Get All ASM List
  static String get getAsmList =>
      "$baseUrl/api/ASMlist";

  // Proceed to Checkout / Place Order
  static String get placeOrder =>
      "$baseUrl/api/ProceedToCheckout/PlaceOrder";
  // My Orders - Dealer
  static String get getMyOrders =>
      "$baseUrl/api/GetByRetailerIdDealerProduct/GetDetails";

  // Visiter / Retailer Login
  static String get visiterLogin =>
      "$baseUrl/api/visiterlogin";

  // Visiter / Retailer Profile
  static String get visiterProfile =>
      "$baseUrl/api/visiterprofile";

  // Get Address Retailer / Dealer by Visiter ID
  static String get getByAddressRetailerDealer =>
      "$baseUrl/api/GetByAddressRetailerDealer";
}



