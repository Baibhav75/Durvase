class GetAllRetailerResponse {
  final RetailerHeader? header;
  final List<RetailerItem> data;

  GetAllRetailerResponse({
    this.header,
    this.data = const [],
  });

  factory GetAllRetailerResponse.fromJson(Map<String, dynamic> json) {
    return GetAllRetailerResponse(
      header: json['Header'] != null && json['Header'] is Map<String, dynamic>
          ? RetailerHeader.fromJson(json['Header'] as Map<String, dynamic>)
          : null,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .map((e) => RetailerItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class RetailerHeader {
  final bool? success;
  final int? totalCount;

  RetailerHeader({
    this.success,
    this.totalCount,
  });

  factory RetailerHeader.fromJson(Map<String, dynamic> json) {
    return RetailerHeader(
      success: json['success'] == true || json['success'] == 'true',
      totalCount: json['totalCount'] is int
          ? json['totalCount']
          : int.tryParse(json['totalCount']?.toString() ?? ''),
    );
  }
}

class RetailerItem {
  static const String imageBaseUrl = 'https://durvasaayurved.online';

  final int? id;
  final String? retailerId;
  final String? status;
  final String? retailerCode;
  final String? joinDate;
  final String? gender;
  final String? name;
  final String? fatherName;
  final String? address;
  final String? mobile;
  final String? mobileAlt;
  final String? email;
  final String? postOffice;
  final String? country;
  final String? state;
  final String? district;
  final String? block;
  final String? employeeType;
  final String? createdAt;
  final String? updatedAt;
  final String? image;
  final String? emergenceNo;
  final String? billedGroup;

  RetailerItem({
    this.id,
    this.retailerId,
    this.status,
    this.retailerCode,
    this.joinDate,
    this.gender,
    this.name,
    this.fatherName,
    this.address,
    this.mobile,
    this.mobileAlt,
    this.email,
    this.postOffice,
    this.country,
    this.state,
    this.district,
    this.block,
    this.employeeType,
    this.createdAt,
    this.updatedAt,
    this.image,
    this.emergenceNo,
    this.billedGroup,
  });

  factory RetailerItem.fromJson(Map<String, dynamic> json) {
    return RetailerItem(
      id: json['Id'] is int
          ? json['Id']
          : (json['id'] is int
              ? json['id']
              : int.tryParse(json['Id']?.toString() ?? json['id']?.toString() ?? '')),
      retailerId: json['RetailerId']?.toString() ??
          json['retailerId']?.toString() ??
          json['retailerID']?.toString(),
      status: json['Status']?.toString() ?? json['status']?.toString() ?? 'Active',
      retailerCode: json['RetailerCode']?.toString() ?? json['retailerCode']?.toString(),
      joinDate: json['JoinDate']?.toString() ?? json['joinDate']?.toString(),
      gender: json['Gender']?.toString() ?? json['gender']?.toString(),
      name: json['Name']?.toString() ??
          json['name']?.toString() ??
          (json['RetailerId'] != null ? 'Retailer ${json['RetailerId']}' : 'Retailer Partner'),
      fatherName: json['FatherName']?.toString() ?? json['fatherName']?.toString(),
      address: json['Address']?.toString() ??
          json['address']?.toString() ??
          json['businessAddress']?.toString(),
      mobile: json['Mobile']?.toString() ??
          json['mobile']?.toString() ??
          json['phone']?.toString(),
      mobileAlt: json['MobileAlt']?.toString() ?? json['mobileAlt']?.toString(),
      email: json['Email']?.toString() ?? json['email']?.toString(),
      postOffice: json['PostOffice']?.toString() ?? json['postOffice']?.toString(),
      country: json['Country']?.toString() ?? json['country']?.toString() ?? 'India',
      state: json['State']?.toString() ?? json['state']?.toString(),
      district: json['District']?.toString() ?? json['district']?.toString(),
      block: json['Block']?.toString() ?? json['block']?.toString(),
      employeeType: json['EmployeeType']?.toString() ??
          json['employeeType']?.toString() ??
          'Retailer',
      createdAt: json['CreatedAt']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['UpdatedAt']?.toString() ?? json['updatedAt']?.toString(),
      image: json['Image']?.toString() ?? json['image']?.toString() ?? json['profile']?.toString(),
      emergenceNo: json['EmergenceNo']?.toString() ?? json['emergenceNo']?.toString(),
      billedGroup: json['BilledGroup']?.toString() ?? json['billedGroup']?.toString(),
    );
  }

  String get resolvedImageUrl {
    if (image == null || image!.trim().isEmpty) return '';
    final path = image!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$imageBaseUrl$path';
    return '$imageBaseUrl/$path';
  }

  bool get isActive {
    if (status == null) return true;
    final lower = status!.trim().toLowerCase();
    return lower == 'active' || lower == 'true' || lower == '1';
  }

  String get displayLocation {
    final List<String> parts = [];
    if (district != null && district!.trim().isNotEmpty) parts.add(district!.trim());
    if (state != null && state!.trim().isNotEmpty) parts.add(state!.trim());
    if (parts.isEmpty) return country ?? 'India';
    return parts.join(', ');
  }
}
