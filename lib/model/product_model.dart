class ProductResponse {
  final bool status;
  final String message;
  final String categoryName;
  final int totalProducts;
  final List<Product> data;

  ProductResponse({
    required this.status,
    required this.message,
    required this.categoryName,
    required this.totalProducts,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      categoryName: json["CategoryName"] ?? "",
      totalProducts: json["TotalProducts"] ?? 0,
      data: (json["data"] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}

class Product {
  final int id;
  final String productId;
  final String productName;
  final String catId;
  final String subCatId;
  final String image1;
  final String? image2;
  final String? image3;
  final String? image4;
  final String? image5;
  final String mrp;
  final String sellingPrice;
  final String unit;
  final String? description;
  final String categoryName;

  Product({
    required this.id,
    required this.productId,
    required this.productName,
    required this.catId,
    required this.subCatId,
    required this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.image5,
    required this.mrp,
    required this.sellingPrice,
    required this.unit,
    this.description,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["ID"],
      productId: json["ProductId"],
      productName: json["ProductName"],
      catId: json["CatId"],
      subCatId: json["SubCatId"],
      image1: json["Image1"] ?? "",
      image2: json["Image2"],
      image3: json["Image3"],
      image4: json["Image4"],
      image5: json["Image5"],
      mrp: json["MRP"] ?? "",
      sellingPrice: json["SellingPrice"] ?? "",
      unit: json["Unit"] ?? "",
      description: json["Description"],
      categoryName: json["CategoryName"] ?? "",
    );
  }
}