import 'dart:convert';

class PlaceOrderRequest {
  final String productId;
  final String retailerId;
  final String dealerId;
  final String userId;
  final String paymentType;
  final String asmId;
  final String? shippingAddress;

  PlaceOrderRequest({
    required this.productId,
    this.retailerId = "",
    this.dealerId = "",
    required this.userId,
    required this.paymentType,
    this.asmId = "",
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      "ProductID": productId,
      "RetailerId": retailerId,
      "DealerID": dealerId,
      "UserId": userId,
      "PaymentType": paymentType,
      "ASMId": asmId,
      if (shippingAddress != null && shippingAddress!.isNotEmpty)
        "ShippingAddress": shippingAddress,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory PlaceOrderRequest.fromJson(Map<String, dynamic> json) {
    return PlaceOrderRequest(
      productId: json["ProductID"]?.toString() ?? "",
      retailerId: json["RetailerId"]?.toString() ?? "",
      dealerId: json["DealerID"]?.toString() ?? json["DealerId"]?.toString() ?? "",
      userId: json["UserId"]?.toString() ?? "",
      paymentType: json["PaymentType"]?.toString() ?? json["PaymenMode"]?.toString() ?? json["PaymentMode"]?.toString() ?? "COD",
      asmId: json["ASMId"]?.toString() ?? json["AsmId"]?.toString() ?? "",
      shippingAddress: json["ShippingAddress"]?.toString(),
    );
  }
}

class PlaceOrderResponse {
  final bool status;
  final String message;
  final String? orderType;
  final String? savedId;
  final String? userId;
  final double? totalAmount;
  final String? orderDate;
  final String? orderId;

  PlaceOrderResponse({
    required this.status,
    required this.message,
    this.orderType,
    this.savedId,
    this.userId,
    this.totalAmount,
    this.orderDate,
    this.orderId,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponse(
      status: json["status"] == true || json["Status"] == true || json["success"] == true,
      message: json["message"]?.toString() ?? json["Message"]?.toString() ?? "",
      orderType: json["orderType"]?.toString() ?? json["OrderType"]?.toString(),
      savedId: json["savedId"]?.toString() ?? json["SavedId"]?.toString(),
      userId: json["userId"]?.toString() ?? json["UserId"]?.toString(),
      totalAmount: double.tryParse(json["totalAmount"]?.toString() ?? json["TotalAmount"]?.toString() ?? ""),
      orderDate: json["orderDate"]?.toString() ?? json["OrderDate"]?.toString(),
      orderId: json["orderId"]?.toString() ?? json["OrderId"]?.toString() ?? json["id"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      if (orderType != null) "orderType": orderType,
      if (savedId != null) "savedId": savedId,
      if (userId != null) "userId": userId,
      if (totalAmount != null) "totalAmount": totalAmount,
      if (orderDate != null) "orderDate": orderDate,
      if (orderId != null) "orderId": orderId,
    };
  }
}
