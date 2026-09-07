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

  bool get isSuccess {
    final s = status?.toString().toLowerCase();
    return s == 'success' || s == 'true' || s == '200' || data != null;
  }

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
  static const String imageBaseUrl = 'https://durvasaayurved.com';

  final int? id;
  final String? visiterId;
  final String? empType;
  final String? empMobile;
  final String? visitFor;
  final String? country;
  final String? state;
  final String? district;
  final String? block;
  final String? businessName;
  final String? personName;
  final String? mobile;
  final String? address;
  final String? purpose;
  final String? photo;
  final String? reVisited;
  final String? visitDate;
  final String? remark;
  final String? empName;
  final String? revisitDate;
  final String? employeeId;

  // Legacy/Alternate support fields
  final String? status;
  final String? retailerCode;
  final String? joinDate;
  final String? gender;
  final String? fatherName;
  final String? mobileAlt;
  final String? email;
  final String? postOffice;
  final String? employeeType;
  final String? createdAt;
  final String? updatedAt;
  final String? emergenceNo;
  final String? billedGroup;

  RetailerProfileData({
    this.id,
    String? visiterId,
    this.empType,
    this.empMobile,
    this.visitFor,
    this.country,
    this.state,
    this.district,
    this.block,
    this.businessName,
    String? personName,
    this.mobile,
    this.address,
    this.purpose,
    String? photo,
    this.reVisited,
    this.visitDate,
    this.remark,
    this.empName,
    this.revisitDate,
    this.employeeId,
    // Legacy support named parameters
    String? retailerId,
    String? name,
    String? image,
    this.status,
    this.retailerCode,
    this.joinDate,
    this.gender,
    this.fatherName,
    this.mobileAlt,
    this.email,
    this.postOffice,
    this.employeeType,
    this.createdAt,
    this.updatedAt,
    this.emergenceNo,
    this.billedGroup,
  })  : visiterId = (visiterId != null && visiterId.isNotEmpty)
            ? visiterId
            : (retailerId ?? ''),
        personName = (personName != null && personName.isNotEmpty)
            ? personName
            : (name ?? ''),
        photo = (photo != null && photo.isNotEmpty)
            ? photo
            : (image ?? '');


  factory RetailerProfileData.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] is int
        ? json['id'] as int
        : int.tryParse(json['id']?.toString() ?? '');

    final rawVisiterId = json['visiterId'] ??
        json['visiterID'] ??
        json['VisiterID'] ??
        json['retailerId'] ??
        json['retailerID'] ??
        json['RetailerID'];

    final rawPersonName = json['personName'] ?? json['name'];
    final rawBusinessName = json['businessName'] ?? json['business_name'];
    final rawMobile = json['mobile'] ?? json['phone'];
    final rawAddress = json['address'] ?? json['businessAddress'];
    final rawPhoto = json['photo'] ?? json['image'] ?? json['profile'];
    final rawEmpType = json['empType'] ?? json['emp_type'] ?? json['employeeType'];
    final rawEmpMobile = json['empMobile'] ?? json['emp_mobile'];
    final rawVisitFor = json['visitFor'] ?? json['visit_for'];
    final rawPurpose = json['purpose'] ?? 'Retailer';
    final rawCountry = json['country'] ?? 'India';
    final rawState = json['state'];
    final rawDistrict = json['district'];
    final rawBlock = json['block'];
    final rawReVisited = json['reVisited'] ?? json['revisited'];
    final rawVisitDate = json['visitDate'] ?? json['visit_date'];
    final rawRemark = json['remark'] ?? json['remarks'];
    final rawEmpName = json['empName'] ?? json['emp_name'];
    final rawRevisitDate = json['revisitDate'] ?? json['revisit_date'];
    final rawEmployeeId = json['employeeId'] ?? json['empId'] ?? json['employee_id'];

    return RetailerProfileData(
      id: rawId,
      visiterId: rawVisiterId?.toString().trim(),
      empType: rawEmpType?.toString().trim(),
      empMobile: rawEmpMobile?.toString().trim(),
      visitFor: rawVisitFor?.toString().trim(),
      country: rawCountry?.toString().trim(),
      state: rawState?.toString().trim(),
      district: rawDistrict?.toString().trim(),
      block: rawBlock?.toString().trim(),
      businessName: rawBusinessName?.toString().trim(),
      personName: rawPersonName?.toString().trim(),
      mobile: rawMobile?.toString().trim(),
      address: rawAddress?.toString().trim(),
      purpose: rawPurpose?.toString().trim(),
      photo: rawPhoto?.toString().trim(),
      reVisited: rawReVisited?.toString().trim(),
      visitDate: rawVisitDate?.toString().trim(),
      remark: rawRemark?.toString().trim(),
      empName: rawEmpName?.toString().trim(),
      revisitDate: rawRevisitDate?.toString().trim(),
      employeeId: rawEmployeeId?.toString().trim(),
      // Legacy
      status: json['status']?.toString().trim() ?? 'Active',
      retailerCode: json['retailerCode']?.toString().trim(),
      joinDate: json['joinDate']?.toString().trim() ?? rawVisitDate?.toString().trim(),
      gender: json['gender']?.toString().trim(),
      fatherName: json['fatherName']?.toString().trim(),
      mobileAlt: json['mobileAlt']?.toString().trim(),
      email: json['email']?.toString().trim(),
      postOffice: json['postOffice']?.toString().trim(),
      employeeType: rawEmpType?.toString().trim() ?? 'Retailer',
      createdAt: json['createdAt']?.toString().trim() ?? rawVisitDate?.toString().trim(),
      updatedAt: json['updatedAt']?.toString().trim(),
      emergenceNo: json['emergenceNo']?.toString().trim(),
      billedGroup: json['billedGroup']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visiterId': visiterId,
      'retailerId': visiterId,
      'empType': empType,
      'empMobile': empMobile,
      'visitFor': visitFor,
      'country': country,
      'state': state,
      'district': district,
      'block': block,
      'businessName': businessName,
      'personName': personName,
      'name': name,
      'mobile': mobile,
      'address': address,
      'purpose': purpose,
      'photo': photo,
      'image': photo,
      'reVisited': reVisited,
      'visitDate': visitDate,
      'remark': remark,
      'empName': empName,
      'revisitDate': revisitDate,
      'employeeId': employeeId,
      'status': status,
      'retailerCode': retailerCode,
      'joinDate': joinDate,
      'gender': gender,
      'fatherName': fatherName,
      'mobileAlt': mobileAlt,
      'email': email,
      'postOffice': postOffice,
      'employeeType': employeeType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'emergenceNo': emergenceNo,
      'billedGroup': billedGroup,
    };
  }

  // ============================================================
  // BACKWARD COMPATIBILITY GETTERS
  // ============================================================
  String? get retailerId => visiterId;
  String? get retailerID => visiterId;
  String? get name => (personName != null && personName!.isNotEmpty)
      ? personName
      : businessName;
  String? get phone => mobile;
  String? get businessAddress => address;
  String? get image => photo;
  String? get profile => photo;
  String? get emergencyContact => emergenceNo ?? empMobile;

  bool get isActive {
    if (status == null) return true;
    final lower = status!.trim().toLowerCase();
    return lower == 'active' || lower == 'true' || lower == '1' || lower == 'success';
  }

  // ============================================================
  // HELPER FORMATTERS & UTILITIES
  // ============================================================
  String get resolvedImageUrl {
    final img = photo ?? image;
    if (img == null || img.trim().isEmpty) return '';
    final path = img.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '$imageBaseUrl$path';
    }
    return '$imageBaseUrl/$path';
  }

  String get displayDesignation {
    if (purpose != null && purpose!.trim().isNotEmpty) {
      return 'Authorized ${purpose!.trim()} Partner';
    }
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

  String get formattedVisitDate {
    if (visitDate == null || visitDate!.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(visitDate!.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return visitDate!;
    }
  }

  String get formattedRevisitDate {
    if (revisitDate == null || revisitDate!.trim().isEmpty) return 'None scheduled';
    try {
      final dt = DateTime.parse(revisitDate!.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return revisitDate!;
    }
  }

  String get formattedJoinDate {
    final dateStr = joinDate ?? visitDate;
    if (dateStr == null || dateStr.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(dateStr.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String get formattedCreatedAt {
    final dateStr = createdAt ?? visitDate;
    if (dateStr == null || dateStr.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(dateStr.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String get formattedUpdatedAt {
    if (updatedAt == null || updatedAt!.trim().isEmpty) return 'Not available';
    try {
      final dt = DateTime.parse(updatedAt!.trim());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return updatedAt!;
    }
  }
}