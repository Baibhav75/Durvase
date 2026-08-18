double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  return double.tryParse(val.toString()) ?? 0.0;
}

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is num) return val.toInt();
  return int.tryParse(val.toString()) ?? 0;
}

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
    final customer = json["Customer"] is Map ? json["Customer"] : {};
    final shipping = json["ShippingAddress"] is Map ? json["ShippingAddress"] : {};
    final wallet = json["Wallet"] is Map ? json["Wallet"] : {};

    return CheckoutResponse(
      status: json["Status"] == true || json["status"] == true,
      message: json["Message"]?.toString() ?? json["message"]?.toString() ?? "",
      user: CheckoutUser(
        fullName: customer["Name"]?.toString() ?? customer["FullName"]?.toString() ?? "",
        mobile: customer["Mobile"]?.toString() ?? "",
        email: customer["Email"]?.toString() ?? "",
        permanentAddress: shipping["Address"]?.toString() ?? shipping["PermanentAddress"]?.toString() ?? "",
        city: shipping["District"]?.toString() ?? shipping["City"]?.toString() ?? "",
        state: shipping["State"]?.toString() ?? "",
      ),
      cart: (json["CartItems"] is List
              ? (json["CartItems"] as List)
              : (json["Cart"] is List ? (json["Cart"] as List) : []))
          .map((e) => CartItem.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList(),
      summary: Summary.fromJson(json["OrderSummary"] is Map
          ? (json["OrderSummary"] as Map<String, dynamic>)
          : (json["Summary"] is Map ? Map<String, dynamic>.from(json["Summary"]) : {})),
      isEligibleToUsePoint: wallet["Eligible"] == true || wallet["eligible"] == true,
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
      fullName: json["FullName"]?.toString() ?? json["Name"]?.toString() ?? "",
      mobile: json["Mobile"]?.toString() ?? "",
      email: json["Email"]?.toString() ?? "",
      permanentAddress: json["PermanentAddress"]?.toString() ?? json["Address"]?.toString() ?? "",
      city: json["City"]?.toString() ?? json["District"]?.toString() ?? "",
      state: json["State"]?.toString() ?? "",
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
      id: _toInt(json["Id"] ?? json["ID"]),
      productID: json["ProductID"]?.toString() ?? json["ProductId"]?.toString() ?? "",
      productName: json["ProductName"]?.toString() ?? "",
      uniqueID: json["UniqueID"]?.toString() ?? json["UniqueId"]?.toString() ?? "",
      listedPrice: _toDouble(json["ListedPrice"] ?? json["MRP"] ?? json["SellingPrice"]),
      sellingPrice: _toDouble(json["SellingPrice"] ?? json["Price"]),
      qty: _toInt(json["Qty"] ?? json["QTY"] ?? json["Quantity"] ?? 1),
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
    final double listed = _toDouble(json["ListedTotal"] ?? json["TotalListedPrice"] ?? json["MRP"]);
    final double selling = _toDouble(json["SellingTotal"] ?? json["TotalSellingPrice"] ?? json["FinalAmount"]);
    final double disc = _toDouble(json["Discount"] ?? (listed > selling ? listed - selling : 0.0));
    final double finalAmt = _toDouble(json["FinalAmount"] ?? json["TotalAmount"] ?? selling);

    return Summary(
      totalListedPrice: listed,
      totalSellingPrice: selling,
      discount: disc,
      finalAmount: finalAmt,
    );
  }
}