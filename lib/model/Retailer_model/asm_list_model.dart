class AsmListResponse {
  final AsmHeader? header;
  final List<AsmItem> data;

  AsmListResponse({
    this.header,
    required this.data,
  });

  factory AsmListResponse.fromJson(Map<String, dynamic> json) {
    return AsmListResponse(
      header: json['Header'] != null && json['Header'] is Map<String, dynamic>
          ? AsmHeader.fromJson(json['Header'] as Map<String, dynamic>)
          : null,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => AsmItem.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Header': header?.toJson(),
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class AsmHeader {
  final bool success;
  final int totalCount;
  final String? mrId;
  final String? name;
  final String? mobile;
  final String? mobileAlt;
  final String? email;
  final String? district;
  final String? block;
  final String? fatherName;
  final String? address;
  final String? joinDate;
  final String? image;
  final String? empId;
  final String? status;
  final String? createdAt;
  final String? gender;
  final String? postOffice;
  final String? country;
  final String? state;
  final String? employeeCode;
  final String? employeeType;
  final String? emergenceNo;
  final String? billedGroup;

  AsmHeader({
    this.success = false,
    this.totalCount = 0,
    this.mrId,
    this.name,
    this.mobile,
    this.mobileAlt,
    this.email,
    this.district,
    this.block,
    this.fatherName,
    this.address,
    this.joinDate,
    this.image,
    this.empId,
    this.status,
    this.createdAt,
    this.gender,
    this.postOffice,
    this.country,
    this.state,
    this.employeeCode,
    this.employeeType,
    this.emergenceNo,
    this.billedGroup,
  });

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  factory AsmHeader.fromJson(Map<String, dynamic> json) {
    return AsmHeader(
      success: json['success'] == true || json['success']?.toString() == 'true',
      totalCount: int.tryParse(json['totalCount']?.toString() ?? '') ?? 0,
      mrId: _parseString(json['MRId'] ?? json['mrId'] ?? json['mrid']),
      name: _parseString(json['Name'] ?? json['name']),
      mobile: _parseString(json['Mobile'] ?? json['mobile']),
      mobileAlt: _parseString(json['MobileAlt'] ?? json['mobileAlt'] ?? json['mobile_alt']),
      email: _parseString(json['Email'] ?? json['email']),
      district: _parseString(json['District'] ?? json['district']),
      block: _parseString(json['Block'] ?? json['block']),
      fatherName: _parseString(json['FatherName'] ?? json['fatherName']),
      address: _parseString(json['Address'] ?? json['address']),
      joinDate: _parseString(json['JoinDate'] ?? json['joinDate']),
      image: _parseString(json['Image'] ?? json['image']),
      empId: _parseString(json['EmpId'] ?? json['empId'] ?? json['emp_id']),
      status: _parseString(json['Status'] ?? json['status']),
      createdAt: _parseString(json['CreatedAt'] ?? json['createdAt']),
      gender: _parseString(json['Gender'] ?? json['gender']),
      postOffice: _parseString(json['PostOffice'] ?? json['postOffice']),
      country: _parseString(json['Country'] ?? json['country']),
      state: _parseString(json['State'] ?? json['state']),
      employeeCode: _parseString(json['EmployeeCode'] ?? json['employeeCode']),
      employeeType: _parseString(json['EmployeeType'] ?? json['employeeType']),
      emergenceNo: _parseString(json['EmergenceNo'] ?? json['emergenceNo']),
      billedGroup: _parseString(json['BilledGroup'] ?? json['billedGroup']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalCount': totalCount,
      'MRId': mrId,
      'Name': name,
      'Mobile': mobile,
      'MobileAlt': mobileAlt,
      'Email': email,
      'District': district,
      'Block': block,
      'FatherName': fatherName,
      'Address': address,
      'JoinDate': joinDate,
      'Image': image,
      'EmpId': empId,
      'Status': status,
      'CreatedAt': createdAt,
      'Gender': gender,
      'PostOffice': postOffice,
      'Country': country,
      'State': state,
      'EmployeeCode': employeeCode,
      'EmployeeType': employeeType,
      'EmergenceNo': emergenceNo,
      'BilledGroup': billedGroup,
    };
  }
}

class AsmItem {
  final String? empId;
  final String? mrId;
  final String? name;
  final String? mobile;
  final String? mobileAlt;
  final String? email;
  final String? district;
  final String? block;
  final String? fatherName;
  final String? address;
  final String? joinDate;
  final String? image;
  final String? status;
  final String? createdAt;
  final String? gender;
  final String? postOffice;
  final String? country;
  final String? state;
  final String? employeeCode;
  final String? employeeType;
  final String? emergenceNo;
  final String? billedGroup;

  AsmItem({
    this.empId,
    this.mrId,
    this.name,
    this.mobile,
    this.mobileAlt,
    this.email,
    this.district,
    this.block,
    this.fatherName,
    this.address,
    this.joinDate,
    this.image,
    this.status,
    this.createdAt,
    this.gender,
    this.postOffice,
    this.country,
    this.state,
    this.employeeCode,
    this.employeeType,
    this.emergenceNo,
    this.billedGroup,
  });

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  factory AsmItem.fromJson(Map<String, dynamic> json) {
    return AsmItem(
      empId: _parseString(
        json['EmpId'] ??
            json['empId'] ??
            json['emp_id'] ??
            json['EmployeeId'] ??
            json['employeeId'] ??
            json['Id'] ??
            json['id'],
      ),
      mrId: _parseString(json['MRId'] ?? json['mrId'] ?? json['mrid']),
      name: _parseString(json['Name'] ?? json['name'] ?? json['emp_name'] ?? json['employee_name']),
      mobile: _parseString(json['Mobile'] ?? json['mobile'] ?? json['phone'] ?? json['Phone']),
      mobileAlt: _parseString(json['MobileAlt'] ?? json['mobileAlt'] ?? json['mobile_alt']),
      email: _parseString(json['Email'] ?? json['email']),
      district: _parseString(json['District'] ?? json['district']),
      block: _parseString(json['Block'] ?? json['block']),
      fatherName: _parseString(json['FatherName'] ?? json['fatherName']),
      address: _parseString(json['Address'] ?? json['address']),
      joinDate: _parseString(json['JoinDate'] ?? json['joinDate']),
      image: _parseString(json['Image'] ?? json['image'] ?? json['photo'] ?? json['Photo']),
      status: _parseString(json['Status'] ?? json['status']),
      createdAt: _parseString(json['CreatedAt'] ?? json['createdAt']),
      gender: _parseString(json['Gender'] ?? json['gender']),
      postOffice: _parseString(json['PostOffice'] ?? json['postOffice']),
      country: _parseString(json['Country'] ?? json['country']),
      state: _parseString(json['State'] ?? json['state']),
      employeeCode: _parseString(json['EmployeeCode'] ?? json['employeeCode'] ?? json['EmployeeId']),
      employeeType: _parseString(json['EmployeeType'] ?? json['employeeType'] ?? 'ASM'),
      emergenceNo: _parseString(json['EmergenceNo'] ?? json['emergenceNo']),
      billedGroup: _parseString(json['BilledGroup'] ?? json['billedGroup']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EmpId': empId,
      'MRId': mrId,
      'Name': name,
      'Mobile': mobile,
      'MobileAlt': mobileAlt,
      'Email': email,
      'District': district,
      'Block': block,
      'FatherName': fatherName,
      'Address': address,
      'JoinDate': joinDate,
      'Image': image,
      'Status': status,
      'CreatedAt': createdAt,
      'Gender': gender,
      'PostOffice': postOffice,
      'Country': country,
      'State': state,
      'EmployeeCode': employeeCode,
      'EmployeeType': employeeType,
      'EmergenceNo': emergenceNo,
      'BilledGroup': billedGroup,
    };
  }

  bool get isActive {
    if (status == null) return true;
    final s = status!.toLowerCase();
    return s == 'active' || s == '1' || s == 'true';
  }

  String get displayName => (name != null && name!.isNotEmpty) ? name! : 'ASM Executive ($displayId)';

  String get displayId => empId ?? employeeCode ?? mrId ?? 'N/A';

  String get fullAddress {
    final parts = [address, block, district, state, country]
        .where((e) => e != null && e.trim().isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(', ');
    return '';
  }

  String get countryAndState {
    final parts = [
      if (state != null && state!.trim().isNotEmpty) "State: $state",
      if (country != null && country!.trim().isNotEmpty) "Country: $country",
    ];
    return parts.join(' | ');
  }

  String get displayLocation {
    final parts = [district, state, country].where((e) => e != null && e.trim().isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(', ');
    if (block != null && block!.isNotEmpty) return block!;
    return 'Assigned Region';
  }

  String get resolvedImageUrl {
    if (image == null || image!.isEmpty) return '';
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image!;
    }
    return 'https://durvasaayurved.com/$image';
  }
}
