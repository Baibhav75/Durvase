class LatestProductModel {
  final bool status;
  final String message;
  final int totalProducts;
  final List<LatestProduct> data;

  LatestProductModel({
    required this.status,
    required this.message,
    required this.totalProducts,
    required this.data,
  });

  factory LatestProductModel.fromJson(Map<String, dynamic> json) {
    return LatestProductModel(
      status: json["Status"],
      message: json["Message"],
      totalProducts: json["TotalProducts"],
      data: (json["Data"] as List)
          .map((e) => LatestProduct.fromJson(e))
          .toList(),
    );
  }
}

class LatestProduct {
  final String productId;
  final String productName;
  final String productImage;
  final String mrp;
  final String sellingPrice;
  final String? productPoint;
  final String? productPercentage;

  LatestProduct({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.mrp,
    required this.sellingPrice,
    this.productPoint,
    this.productPercentage,
  });

  factory LatestProduct.fromJson(Map<String, dynamic> json) {
    return LatestProduct(
      productId: json["ProductId"],
      productName: json["ProductName"],
      productImage: json["ProductImage"],
      mrp: json["MRP"],
      sellingPrice: json["SellingPrice"],
      productPoint: json["ProductPoint"],
      productPercentage: json["ProductPercentage"],
    );
  }

  String get imageUrl =>
      "https://durvasaayurved.online$productImage";
}