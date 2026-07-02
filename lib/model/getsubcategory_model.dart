class SubCategoryResponse {
  final bool status;
  final String message;
  final List<SubCategory> data;

  SubCategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoryResponse(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? (json["data"] as List<dynamic>)
              .map((e) => SubCategory.fromJson(e))
              .toList()
          : [],
    );
  }
}

class SubCategory {
  final int id;
  final String catId;
  final String subCatId;
  final String subCategoryName;
  final DateTime currentDate;

  SubCategory({
    required this.id,
    required this.catId,
    required this.subCatId,
    required this.subCategoryName,
    required this.currentDate,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json["ID"] ?? 0,
      catId: json["CatId"] ?? "",
      subCatId: json["SubCatId"] ?? "",
      subCategoryName: json["SUbCategoryName"] ?? "",
      currentDate: json["CurrentDate"] != null 
          ? DateTime.parse(json["CurrentDate"]) 
          : DateTime.now(),
    );
  }
}
