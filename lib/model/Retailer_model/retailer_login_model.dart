class RetailerModel {
  final String retailerId;
  final String name;
  final String email;
  final String phone;
  final String businessAddress;
  final String profile;

  RetailerModel({
    required this.retailerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessAddress,
    required this.profile,
  });

  factory RetailerModel.fromJson(Map<String, dynamic> json) {
    return RetailerModel(
      retailerId: json['RetailerID']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      businessAddress: json['businessAddress']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RetailerID': retailerId,
      'name': name,
      'email': email,
      'phone': phone,
      'businessAddress': businessAddress,
      'profile': profile,
    };
  }
}