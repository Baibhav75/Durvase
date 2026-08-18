class ApiConstants {
  static const String baseUrl =
      "https://durvasaayurved.online";

  static const String getBannerImage =
      "$baseUrl/api/GetBannerImage/GetBannerImage";

  static const String latestProducts =
      "$baseUrl/api/LattestProductDetails/LatestProducts";

  // Country List
  static const String getAllCountry =
      "$baseUrl/api/GetAllCountry";

  // State List (by CountryId)
  static const String getAllState =
      "$baseUrl/api/GetAllState";

  // District List (by StateId)
  static const String getAllDistrict =
      "$baseUrl/api/GetAllDistrict";

  // Block List (by DistrictId)
  static const String getAllBlock =
      "$baseUrl/api/GetAllBlock";
}