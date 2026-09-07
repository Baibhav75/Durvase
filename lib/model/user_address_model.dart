class UserAddressResponse {
  final bool status;
  final UserAddress? data;

  UserAddressResponse({
    required this.status,
    this.data,
  });

  factory UserAddressResponse.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] ?? json['Status'];
    final bool isSuccess = statusVal == true || statusVal == 'true' || statusVal == 1;

    UserAddress? addressData;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      addressData = UserAddress.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['Data'] != null && json['Data'] is Map<String, dynamic>) {
      addressData = UserAddress.fromJson(json['Data'] as Map<String, dynamic>);
    }

    return UserAddressResponse(
      status: isSuccess,
      data: addressData,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data?.toJson(),
      };
}

class UserAddress {
  final String country;
  final String state;
  final String district;
  final String block;
  final String address;
  final String purpose;

  UserAddress({
    this.country = '',
    this.state = '',
    this.district = '',
    this.block = '',
    this.address = '',
    this.purpose = '',
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      country: json['Country']?.toString() ?? json['country']?.toString() ?? '',
      state: json['State']?.toString() ?? json['state']?.toString() ?? '',
      district: json['District']?.toString() ?? json['district']?.toString() ?? '',
      block: json['Block']?.toString() ?? json['block']?.toString() ?? '',
      address: json['Address']?.toString() ?? json['address']?.toString() ?? '',
      purpose: json['Purpose']?.toString() ?? json['purpose']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'Country': country,
        'State': state,
        'District': district,
        'Block': block,
        'Address': address,
        'Purpose': purpose,
      };

  /// Returns full formatted comma-separated address
  String get formattedAddress {
    final parts = [address, block, district, state, country]
        .where((p) => p.trim().isNotEmpty)
        .map((p) => p.trim())
        .toList();
    return parts.join(', ');
  }

  bool get isEmpty =>
      country.isEmpty &&
      state.isEmpty &&
      district.isEmpty &&
      block.isEmpty &&
      address.isEmpty;

  bool get isNotEmpty => !isEmpty;
}
