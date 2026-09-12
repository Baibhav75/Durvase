/// Request model for applying visitor/retailer discount
/// API Endpoint: POST https://durvasaayurved.com/api/VisiterOfferDiscount
class VisiterOfferDiscountRequest {
  final String visiterId;
  final double discountPercentage;

  VisiterOfferDiscountRequest({
    required this.visiterId,
    required this.discountPercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'VisiterId': visiterId.trim(),
      'DiscountPercentage': discountPercentage,
    };
  }
}

/// Response model returned by POST https://durvasaayurved.com/api/VisiterOfferDiscount
class VisiterOfferDiscountResponse {
  final String? message;
  final String? visiterId;
  final double? savedDiscountPercentage;
  final int? updatedRecordsCount;
  final bool isSuccess;

  VisiterOfferDiscountResponse({
    this.message,
    this.visiterId,
    this.savedDiscountPercentage,
    this.updatedRecordsCount,
    this.isSuccess = true,
  });

  factory VisiterOfferDiscountResponse.fromJson(Map<String, dynamic> json, {int statusCode = 200}) {
    final rawMessage = json['Message'] ?? json['message'] ?? json['msg'];
    final rawVisiterId = json['VisiterId'] ??
        json['visiterId'] ??
        json['RetailerId'] ??
        json['retailerId'] ??
        json['UserId'] ??
        json['userId'];

    final rawDiscount = json['SavedDiscountPercentage'] ??
        json['savedDiscountPercentage'] ??
        json['DiscountPercentage'] ??
        json['discountPercentage'];

    final rawCount = json['UpdatedRecordsCount'] ??
        json['updatedRecordsCount'] ??
        json['UpdatedItemsCount'] ??
        json['updatedItemsCount'];

    double? parsedDiscount;
    if (rawDiscount is num) {
      parsedDiscount = rawDiscount.toDouble();
    } else if (rawDiscount != null) {
      parsedDiscount = double.tryParse(rawDiscount.toString().replaceAll('%', '').trim());
    }

    int? parsedCount;
    if (rawCount is int) {
      parsedCount = rawCount;
    } else if (rawCount != null) {
      parsedCount = int.tryParse(rawCount.toString());
    }

    final bool success = (statusCode == 200 || statusCode == 201) &&
        (rawMessage == null || !rawMessage.toString().toLowerCase().contains('error'));

    return VisiterOfferDiscountResponse(
      message: rawMessage?.toString(),
      visiterId: rawVisiterId?.toString(),
      savedDiscountPercentage: parsedDiscount,
      updatedRecordsCount: parsedCount,
      isSuccess: success,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Message': message,
      'VisiterId': visiterId,
      'SavedDiscountPercentage': savedDiscountPercentage,
      'UpdatedRecordsCount': updatedRecordsCount,
    };
  }
}

/// Response model for GET https://durvasaayurved.com/api/GetDiscountByVisiter?VisiterId=VTR807825
/// Schema:
/// {
///   "Status": true,
///   "Message": "Discount retrieved successfully.",
///   "VisiterId": "VTR807825",
///   "DiscountPercentage": "10%"
/// }
class GetDiscountByVisiterResponse {
  final bool status;
  final String? message;
  final String? visiterId;
  final String? discountPercentage;

  GetDiscountByVisiterResponse({
    this.status = true,
    this.message,
    this.visiterId,
    this.discountPercentage,
  });

