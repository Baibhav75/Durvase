
class AsmListResponse {
  final AsmHeader? header;
  final List<AsmItem> data;

  AsmListResponse({
    this.header,
    required this.data,
  });

  factory AsmListResponse.fromJson(Map<String, dynamic> json) {
    return AsmListResponse(
      header: json['Header'] is Map
          ? AsmHeader.fromJson(
        Map<String, dynamic>.from(json['Header']),
      )
          : null,
      data: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map>()
          .map(
            (item) => AsmItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Header': header?.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}


// =====================================================
// ASM HEADER
// =====================================================

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

    final String valueString = value.toString().trim();

    if (valueString.isEmpty) return null;

    return valueString;
  }

  factory AsmHeader.fromJson(Map<String, dynamic> json) {
    return AsmHeader(
      success: json['success'] == true ||
          json['success']?.toString().toLowerCase() == 'true',

      totalCount:
      int.tryParse(json['totalCount']?.toString() ?? '') ?? 0,

      mrId: _parseString(
        json['MRId'] ?? json['mrId'] ?? json['mrid'],
      ),

      name: _parseString(
        json['Name'] ?? json['name'],
      ),

      mobile: _parseString(
        json['Mobile'] ?? json['mobile'],
      ),

      mobileAlt: _parseString(
        json['MobileAlt'] ??
            json['mobileAlt'] ??
            json['mobile_alt'],
      ),

      email: _parseString(
        json['Email'] ?? json['email'],
      ),

      district: _parseString(
        json['District'] ?? json['district'],
      ),

      block: _parseString(
        json['Block'] ?? json['block'],
      ),

      fatherName: _parseString(
        json['FatherName'] ?? json['fatherName'],
      ),

      address: _parseString(
        json['Address'] ?? json['address'],
      ),

      joinDate: _parseString(
        json['JoinDate'] ?? json['joinDate'],
      ),

      image: _parseString(
        json['Image'] ?? json['image'] ?? json['Photo'],
      ),

      empId: _parseString(
        json['EmpId'] ??
            json['empId'] ??
            json['EmployeeId'] ??
            json['employeeId'],
      ),

      status: _parseString(
        json['Status'] ?? json['status'],
      ),

      createdAt: _parseString(
        json['CreatedAt'] ?? json['createdAt'],
      ),

      gender: _parseString(
        json['Gender'] ?? json['gender'],
      ),

      postOffice: _parseString(
        json['PostOffice'] ?? json['postOffice'],
      ),

      country: _parseString(
        json['Country'] ?? json['country'],
      ),

      state: _parseString(
        json['State'] ?? json['state'],
      ),

      employeeCode: _parseString(
        json['EmployeeCode'] ?? json['employeeCode'],
      ),

      employeeType: _parseString(
        json['EmployeeType'] ?? json['employeeType'],
      ),

      emergenceNo: _parseString(
        json['EmergenceNo'] ?? json['emergenceNo'],
      ),

      billedGroup: _parseString(
        json['BilledGroup'] ?? json['billedGroup'],
      ),
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


// =====================================================
// ASM ITEM
// =====================================================

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

    final String valueString = value.toString().trim();

    if (valueString.isEmpty) return null;

    return valueString;
  }

  factory AsmItem.fromJson(Map<String, dynamic> json) {
    return AsmItem(

      // -------------------------
      // ID
      // -------------------------

      empId: _parseString(
        json['EmpId'] ??
            json['empId'] ??
            json['EmployeeId'] ??
            json['employeeId'] ??
            json['Id'] ??
            json['id'],
      ),

      mrId: _parseString(
        json['MRId'] ??
            json['mrId'] ??
            json['mrid'],
      ),

      // -------------------------
      // BASIC DETAILS
      // -------------------------

      name: _parseString(
        json['Name'] ??
            json['name'] ??
            json['Emp_Name'] ??
            json['emp_name'] ??
            json['employee_name'],
      ),

      mobile: _parseString(
        json['Mobile'] ??
            json['mobile'] ??
            json['Phone'] ??
            json['phone'],
      ),

      mobileAlt: _parseString(
        json['MobileAlt'] ??
            json['mobileAlt'] ??
            json['mobile_alt'],
      ),

      email: _parseString(
        json['Email'] ??
            json['email'],
      ),

      // -------------------------
      // LOCATION
      // -------------------------

      country: _parseString(
        json['Country'] ??
            json['country'],
      ),

      state: _parseString(
        json['State'] ??
            json['state'],
      ),

      district: _parseString(
        json['District'] ??
            json['district'],
      ),

      block: _parseString(
        json['Block'] ??
            json['block'],
      ),

      postOffice: _parseString(
        json['PostOffice'] ??
            json['postOffice'],
      ),

      address: _parseString(
        json['Address'] ??
            json['address'],
      ),

      // -------------------------
      // PERSONAL DETAILS
      // -------------------------

      fatherName: _parseString(
        json['FatherName'] ??
            json['fatherName'],
      ),

      gender: _parseString(
        json['Gender'] ??
            json['gender'],
      ),

      // -------------------------
      // EMPLOYEE DETAILS
      // -------------------------

      employeeCode: _parseString(
        json['EmployeeCode'] ??
            json['employeeCode'] ??
            json['EmployeeId'],
      ),

      employeeType: _parseString(
        json['EmployeeType'] ??
            json['employeeType'] ??
            'ASM',
      ),

      status: _parseString(
        json['Status'] ??
            json['status'],
      ),

      joinDate: _parseString(
        json['JoinDate'] ??
            json['joinDate'],
      ),

      // -------------------------
      // OTHER DETAILS
      // -------------------------

      image: _parseString(
        json['Image'] ??
            json['image'] ??
            json['Photo'] ??
            json['photo'],
      ),

      createdAt: _parseString(
        json['CreatedAt'] ??
            json['createdAt'],
      ),

      emergenceNo: _parseString(
        json['EmergenceNo'] ??
            json['emergenceNo'],
      ),

      billedGroup: _parseString(
        json['BilledGroup'] ??
            json['billedGroup'],
      ),
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

  // ===================================================
  // HELPER GETTERS
  // ===================================================

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!;
    }

    return 'ASM';
  }

  String get displayId {
    return empId ??
        employeeCode ??
        mrId ??
        'N/A';
  }

  String get displayMobile {
    return mobile ?? 'N/A';
  }

  String get displayState {
    return state ?? 'N/A';
  }

  String get displayDistrict {
    return district ?? 'N/A';
  }

  String get displayBlock {
    return block ?? 'N/A';
  }

  String get displayAddress {
    return address ?? 'N/A';
  }

  // ===================================================
  // FULL LOCATION
  // ===================================================

  String get displayLocation {
    final List<String> parts = [];

    if (block != null && block!.trim().isNotEmpty) {
      parts.add(block!);
    }

    if (district != null && district!.trim().isNotEmpty) {
      parts.add(district!);
    }

    if (state != null && state!.trim().isNotEmpty) {
      parts.add(state!);
    }

    if (country != null && country!.trim().isNotEmpty) {
      parts.add(country!);
    }

    if (parts.isEmpty) {
      return 'Location not available';
    }

    return parts.join(', ');
  }

  // ===================================================
  // FULL ADDRESS
  // ===================================================

  String get fullAddress {
    final List<String> parts = [];

    if (address != null && address!.trim().isNotEmpty) {
      parts.add(address!);
    }

    if (block != null && block!.trim().isNotEmpty) {
      parts.add(block!);
    }

    if (district != null && district!.trim().isNotEmpty) {
      parts.add(district!);
    }

    if (state != null && state!.trim().isNotEmpty) {
      parts.add(state!);
    }

    if (country != null && country!.trim().isNotEmpty) {
      parts.add(country!);
    }

    if (parts.isEmpty) {
      return 'Address not available';
    }

    return parts.join(', ');
  }

  // ===================================================
  // ACTIVE STATUS
  // ===================================================

  bool get isActive {
    if (status == null || status!.trim().isEmpty) {
      return true;
    }

    final String value = status!.toLowerCase().trim();

    return value == 'active' ||
        value == '1' ||
        value == 'true';
  }

  // ===================================================
  // IMAGE URL
  // ===================================================

  String get resolvedImageUrl {
    if (image == null || image!.trim().isEmpty) {
      return '';
    }

    if (image!.startsWith('http://') ||
        image!.startsWith('https://')) {
      return image!;
    }

    return 'https://durvasaayurved.com/$image';
  }
}
