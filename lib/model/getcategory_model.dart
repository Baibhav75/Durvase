class CategoryResponse {
  final bool status;
  final String message;
  final List<Category> data;

  CategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: (json["data"] as List<dynamic>)
          .map((e) => Category.fromJson(e))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String catId;
  final String categoryName;
  final DateTime currentDate;
  final String image;

  Category({
    required this.id,
    required this.catId,
    required this.categoryName,
    required this.currentDate,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["ID"],
      catId: json["CatId"],
      categoryName: json["CategoryName"],
      currentDate: DateTime.parse(json["CurrentDate"]),
      image: json["Image"] ?? "",
    );
  }
}