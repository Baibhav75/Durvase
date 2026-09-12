class RetailerOrderHistoryResponse {
  final bool status;
  final String message;
  final List<RetailerOrderItemModel> data;

  RetailerOrderHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RetailerOrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['Data'] ?? json['data'];
    List<RetailerOrderItemModel> items = [];
    if (rawList is List) {
      items = rawList
          .whereType<Map<String, dynamic>>()
          .map((item) => RetailerOrderItemModel.fromJson(item))
          .toList();
    }

    return RetailerOrderHistoryResponse(
      status: json['Status'] == true || json['status'] == true,
      message: json['Message']?.toString() ?? json['message']?.toString() ?? '',
      data: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'Status': status,
        'Message': message,
        'Data': data.map((x) => x.toJson()).toList(),
      };
}

class RetailerOrderItemModel {
  final int id;
  final String? orderId;
  final String productId;
  final String productName;
  final String image;
  final int qty;
  final double listedPrice;
  final double sellingPrice;
  final String paymentType;
  final String routeType;
  final String dealerId;
  final String asmId;
  final String? orderStatus;

  RetailerOrderItemModel({
    required this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.image,
    required this.qty,
    required this.listedPrice,
    required this.sellingPrice,
    required this.paymentType,
    required this.routeType,
    required this.dealerId,
    required this.asmId,
    this.orderStatus,
  });

  factory RetailerOrderItemModel.fromJson(Map<String, dynamic> json) {
    // Safe int parsing
    int parsedId = 0;
    final rawId = json['ID'] ?? json['Id'] ?? json['id'];
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }

    // Safe QTY parsing
    int parsedQty = 1;
    final rawQty = json['QTY'] ?? json['Qty'] ?? json['qty'] ?? json['Quantity'] ?? json['quantity'];
    if (rawQty is int) {
      parsedQty = rawQty;
    } else if (rawQty is num) {
      parsedQty = rawQty.toInt();
    } else if (rawQty != null) {
      parsedQty = int.tryParse(rawQty.toString()) ?? 1;
    }

    // Safe double parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return RetailerOrderItemModel(
      id: parsedId,
      orderId: json['OrderID']?.toString() ?? json['OrderId']?.toString() ?? json['order_id']?.toString(),
      productId: json['ProductID']?.toString() ?? json['ProductId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['ProductName']?.toString() ?? json['product_name']?.toString() ?? 'Ayurvedic Product',
      image: json['Image']?.toString() ?? json['image']?.toString() ?? '',
      qty: parsedQty > 0 ? parsedQty : 1,
      listedPrice: parseDouble(json['listedPrice'] ?? json['ListedPrice'] ?? json['MRP'] ?? json['mrp']),
      sellingPrice: parseDouble(json['SellingPrice'] ?? json['sellingPrice'] ?? json['Price'] ?? json['price']),
      paymentType: json['PaymentType']?.toString() ?? json['payment_type']?.toString() ?? 'COD',
      routeType: json['RouteType']?.toString() ?? json['route_type']?.toString() ?? 'Dealer',
      dealerId: json['DealerID']?.toString() ?? json['DealerId']?.toString() ?? json['dealer_id']?.toString() ?? '',
      asmId: json['ASMId']?.toString() ?? json['AsmId']?.toString() ?? json['asm_id']?.toString() ?? '',
      orderStatus: json['OrderStatus']?.toString() ?? json['order_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ID': id,
        'OrderID': orderId,
        'ProductID': productId,
        'ProductName': productName,
        'Image': image,
        'QTY': qty,
        'listedPrice': listedPrice,
        'SellingPrice': sellingPrice,
        'PaymentType': paymentType,
        'RouteType': routeType,
        'DealerID': dealerId,
        'ASMId': asmId,
        'OrderStatus': orderStatus,
      };

  // Calculated getters
  double get totalAmount => sellingPrice * qty;

  double get totalListedAmount => (listedPrice > 0 ? listedPrice : sellingPrice) * qty;

  double get totalSavings {
    if (listedPrice > sellingPrice) {
      return (listedPrice - sellingPrice) * qty;
    }
    return 0.0;
  }

  int get discountPercent {
    if (listedPrice > sellingPrice && listedPrice > 0) {
      return (((listedPrice - sellingPrice) / listedPrice) * 100).round();
    }
    return 0;
  }

  String get displayOrderId {
    if (orderId != null && orderId!.trim().isNotEmpty && orderId!.trim().toLowerCase() != 'null') {
      return orderId!.trim();
    }
    return 'ORD-$id';
  }

  String get displayStatus {
    if (orderStatus != null && orderStatus!.trim().isNotEmpty && orderStatus!.trim().toLowerCase() != 'null') {
      return orderStatus!.trim();
    }
    return 'Confirmed';
  }

  String get formattedImageUrl {
    final raw = image.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return 'https://durvasaayurved.com$raw';
    return 'https://durvasaayurved.com/$raw';
  }
}