  /// Parse discount percentage as double (e.g., 10.0 from "10%" or "10.5%")
  double get discountValue {
    if (discountPercentage == null || discountPercentage!.trim().isEmpty) {
      return 0.0;
    }
    final clean = discountPercentage!.replaceAll('%', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  /// Formatted string with '%' (e.g., "10%" or "10.5%")
  String get formattedPercentage {
    final val = discountValue;
    if (val <= 0) return '0%';
    if (val == val.roundToDouble()) {
      return '${val.toInt()}%';
    }
    return '${val.toStringAsFixed(1)}%';
  }

  /// Whether valid discount exists (> 0%)
  bool get hasDiscount => status && discountValue > 0;

  factory GetDiscountByVisiterResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['Status'] ?? json['status'] ?? json['Success'] ?? json['success'];
    bool parsedStatus = true;
    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus != null) {
      final s = rawStatus.toString().toLowerCase().trim();
      parsedStatus = s == 'true' || s == '1' || s == 'success';
    }

    final rawMessage = json['Message'] ?? json['message'] ?? json['msg'];
    final rawVisiterId = json['VisiterId'] ??
        json['visiterId'] ??
        json['RetailerId'] ??
        json['retailerId'] ??
        json['UserId'] ??
        json['userId'];

    final rawDiscount = json['DiscountPercentage'] ??
        json['discountPercentage'] ??
        json['discount_percentage'] ??
        json['SavedDiscountPercentage'] ??
        json['savedDiscountPercentage'] ??
        json['Discount'] ??
        json['discount'];

    return GetDiscountByVisiterResponse(
      status: parsedStatus,
      message: rawMessage?.toString(),
      visiterId: rawVisiterId?.toString(),
      discountPercentage: rawDiscount?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Message': message,
      'VisiterId': visiterId,
      'DiscountPercentage': discountPercentage,
    };
  }

  /// Converts this response to a RetailerDiscountModel instance
  RetailerDiscountModel toRetailerDiscountModel() {
    return RetailerDiscountModel(
      status: status,
      retailerId: visiterId,
      discountPercentage: discountPercentage,
      message: message,
    );
  }
}

class RetailerDiscountModel {
  final bool status;
  final String? retailerId;
  final String? discountPercentage;
  final String? message;
  final int? updatedItemsCount;

  RetailerDiscountModel({
    this.status = true,
    this.retailerId,
    this.discountPercentage,
    this.message,
    this.updatedItemsCount,
  });

  /// Parse discount percentage as double (e.g., 10.0)
  double get discountValue {
    if (discountPercentage == null || discountPercentage!.trim().isEmpty) {
      return 0.0;
    }
    final clean = discountPercentage!.replaceAll('%', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  /// Formatted string with '%' (e.g., "10%" or "10.5%")
  String get formattedPercentage {
    final val = discountValue;
    if (val <= 0) return '0%';
    if (val == val.roundToDouble()) {
      return '${val.toInt()}%';
    }
    return '${val.toStringAsFixed(1)}%';
  }

  /// Whether valid discount exists (> 0%)
  bool get hasDiscount => status && discountValue > 0;

  factory RetailerDiscountModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['Status'] ?? json['status'] ?? json['Success'] ?? json['success'];
    bool parsedStatus = true;
    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus != null) {
      final s = rawStatus.toString().toLowerCase().trim();
      parsedStatus = s == 'true' || s == '1' || s == 'success';
    }

    // Flexible parsing for various API response keys
    final rawDiscount = json['DiscountPercentage'] ??
        json['discountPercentage'] ??
        json['discount_percentage'] ??
        json['SavedDiscountPercentage'] ??
        json['savedDiscountPercentage'] ??
        json['Discount'] ??
        json['discount'] ??
        json['DiscountPercent'] ??
        json['discountPercent'];

    final rawRetailerId = json['VisiterId'] ??
        json['visiterId'] ??
        json['visiter_id'] ??
        json['RetailerId'] ??
        json['retailerId'] ??
        json['retailer_id'] ??
        json['UserID'] ??
        json['UserId'] ??
        json['userId'];

    final rawMessage = json['Message'] ?? json['message'] ?? json['msg'];

    final rawCount = json['UpdatedRecordsCount'] ??
        json['updatedRecordsCount'] ??
        json['UpdatedItemsCount'] ??
        json['updatedItemsCount'] ??
        json['updated_items_count'] ??
        json['ItemsCount'] ??
        json['itemsCount'];

    return RetailerDiscountModel(
      status: parsedStatus,
      retailerId: rawRetailerId?.toString(),
      discountPercentage: rawDiscount?.toString(),
      message: rawMessage?.toString(),
      updatedItemsCount: rawCount is int
          ? rawCount
          : int.tryParse(rawCount?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'VisiterId': retailerId,
      'RetailerId': retailerId,
      'DiscountPercentage': discountPercentage,
      'Message': message,
      'UpdatedItemsCount': updatedItemsCount,
    };
  }
}