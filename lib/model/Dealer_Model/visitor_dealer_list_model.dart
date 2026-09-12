import 'dart:convert';

class VisitorDealerListResponse {
  final VisitorDealerHeader? header;
  final List<VisitorDealerItem> data;

  VisitorDealerListResponse({
    this.header,
    this.data = const [],
  });

  factory VisitorDealerListResponse.fromJson(Map<String, dynamic> json) {
    VisitorDealerHeader? parsedHeader;
    if (json['Header'] != null && json['Header'] is Map) {
      parsedHeader = VisitorDealerHeader.fromJson(
        Map<String, dynamic>.from(json['Header']),
      );
    } else if (json['header'] != null && json['header'] is Map) {
      parsedHeader = VisitorDealerHeader.fromJson(
        Map<String, dynamic>.from(json['header']),
      );
    }

    List<VisitorDealerItem> dataList = [];
    if (json['data'] != null && json['data'] is List) {
      dataList = (json['data'] as List)
          .whereType<Map>()
          .map((e) => VisitorDealerItem.fromJson(
                Map<String, dynamic>.from(e),
                fallbackHeader: parsedHeader,
              ))
          .toList();
    } else if (json['Data'] != null && json['Data'] is List) {
      dataList = (json['Data'] as List)
          .whereType<Map>()
          .map((e) => VisitorDealerItem.fromJson(
                Map<String, dynamic>.from(e),
                fallbackHeader: parsedHeader,
              ))
          .toList();
    }

    return VisitorDealerListResponse(
      header: parsedHeader,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() => {
        'Header': header?.toJson(),
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class VisitorDealerHeader {
  final bool success;
  final int totalCount;
  final int? id;
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
  final String? password;
  final String? visiterId;
  final String? employeeId;

  VisitorDealerHeader({
    this.success = false,
    this.totalCount = 0,
    this.id,
    this.empType,
    this.empMobile,
    this.visitFor,
    this.country,
    this.state,
    this.district,
    this.block,
    this.businessName,
    this.personName,
    this.mobile,
    this.address,
    this.purpose,
    this.photo,
    this.reVisited,
    this.visitDate,
    this.remark,
    this.empName,
    this.revisitDate,
    this.password,
    this.visiterId,
    this.employeeId,
  });

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  factory VisitorDealerHeader.fromJson(Map<String, dynamic> json) {
    return VisitorDealerHeader(
      success: json['success'] == true ||
          json['success']?.toString().toLowerCase() == 'true',
      totalCount: int.tryParse(json['totalCount']?.toString() ?? '') ?? 0,
      id: _parseInt(json['Id'] ?? json['id']),
      empType: _parseString(json['Emp_Type'] ?? json['emp_type']),
      empMobile: _parseString(json['Emp_Mobile'] ?? json['emp_mobile']),
      visitFor: _parseString(json['Visit_for'] ?? json['visit_for']),
      country: _parseString(json['Country'] ?? json['country']),
      state: _parseString(json['State'] ?? json['state']),
      district: _parseString(json['District'] ?? json['district']),
      block: _parseString(json['Block'] ?? json['block']),
      businessName: _parseString(json['Business_Name'] ?? json['business_name']),
      personName: _parseString(json['Person_Name'] ?? json['person_name']),
      mobile: _parseString(json['Mobile'] ?? json['mobile']),
      address: _parseString(json['Address'] ?? json['address']),
      purpose: _parseString(json['Purpose'] ?? json['purpose']),
      photo: _parseString(json['Photo'] ?? json['photo']),
      reVisited: _parseString(json['Re_visited'] ?? json['re_visited']),
      visitDate: _parseString(json['VisitDate'] ?? json['visitDate']),
      remark: _parseString(json['Remark'] ?? json['remark']),
      empName: _parseString(json['Emp_Name'] ?? json['emp_name']),
      revisitDate: _parseString(json['RevisitDate'] ?? json['revisitDate']),
      password: _parseString(json['Password'] ?? json['password']),
      visiterId: _parseString(json['VisiterId'] ?? json['visiterId'] ?? json['DealerId'] ?? json['DealerID']),
      employeeId: _parseString(json['EmployeeId'] ?? json['employeeId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'totalCount': totalCount,
        'Id': id,
        'Emp_Type': empType,
        'Emp_Mobile': empMobile,
        'Visit_for': visitFor,
        'Country': country,
        'State': state,
        'District': district,
        'Block': block,
        'Business_Name': businessName,
        'Person_Name': personName,
        'Mobile': mobile,
        'Address': address,
        'Purpose': purpose,
        'Photo': photo,
        'Re_visited': reVisited,
        'VisitDate': visitDate,
        'Remark': remark,
        'Emp_Name': empName,
        'RevisitDate': revisitDate,
        'Password': password,
        'VisiterId': visiterId,
        'EmployeeId': employeeId,
      };
}

class VisitorDealerItem {
  final int? id;
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
  final String? password;
  final String? visiterId;
  final String? employeeId;

  VisitorDealerItem({
    this.id,
    this.empType,
    this.empMobile,
    this.visitFor,
    this.country,
    this.state,
    this.district,
    this.block,
    this.businessName,
    this.personName,
    this.mobile,
    this.address,
    this.purpose,
    this.photo,
    this.reVisited,
    this.visitDate,
    this.remark,
    this.empName,
    this.revisitDate,
    this.password,
    this.visiterId,
    this.employeeId,
  });

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  factory VisitorDealerItem.fromJson(Map<String, dynamic> json, {VisitorDealerHeader? fallbackHeader}) {
    return VisitorDealerItem(
      id: _parseInt(json['Id'] ?? json['id']) ?? fallbackHeader?.id,
      empType: _parseString(json['Emp_Type'] ?? json['emp_type']) ?? fallbackHeader?.empType,
      empMobile: _parseString(json['Emp_Mobile'] ?? json['emp_mobile']) ?? fallbackHeader?.empMobile,
      visitFor: _parseString(json['Visit_for'] ?? json['visit_for']) ?? fallbackHeader?.visitFor,
      country: _parseString(json['Country'] ?? json['country']) ?? fallbackHeader?.country,
      state: _parseString(json['State'] ?? json['state']) ?? fallbackHeader?.state,
      district: _parseString(json['District'] ?? json['district']) ?? fallbackHeader?.district,
      block: _parseString(json['Block'] ?? json['block']) ?? fallbackHeader?.block,
      businessName: _parseString(json['Business_Name'] ?? json['business_name'] ?? json['businessName']) ?? fallbackHeader?.businessName,
      personName: _parseString(json['Person_Name'] ?? json['person_name'] ?? json['name'] ?? json['Name']) ?? fallbackHeader?.personName,
      mobile: _parseString(json['Mobile'] ?? json['mobile'] ?? json['phone']) ?? fallbackHeader?.mobile,
      address: _parseString(json['Address'] ?? json['address']) ?? fallbackHeader?.address,
      purpose: _parseString(json['Purpose'] ?? json['purpose']) ?? fallbackHeader?.purpose ?? 'Dealer',
      photo: _parseString(json['Photo'] ?? json['photo'] ?? json['image'] ?? json['Image']) ?? fallbackHeader?.photo,
      reVisited: _parseString(json['Re_visited'] ?? json['re_visited']) ?? fallbackHeader?.reVisited,
      visitDate: _parseString(json['VisitDate'] ?? json['visitDate']) ?? fallbackHeader?.visitDate,
      remark: _parseString(json['Remark'] ?? json['remark']) ?? fallbackHeader?.remark,
      empName: _parseString(json['Emp_Name'] ?? json['emp_name']) ?? fallbackHeader?.empName,
      revisitDate: _parseString(json['RevisitDate'] ?? json['revisitDate']) ?? fallbackHeader?.revisitDate,
      password: _parseString(json['Password'] ?? json['password']) ?? fallbackHeader?.password,
      visiterId: _parseString(json['VisiterId'] ?? json['visiterId'] ?? json['DealerId'] ?? json['DealerID'] ?? json['DealerCode']) ?? fallbackHeader?.visiterId,
      employeeId: _parseString(json['EmployeeId'] ?? json['employeeId']) ?? fallbackHeader?.employeeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Emp_Type': empType,
        'Emp_Mobile': empMobile,
        'Visit_for': visitFor,
        'Country': country,
        'State': state,
        'District': district,
        'Block': block,
        'Business_Name': businessName,
        'Person_Name': personName,
        'Mobile': mobile,
        'Address': address,
        'Purpose': purpose,
        'Photo': photo,
        'Re_visited': reVisited,
        'VisitDate': visitDate,
        'Remark': remark,
        'Emp_Name': empName,
        'RevisitDate': revisitDate,
        'Password': password,
        'VisiterId': visiterId,
        'EmployeeId': employeeId,
      };

  // ===================================================
  // HELPER GETTERS
  // ===================================================

  String get displayName {
    if (personName != null && personName!.trim().isNotEmpty) {
      return personName!.trim();
    }
    if (businessName != null && businessName!.trim().isNotEmpty) {
      return businessName!.trim();
    }
    return 'Dealer';
  }

  String get displayId {
    if (visiterId != null && visiterId!.trim().isNotEmpty) {
      return visiterId!.trim();
    }
    if (employeeId != null && employeeId!.trim().isNotEmpty) {
      return employeeId!.trim();
    }
    if (id != null) {
      return id.toString();
    }
    return 'N/A';
  }

  String get effectiveDealerId {
    if (visiterId != null && visiterId!.trim().isNotEmpty) {
      return visiterId!.trim();
    }
    if (employeeId != null && employeeId!.trim().isNotEmpty) {
      return employeeId!.trim();
    }
    if (id != null) {
      return id.toString();
    }
    return '';
  }

  String get displayMobile => mobile ?? empMobile ?? 'N/A';
  String get displayState => state ?? 'N/A';
  String get displayDistrict => district ?? 'N/A';
  String get displayBlock => block ?? 'N/A';
  String get displayAddress => address ?? 'N/A';

  String get displayLocation {
    final List<String> parts = [];
    if (block != null && block!.trim().isNotEmpty) parts.add(block!.trim());
    if (district != null && district!.trim().isNotEmpty) parts.add(district!.trim());
    if (state != null && state!.trim().isNotEmpty) parts.add(state!.trim());
    if (country != null && country!.trim().isNotEmpty) parts.add(country!.trim());
    return parts.isNotEmpty ? parts.join(', ') : 'Location not available';
  }

  String get resolvedImageUrl {
    if (photo == null || photo!.trim().isEmpty) return '';
    final raw = photo!.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'https://durvasaayurved.com/Uploads/VisiterPhotos/$raw';
  }

  bool get isActive => true;
}
