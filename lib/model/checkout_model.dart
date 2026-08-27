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
    final customer = json["Customer"] is Map ? json["Customer"] : (json["User"] is Map ? json["User"] : {});
    final shipping = json["ShippingAddress"] is Map ? json["ShippingAddress"] : (json["Address"] is Map ? json["Address"] : {});
    final wallet = json["Wallet"] is Map ? json["Wallet"] : {};

    return CheckoutResponse(
      status: json["Status"] == true || json["status"] == true,
      message: json["Message"]?.toString() ?? json["message"]?.toString() ?? "",
      user: CheckoutUser(
        fullName: customer["FullName"]?.toString() ?? customer["Name"]?.toString() ?? customer["name"]?.toString() ?? "",
        mobile: customer["Mobile"]?.toString() ?? customer["mobile"]?.toString() ?? "",
        email: customer["Email"]?.toString() ?? customer["email"]?.toString() ?? "",
        permanentAddress: shipping["PermanentAddress"]?.toString() ?? shipping["Address"]?.toString() ?? customer["Address"]?.toString() ?? customer["address"]?.toString() ?? "",
        city: shipping["District"]?.toString() ?? shipping["City"]?.toString() ?? customer["City"]?.toString() ?? customer["district"]?.toString() ?? "",
        state: shipping["State"]?.toString() ?? customer["State"]?.toString() ?? customer["state"]?.toString() ?? "",
      ),
      cart: (json["CartItems"] is List
              ? (json["CartItems"] as List)
              : (json["Cart"] is List
                  ? (json["Cart"] as List)
                  : (json["data"] is List ? (json["data"] as List) : [])))
          .map((e) => CartItem.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e)))
          .toList(),
      summary: Summary.fromJson(json["OrderSummary"] is Map
          ? (json["OrderSummary"] as Map<String, dynamic>)
          : (json["Summary"] is Map ? Map<String, dynamic>.from(json["Summary"]) : {})),
      isEligibleToUsePoint: wallet["Eligible"] == true || wallet["eligible"] == true || json["WalletEligible"] == true,
    );
  }

  factory CheckoutResponse.fromCartItemsAndUser({
    required List<CartItem> cartItems,
    required CheckoutUser user,
    double? subtotal,
    double? totalMrp,
    bool isEligibleToUsePoint = false,
  }) {
    double calculatedSelling = subtotal ?? 0.0;
    double calculatedMrp = totalMrp ?? 0.0;

    if (calculatedSelling == 0.0 && cartItems.isNotEmpty) {
      for (var item in cartItems) {
        calculatedSelling += (item.sellingPrice * (item.qty > 0 ? item.qty : 1));
        calculatedMrp += ((item.listedPrice > 0 ? item.listedPrice : item.sellingPrice) * (item.qty > 0 ? item.qty : 1));
      }
    }

    if (calculatedMrp == 0.0) {
      calculatedMrp = calculatedSelling;
    }

    final double discount = calculatedMrp > calculatedSelling ? (calculatedMrp - calculatedSelling) : 0.0;

    return CheckoutResponse(
      status: true,
      message: "Success",
      user: user,
      cart: cartItems,
      summary: Summary(
        totalListedPrice: calculatedMrp,
        totalSellingPrice: calculatedSelling,
        discount: discount,
        finalAmount: calculatedSelling,
      ),
      isEligibleToUsePoint: isEligibleToUsePoint,
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
      fullName: json["FullName"]?.toString() ?? json["Name"]?.toString() ?? json["name"]?.toString() ?? "",
      mobile: json["Mobile"]?.toString() ?? json["mobile"]?.toString() ?? "",
      email: json["Email"]?.toString() ?? json["email"]?.toString() ?? "",
      permanentAddress: json["PermanentAddress"]?.toString() ?? json["Address"]?.toString() ?? json["address"]?.toString() ?? "",
      city: json["City"]?.toString() ?? json["District"]?.toString() ?? json["district"]?.toString() ?? json["city"]?.toString() ?? "",
      state: json["State"]?.toString() ?? json["state"]?.toString() ?? "",
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
    final String pId = json["ProductID"]?.toString() ??
        json["ProductId"]?.toString() ??
        json["product_id"]?.toString() ??
        json["Product_Id"]?.toString() ??
        json["ProId"]?.toString() ??
        json["proId"]?.toString() ??
        json["UniqueID"]?.toString() ??
        json["UniqueId"]?.toString() ??
        json["unique_id"]?.toString() ??
        "";

    final int rowId = _toInt(json["Id"] ?? json["ID"] ?? json["id"]);

    return CartItem(
      id: rowId,
      productID: pId.isNotEmpty ? pId : (rowId > 0 ? rowId.toString() : ""),
      productName: json["ProductName"]?.toString() ??
          json["product_name"]?.toString() ??
          json["Name"]?.toString() ??
          json["name"]?.toString() ??
          "Product",
      uniqueID: json["UniqueID"]?.toString() ??
          json["UniqueId"]?.toString() ??
          json["unique_id"]?.toString() ??
          pId,
      listedPrice: _toDouble(json["ListedPrice"] ??
          json["listedPrice"] ??
          json["MRP"] ??
          json["mrp"] ??
          json["SellingPrice"] ??
          json["Price"]),
      sellingPrice: _toDouble(json["SellingPrice"] ??
          json["sellingPrice"] ??
          json["Price"] ??
          json["price"] ??
          0),
      qty: _toInt(json["Qty"] ??
          json["QTY"] ??
          json["Quantity"] ??
          json["quantity"] ??
          json["qty"] ??
          1),
      image: json["Image"]?.toString() ??
          json["image"]?.toString() ??
          json["ImagePath"]?.toString() ??
          "",
      gst: json["GST"]?.toString() ?? json["gst"]?.toString(),
      productPoint: json["ProductPoint"]?.toString() ??
          json["productPoint"]?.toString() ??
          json["ProductPoints"]?.toString() ??
          "",
      productPercentage: json["ProductPercentage"]?.toString() ??
          json["productPercentage"]?.toString(),
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
    final double listed = _toDouble(json["ListedTotal"] ??
        json["TotalListedPrice"] ??
        json["totalListedPrice"] ??
        json["MRP"] ??
        json["mrp"]);
    final double selling = _toDouble(json["SellingTotal"] ??
        json["TotalSellingPrice"] ??
        json["totalSellingPrice"] ??
        json["FinalAmount"] ??
        json["finalAmount"] ??
        json["Price"] ??
        json["price"]);
    final double disc = _toDouble(json["Discount"] ??
        json["discount"] ??
        (listed > selling ? listed - selling : 0.0));
    final double finalAmt = _toDouble(json["FinalAmount"] ??
        json["finalAmount"] ??
        json["TotalAmount"] ??
        json["totalAmount"] ??
        selling);

    return Summary(
      totalListedPrice: listed,
      totalSellingPrice: selling,
      discount: disc,
      finalAmount: finalAmt,
    );
  }
}