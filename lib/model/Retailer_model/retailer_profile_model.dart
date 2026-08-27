import 'package:intl/intl.dart';

class RetailerProfileResponse {
  final dynamic message;
  final dynamic status;
  final RetailerProfileData? data;

  RetailerProfileResponse({
    this.message,
    this.status,
    this.data,
  });

  factory RetailerProfileResponse.fromJson(Map<String, dynamic> json) {
    return RetailerProfileResponse(
      message: json['message'],
      status: json['status'],
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RetailerProfileData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class RetailerProfileData {
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

  RetailerProfileData({
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

  factory RetailerProfileData.fromJson(Map<String, dynamic> json) {
    return RetailerProfileData(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      retailerId: json['retailerId']?.toString() ?? json['retailerID']?.toString(),
      status: json['status']?.toString() ?? (json['isActive'] == true || json['isActive'] == 1 ? 'Active' : null),
      retailerCode: json['retailerCode']?.toString(),
      joinDate: json['joinDate']?.toString(),
      gender: json['gender']?.toString(),
      name: json['name']?.toString(),
      fatherName: json['fatherName']?.toString(),
      address: json['address']?.toString() ?? json['businessAddress']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      mobileAlt: json['mobileAlt']?.toString(),
      email: json['email']?.toString(),
      postOffice: json['postOffice']?.toString(),
      country: json['country']?.toString() ?? 'India',
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      block: json['block']?.toString(),
      employeeType: json['employeeType']?.toString() ?? 'Retailer',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      image: json['image']?.toString() ?? json['profile']?.toString(),
      emergenceNo: json['emergenceNo']?.toString() ?? json['emergencyNo']?.toString(),
      billedGroup: json['billedGroup']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'retailerId': retailerId,
      'status': status,
      'retailerCode': retailerCode,
      'joinDate': joinDate,
      'gender': gender,
      'name': name,
      'fatherName': fatherName,
      'address': address,
      'mobile': mobile,
      'mobileAlt': mobileAlt,
      'email': email,
      'postOffice': postOffice,
      'country': country,
      'state': state,
      'district': district,
      'block': block,
      'employeeType': employeeType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'image': image,
      'emergenceNo': emergenceNo,
      'billedGroup': billedGroup,
    };
  }

  // ============================================================
  // BACKWARD COMPATIBILITY GETTERS
  // ============================================================
  String? get retailerID => retailerId;
  String? get phone => mobile;
  String? get businessAddress => address;
  String? get profile => image;
  String? get emergencyContact => emergenceNo;

  bool get isActive {
    if (status == null) return true;
    final lower = status!.trim().toLowerCase();
    return lower == 'active' || lower == 'true' || lower == '1';
  }

  // ============================================================
  // HELPER FORMATTERS & UTILITIES
  // ============================================================
  String get resolvedImageUrl {
    if (image == null || image!.trim().isEmpty) return '';
    final path = image!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '$imageBaseUrl$path';
    }
    return '$imageBaseUrl/$path';
  }

  String get displayDesignation {
    if (employeeType != null && employeeType!.trim().isNotEmpty) {
      final type = employeeType!.trim();
      if (type.toLowerCase() == 'retailer') {
        return 'Authorized Retailer & Pharmacy';
      }
      return type;
    }
    return 'Authorized Ayurvedic Retailer';
  }

  String get displayLocation {
    final List<String> parts = [];
    if (district != null && district!.trim().isNotEmpty) parts.add(district!.trim());
    if (state != null && state!.trim().isNotEmpty) parts.add(state!.trim());
    if (parts.isEmpty) {
      return country ?? 'India';
    }
    return parts.join(', ');
  }

  String get formattedJoinDate {
    if (joinDate == null || joinDate!.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(joinDate!.trim());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      try {
        final dt = DateTime.parse(joinDate!.trim().split('T').first);
        return DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        return joinDate!;
      }
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(createdAt!.trim());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  String get formattedUpdatedAt {
    if (updatedAt == null || updatedAt!.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(updatedAt!.trim());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return updatedAt!;
    }
  }
}