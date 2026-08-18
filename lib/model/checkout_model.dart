class CheckoutResponse {
  final bool status;
  final String message;
  final CheckoutUser user;
  final List<CartItem> cart;
  final Summary summary;
  final bool isEligibleToUsePoint;

  CheckoutResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.cart,
    required this.summary,
    required this.isEligibleToUsePoint,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    final customer = json["Customer"] ?? {};
    final shipping = json["ShippingAddress"] ?? {};
    final wallet = json["Wallet"] ?? {};

    return CheckoutResponse(
      status: json["Status"] ?? false,
      message: json["Message"] ?? "",
      user: CheckoutUser(
        fullName: customer["Name"]?.toString() ?? "",
        mobile: customer["Mobile"]?.toString() ?? "",
        email: customer["Email"]?.toString() ?? "",
        permanentAddress: shipping["Address"]?.toString() ?? "",
        city: shipping["District"]?.toString() ?? "",
        state: shipping["State"]?.toString() ?? "",
      ),
      cart: (json["CartItems"] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json["OrderSummary"] ?? {}),
      isEligibleToUsePoint: wallet["Eligible"] ?? false,
    );
  }
}

class CheckoutUser {
  final String fullName;
  final String mobile;
  final String email;
  final String permanentAddress;
  final String city;
  final String state;

  CheckoutUser({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.permanentAddress,
    required this.city,
    required this.state,
  });

  factory CheckoutUser.fromJson(Map<String, dynamic> json) {
    return CheckoutUser(
      fullName: json["FullName"] ?? "",
      mobile: json["Mobile"] ?? "",
      email: json["Email"] ?? "",
      permanentAddress: json["PermanentAddress"] ?? "",
      city: json["City"] ?? "",
      state: json["State"] ?? "",
    );
  }
}

class CartItem {
  final int id;
  final String productID;
  final String productName;
  final String uniqueID;
  final double listedPrice;
  final double sellingPrice;
  final int qty;
  final String image;
  final String? gst;
  final String productPoint;
  final String? productPercentage;

  CartItem({
    required this.id,
    required this.productID,
    required this.productName,
    required this.uniqueID,
    required this.listedPrice,
    required this.sellingPrice,
    required this.qty,
    required this.image,
    this.gst,
    required this.productPoint,
    this.productPercentage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json["Id"] ?? 0,
      productID: json["ProductID"]?.toString() ?? "",
      productName: json["ProductName"]?.toString() ?? "",
      uniqueID: json["UniqueID"]?.toString() ?? "",
      listedPrice: (json["ListedPrice"] ?? 0).toDouble(),
      sellingPrice: (json["SellingPrice"] ?? 0).toDouble(),
      qty: json["Qty"] ?? 0,
      image: json["Image"]?.toString() ?? "",
      gst: json["GST"]?.toString(),
      productPoint: json["ProductPoint"]?.toString() ?? "",
      productPercentage: json["ProductPercentage"]?.toString(),
    );
  }
}

class Summary {
  final double totalListedPrice;
  final double totalSellingPrice;
  final double discount;
  final double finalAmount;

  Summary({
    required this.totalListedPrice,
    required this.totalSellingPrice,
    required this.discount,
    required this.finalAmount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalListedPrice: (json["ListedTotal"] ?? 0).toDouble(),
      totalSellingPrice: (json["SellingTotal"] ?? 0).toDouble(),
      discount: (json["Discount"] ?? 0).toDouble(),
      finalAmount: (json["FinalAmount"] ?? 0).toDouble(),
    );
  }
}