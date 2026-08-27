class DealerModel {
  final String dealerId;
  final String name;
  final String email;
  final String phone;
  final String gstNumber;
  final String businessAddress;

  DealerModel({
    required this.dealerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.gstNumber,
    required this.businessAddress,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      dealerId: json['DealerID']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gstNumber: json['gstNumber']?.toString() ?? '',
      businessAddress: json['businessAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DealerID': dealerId,
      'name': name,
      'email': email,
      'phone': phone,
      'gstNumber': gstNumber,
      'businessAddress': businessAddress,
    };
  }
}