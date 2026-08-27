import 'dart:convert';

class PlaceOrderRequest {
  final String productId;
  final String? retailerId;
  final String? dealerId;
  final String userId;
  final String shippingAddress;
  final String paymentMode;

  PlaceOrderRequest({
    required this.productId,
    this.retailerId,
    this.dealerId,
    required this.userId,
    required this.shippingAddress,
    required this.paymentMode,
  });

  Map<String, dynamic> toJson() {
    return {
      "ProductID": productId,
      "RetailerId": retailerId ?? "",
      "DealerId": dealerId ?? "",
      "UserId": userId,
      "ShippingAddress": shippingAddress,
      "PaymenMode": paymentMode,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory PlaceOrderRequest.fromJson(Map<String, dynamic> json) {
    return PlaceOrderRequest(
      productId: json["ProductID"]?.toString() ?? "",
      retailerId: json["RetailerId"]?.toString(),
      dealerId: json["DealerId"]?.toString(),
      userId: json["UserId"]?.toString() ?? "",
      shippingAddress: json["ShippingAddress"]?.toString() ?? "",
      paymentMode: json["PaymenMode"]?.toString() ?? json["PaymentMode"]?.toString() ?? "COD",
    );
  }
}

class PlaceOrderResponse {
  final bool status;
  final String message;
  final String? orderId;
  final dynamic data;

  PlaceOrderResponse({
    required this.status,
    required this.message,
    this.orderId,
    this.data,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponse(
      status: json["Status"] == true || json["status"] == true || json["success"] == true,
      message: json["Message"]?.toString() ?? json["message"]?.toString() ?? "",
      orderId: json["OrderId"]?.toString() ?? json["order_id"]?.toString() ?? json["id"]?.toString(),
      data: json["Data"] ?? json["data"],
    );
  }
}
