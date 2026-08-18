class OrderSummaryResponse {
  final bool status;
  final String message;
  final OrderUser user;
  final bool walletEligible;
  final OrderSummary summary;
  final List<OrderCartItem> cartItems;

  OrderSummaryResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.walletEligible,
    required this.summary,
    required this.cartItems,
  });

  factory OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    return OrderSummaryResponse(
      status: json["Status"] ?? false,
      message: json["Message"] ?? "",
      user: OrderUser.fromJson(json["User"] ?? {}),
      walletEligible: json["WalletEligible"] ?? false,
      summary: OrderSummary.fromJson(json["Summary"] ?? {}),
      cartItems: (json["CartItems"] as List<dynamic>? ?? [])
          .map((e) => OrderCartItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderUser {
  final String name;
  final String mobile;
  final String email;
  final String address;

  OrderUser({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      name: json["Name"] ?? "",
      mobile: json["Mobile"] ?? "",
      email: json["Email"] ?? "",
      address: json["Address"] ?? "",
    );
  }
}

class OrderSummary {
  final double listedTotal;
  final double sellingTotal;
  final double discount;
  final double finalTotal;

  OrderSummary({
    required this.listedTotal,
    required this.sellingTotal,
    required this.discount,
    required this.finalTotal,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      listedTotal: (json["ListedTotal"] ?? 0).toDouble(),
      sellingTotal: (json["SellingTotal"] ?? 0).toDouble(),
      discount: (json["Discount"] ?? 0).toDouble(),
      finalTotal: (json["FinalTotal"] ?? 0).toDouble(),
    );
  }
}

class OrderCartItem {
  final String productID;
  final String productName;
  final String image;
  final int qty;
  final double listedPrice;
  final double sellingPrice;
  final double total;

  OrderCartItem({
    required this.productID,
    required this.productName,
    required this.image,
    required this.qty,
    required this.listedPrice,
    required this.sellingPrice,
    required this.total,
  });

  factory OrderCartItem.fromJson(Map<String, dynamic> json) {
    return OrderCartItem(
      productID: json["ProductID"] ?? "",
      productName: json["ProductName"] ?? "",
      image: json["Image"] ?? "",
      qty: json["QTY"] ?? 0,
      listedPrice: (json["listedPrice"] ?? 0).toDouble(),
      sellingPrice: (json["SellingPrice"] ?? 0).toDouble(),
      total: (json["Total"] ?? 0).toDouble(),
    );
  }
}