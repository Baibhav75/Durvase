class MyOrderModel {
  final dynamic id;
  final dynamic orderID;
  final String dealerID;
  final String productID;
  final String productName;
  final String uniqueID;
  final dynamic listedPrice;
  final dynamic sellingPrice;
  final dynamic qty;
  final String image;
  final dynamic gst;
  final String productPoint;
  final dynamic productPercentage;
  final String userId;

  MyOrderModel({
    required this.id,
    required this.orderID,
    required this.dealerID,
    required this.productID,
    required this.productName,
    required this.uniqueID,
    required this.listedPrice,
    required this.sellingPrice,
    required this.qty,
    required this.image,
    required this.gst,
    required this.productPoint,
    required this.productPercentage,
    required this.userId,
  });

  factory MyOrderModel.fromJson(Map<String, dynamic> json) {
    return MyOrderModel(
      id: json['ID'] ?? json['Id'] ?? json['id'],
      orderID: json['OrderID'] ?? json['OrderId'] ?? json['order_id'] ?? json['orderId'],
      dealerID: json['DealerID']?.toString() ?? json['DealerId']?.toString() ?? json['dealer_id']?.toString() ?? '',
      productID: json['ProductID']?.toString() ?? json['ProductId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['ProductName']?.toString() ?? json['product_name']?.toString() ?? json['Name']?.toString() ?? json['name']?.toString() ?? 'Product',
      uniqueID: json['UniqueID']?.toString() ?? json['UniqueId']?.toString() ?? json['unique_id']?.toString() ?? '',
      listedPrice: json['listedPrice'] ?? json['ListedPrice'] ?? json['MRP'] ?? json['mrp'],
      sellingPrice: json['SellingPrice'] ?? json['sellingPrice'] ?? json['Price'] ?? json['price'],
      qty: json['QTY'] ?? json['Qty'] ?? json['Quantity'] ?? json['quantity'] ?? 1,
      image: json['Image']?.toString() ?? json['image']?.toString() ?? json['ImagePath']?.toString() ?? '',
      gst: json['GST'] ?? json['gst'],
      productPoint: json['ProductPoint']?.toString() ?? json['productPoint']?.toString() ?? '',
      productPercentage: json['ProductPercentage'] ?? json['productPercentage'],
      userId: json['UserId']?.toString() ?? json['UserID']?.toString() ?? json['userId']?.toString() ?? '',
    );
  }

  double get sellingPriceValue {
    if (sellingPrice == null) return 0.0;
    if (sellingPrice is num) return (sellingPrice as num).toDouble();
    return double.tryParse(sellingPrice.toString()) ?? 0.0;
  }

  double get listedPriceValue {
    if (listedPrice == null) return sellingPriceValue;
    if (listedPrice is num) return (listedPrice as num).toDouble();
    return double.tryParse(listedPrice.toString()) ?? sellingPriceValue;
  }

  int get qtyValue {
    if (qty == null) return 1;
    if (qty is int) return qty as int;
    if (qty is num) return (qty as num).toInt();
    return int.tryParse(qty.toString()) ?? 1;
  }

  double get totalAmount => sellingPriceValue * (qtyValue > 0 ? qtyValue : 1);

  String get formattedImageUrl {
    final raw = image.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return 'https://durvasaayurved.com$raw';
    return 'https://durvasaayurved.com/$raw';
  }

  int get discountPercentage {
    if (listedPriceValue > sellingPriceValue && listedPriceValue > 0) {
      return (((listedPriceValue - sellingPriceValue) / listedPriceValue) * 100).round();
    }
    return 0;
  }
}