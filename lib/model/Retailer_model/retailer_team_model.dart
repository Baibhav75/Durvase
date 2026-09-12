class GetAllRetailerResponse {
  final RetailerHeader? header;
  final List<RetailerItem> data;

  GetAllRetailerResponse({
    this.header,
    this.data = const [],
  });

  factory GetAllRetailerResponse.fromJson(Map<String, dynamic> json) {
    RetailerHeader? parsedHeader;
    if (json['Header'] != null && json['Header'] is Map<String, dynamic>) {
      parsedHeader = RetailerHeader.fromJson(json['Header'] as Map<String, dynamic>);
    } else if (json['header'] != null && json['header'] is Map<String, dynamic>) {
      parsedHeader = RetailerHeader.fromJson(json['header'] as Map<String, dynamic>);
    }

    List<RetailerItem> dataList = [];
    if (json['data'] != null && json['data'] is List) {
      dataList = (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RetailerItem.fromJson(e, fallbackHeader: parsedHeader))
          .toList();
    } else if (json['Data'] != null && json['Data'] is List) {
      dataList = (json['Data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => RetailerItem.fromJson(e, fallbackHeader: parsedHeader))
          .toList();
    }

    // If data array is empty or missing but header has retailer information
    if (dataList.isEmpty &&
        parsedHeader != null &&
        (parsedHeader.visiterId?.isNotEmpty == true ||
            parsedHeader.id != null ||
            parsedHeader.businessName?.isNotEmpty == true ||
            parsedHeader.state?.isNotEmpty == true ||
            parsedHeader.district?.isNotEmpty == true)) {
      dataList = [RetailerItem.fromHeader(parsedHeader)];
    }

    return GetAllRetailerResponse(
      header: parsedHeader,
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() => {
        'Header': header?.toJson(),
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class RetailerHeader {
  final bool? success;
  final int? totalCount;
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
  final dynamic reVisited;
  final String? visitDate;
  final String? remark;
  final String? empName;
  final String? revisitDate;
  final String? password;
  final String? employeeId;

  RetailerHeader({
    this.success,
    this.totalCount,
    this.id,
    this.visiterId,
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
    this.employeeId,
  });

  factory RetailerHeader.fromJson(Map<String, dynamic> json) {
    return RetailerHeader(
      success: json['success'] == true ||
          json['success'] == 'true' ||
          json['Success'] == true ||
          json['Success'] == 'true',
      totalCount: json['totalCount'] is int
          ? json['totalCount']
          : int.tryParse(json['totalCount']?.toString() ??
              json['TotalCount']?.toString() ??
              json['total_count']?.toString() ??
              ''),
      id: json['Id'] is int
          ? json['Id']
          : int.tryParse(json['Id']?.toString() ??
              json['id']?.toString() ??
              json['ID']?.toString() ??
              ''),
      visiterId: _firstNonEmpty([
        json['VisiterId'],
        json['visiterId'],
        json['VisiterID'],
        json['visiter_id'],
        json['RetailerId'],
        json['retailerId'],
      ]),
      empType: _firstNonEmpty([
        json['Emp_Type'],
        json['emp_Type'],
        json['empType'],
        json['EmpType'],
        json['emp_type'],
        json['EmployeeType'],
        json['employeeType'],
      ]),
      empMobile: _firstNonEmpty([
        json['Emp_Mobile'],
        json['emp_Mobile'],
        json['empMobile'],
        json['EmpMobile'],
        json['emp_mobile'],
      ]),
      visitFor: _firstNonEmpty([
        json['Visit_for'],
        json['visit_for'],
        json['visitFor'],
        json['VisitFor'],
      ]),
      country: _firstNonEmpty([
        json['Country'],
        json['country'],
        json['COUNTRY'],
        json['CountryName'],
        json['countryName'],
      ]),
      state: _firstNonEmpty([
        json['State'],
        json['state'],
        json['STATE'],
        json['StateName'],
        json['stateName'],
        json['State_Name'],
        json['state_name'],
        json['Region'],
        json['region'],
      ]),
      district: _firstNonEmpty([
        json['District'],
        json['district'],
        json['DISTRICT'],
        json['DistrictName'],
        json['districtName'],
        json['District_Name'],
        json['district_name'],
        json['City'],
        json['city'],
        json['CityName'],
        json['cityName'],
      ]),
      block: _firstNonEmpty([
        json['Block'],
        json['block'],
        json['BLOCK'],
        json['BlockName'],
        json['blockName'],
        json['Block_Name'],
        json['block_name'],
        json['Tehsil'],
        json['tehsil'],
        json['Area'],
        json['area'],
      ]),
      businessName: _firstNonEmpty([
        json['Business_Name'],
        json['business_Name'],
        json['businessName'],
        json['BusinessName'],
        json['business_name'],
        json['ShopName'],
        json['shopName'],
        json['StoreName'],
        json['storeName'],
        json['Name'],
        json['name'],
      ]),
      personName: _firstNonEmpty([
        json['Person_Name'],
        json['person_Name'],
        json['personName'],
        json['PersonName'],
        json['person_name'],
        json['ContactPerson'],
        json['contactPerson'],
        json['OwnerName'],
        json['ownerName'],
      ]),
      mobile: _firstNonEmpty([
        json['Mobile'],
        json['mobile'],
        json['MOBILE'],
        json['Phone'],
        json['phone'],
        json['Contact'],
        json['contact'],
      ]),
      address: _firstNonEmpty([
        json['Address'],
        json['address'],
        json['ADDRESS'],
        json['Address1'],
        json['address1'],
        json['businessAddress'],
        json['BusinessAddress'],
        json['permanentAddress'],
        json['PermanentAddress'],
        json['Street'],
        json['street'],
      ]),
      purpose: _firstNonEmpty([
        json['Purpose'],
        json['purpose'],
        json['PURPOSE'],
      ]),
      photo: _firstNonEmpty([
        json['Photo'],
        json['photo'],
        json['PHOTO'],
        json['Image'],
        json['image'],
        json['IMAGE'],
        json['Profile'],
        json['profile'],
      ]),
      reVisited: json['Re_visited'] ??
          json['re_visited'] ??
          json['reVisited'] ??
          json['Revisited'],
      visitDate: _firstNonEmpty([
        json['VisitDate'],
        json['visitDate'],
        json['visit_date'],
        json['Visit_Date'],
      ]),
      remark: _firstNonEmpty([
        json['Remark'],
        json['remark'],
        json['REMARK'],
        json['Remarks'],
        json['remarks'],
      ]),
      empName: _firstNonEmpty([
        json['Emp_Name'],
        json['emp_Name'],
        json['empName'],
        json['EmpName'],
        json['emp_name'],
        json['EmployeeName'],
        json['employeeName'],
      ]),
      revisitDate: _firstNonEmpty([
        json['RevisitDate'],
        json['revisitDate'],
        json['revisit_date'],
        json['Revisit_Date'],
      ]),
      password: _firstNonEmpty([
        json['Password'],
        json['password'],
      ]),
      employeeId: _firstNonEmpty([
        json['EmployeeId'],
        json['employeeId'],
        json['EmployeeID'],
        json['employee_id'],
        json['EmpId'],
        json['empId'],
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'totalCount': totalCount,
        'Id': id,
        'VisiterId': visiterId,
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
        'EmployeeId': employeeId,
      };
}

class RetailerItem {
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
  final dynamic reVisited;
  final String? visitDate;
  final String? remark;
  final String? empName;
  final String? revisitDate;
  final String? password;
  final String? employeeId;

  // Additional legacy & convenience fields
  final String? status;
  final String? retailerCode;
  final String? joinDate;
  final String? gender;
  final String? nameField;
  final String? fatherName;
  final String? mobileAlt;
  final String? email;
  final String? postOffice;
  final String? createdAt;
  final String? updatedAt;
  final String? emergenceNo;
  final String? billedGroup;

  RetailerItem({
    this.id,
    this.visiterId,
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
    this.employeeId,
    this.status,
    this.retailerCode,
    this.joinDate,
    this.gender,
    this.nameField,
    this.fatherName,
    this.mobileAlt,
    this.email,
    this.postOffice,
    this.createdAt,
    this.updatedAt,
    this.emergenceNo,
    this.billedGroup,
  });

  factory RetailerItem.fromJson(Map<String, dynamic> json,
      {RetailerHeader? fallbackHeader}) {
    final vId = _firstNonEmpty([
      json['VisiterId'],
      json['visiterId'],
      json['VisiterID'],
      json['visiter_id'],
      json['RetailerId'],
      json['retailerId'],
      json['retailerID'],
      json['retailer_id'],
      fallbackHeader?.visiterId,
    ]);

    final bName = _firstNonEmpty([
      json['Business_Name'],
      json['business_Name'],
      json['businessName'],
      json['BusinessName'],
      json['business_name'],
      json['ShopName'],
      json['shopName'],
      json['StoreName'],
      json['storeName'],
      json['Name'],
      json['name'],
      fallbackHeader?.businessName,
    ]);

    final pName = _firstNonEmpty([
      json['Person_Name'],
      json['person_Name'],
      json['personName'],
      json['PersonName'],
      json['person_name'],
      json['ContactPerson'],
      json['contactPerson'],
      json['OwnerName'],
      json['ownerName'],
      json['CustomerName'],
      json['customerName'],
      fallbackHeader?.personName,
    ]);

    final directName = _firstNonEmpty([
      json['Name'],
      json['name'],
      fallbackHeader?.businessName,
      fallbackHeader?.personName,
    ]);

    final pic = _firstNonEmpty([
      json['Photo'],
      json['photo'],
      json['PHOTO'],
      json['Image'],
      json['image'],
      json['IMAGE'],
      json['Profile'],
      json['profile'],
      json['ProfileImage'],
      json['profileImage'],
      fallbackHeader?.photo,
    ]);

    final parsedState = _firstNonEmpty([
      json['State'],
      json['state'],
      json['STATE'],
      json['StateName'],
      json['stateName'],
      json['State_Name'],
      json['state_name'],
      json['Region'],
      json['region'],
      fallbackHeader?.state,
    ]);

    final parsedDistrict = _firstNonEmpty([
      json['District'],
      json['district'],
      json['DISTRICT'],
      json['DistrictName'],
      json['districtName'],
      json['District_Name'],
      json['district_name'],
      json['City'],
      json['city'],
      json['CityName'],
      json['cityName'],
      json['PostOffice'],
      json['postOffice'],
      fallbackHeader?.district,
    ]);

    final parsedBlock = _firstNonEmpty([
      json['Block'],
      json['block'],
      json['BLOCK'],
      json['BlockName'],
      json['blockName'],
      json['Block_Name'],
      json['block_name'],
      json['Tehsil'],
      json['tehsil'],
      json['Area'],
      json['area'],
      fallbackHeader?.block,
    ]);

    final parsedAddress = _firstNonEmpty([
      json['Address'],
      json['address'],
      json['ADDRESS'],
      json['Address1'],
      json['address1'],
      json['businessAddress'],
      json['BusinessAddress'],
      json['permanentAddress'],
      json['PermanentAddress'],
      json['Street'],
      json['street'],
      fallbackHeader?.address,
    ]);

    final parsedCountry = _firstNonEmpty([
      json['Country'],
      json['country'],
      json['COUNTRY'],
      json['CountryName'],
      json['countryName'],
      fallbackHeader?.country,
      'India',
    ]);

    final parsedEmpType = _firstNonEmpty([
      json['Emp_Type'],
      json['emp_Type'],
      json['empType'],
      json['EmpType'],
      json['emp_type'],
      json['EmployeeType'],
      json['employeeType'],
      fallbackHeader?.empType,
    ]);

    final parsedEmpMobile = _firstNonEmpty([
      json['Emp_Mobile'],
      json['emp_Mobile'],
      json['empMobile'],
      json['EmpMobile'],
      json['emp_mobile'],
      fallbackHeader?.empMobile,
    ]);

    final parsedEmpName = _firstNonEmpty([
      json['Emp_Name'],
      json['emp_Name'],
      json['empName'],
      json['EmpName'],
      json['emp_name'],
      json['EmployeeName'],
      json['employeeName'],
      fallbackHeader?.empName,
    ]);

    final parsedVisitFor = _firstNonEmpty([
      json['Visit_for'],
      json['visit_for'],
      json['visitFor'],
      json['VisitFor'],
      fallbackHeader?.visitFor,
    ]);

    final parsedMobile = _firstNonEmpty([
      json['Mobile'],
      json['mobile'],
      json['MOBILE'],
      json['Phone'],
      json['phone'],
      json['Contact'],
      json['contact'],
      fallbackHeader?.mobile,
    ]);

    final parsedPurpose = _firstNonEmpty([
      json['Purpose'],
      json['purpose'],
      json['PURPOSE'],
      fallbackHeader?.purpose,
      'Retailer',
    ]);

    final parsedVisitDate = _firstNonEmpty([
      json['VisitDate'],
      json['visitDate'],
      json['visit_date'],
      json['Visit_Date'],
      fallbackHeader?.visitDate,
    ]);

    final parsedRevisitDate = _firstNonEmpty([
      json['RevisitDate'],
      json['revisitDate'],
      json['revisit_date'],
      json['Revisit_Date'],
      fallbackHeader?.revisitDate,
    ]);

    final parsedRemark = _firstNonEmpty([
      json['Remark'],
      json['remark'],
      json['REMARK'],
      json['Remarks'],
      json['remarks'],
      fallbackHeader?.remark,
    ]);

    final parsedEmpId = _firstNonEmpty([
      json['EmployeeId'],
      json['employeeId'],
      json['EmployeeID'],
      json['employee_id'],
      json['EmpId'],
      json['empId'],
      fallbackHeader?.employeeId,
    ]);

    return RetailerItem(
      id: json['Id'] is int
          ? json['Id']
          : (json['id'] is int
              ? json['id']
              : int.tryParse(json['Id']?.toString() ??
                  json['id']?.toString() ??
                  fallbackHeader?.id?.toString() ??
                  '')),
      visiterId: vId,
      empType: parsedEmpType,
      empMobile: parsedEmpMobile,
      visitFor: parsedVisitFor,
      country: parsedCountry,
      state: parsedState,
      district: parsedDistrict,
      block: parsedBlock,
      businessName: bName,
      personName: pName,
      mobile: parsedMobile,
      address: parsedAddress,
      purpose: parsedPurpose,
      photo: pic,
      reVisited: json['Re_visited'] ??
          json['re_visited'] ??
          json['reVisited'] ??
          fallbackHeader?.reVisited,
      visitDate: parsedVisitDate,
      remark: parsedRemark,
      empName: parsedEmpName,
      revisitDate: parsedRevisitDate,
      password: _firstNonEmpty([json['Password'], json['password'], fallbackHeader?.password]),
      employeeId: parsedEmpId,
      status: _firstNonEmpty([json['Status'], json['status'], 'Active']),
      retailerCode: _firstNonEmpty([json['RetailerCode'], json['retailerCode']]),
      joinDate: _firstNonEmpty([json['JoinDate'], json['joinDate']]),
      gender: _firstNonEmpty([json['Gender'], json['gender']]),
      nameField: directName,
      fatherName: _firstNonEmpty([json['FatherName'], json['fatherName']]),
      mobileAlt: _firstNonEmpty([json['MobileAlt'], json['mobileAlt']]),
      email: _firstNonEmpty([json['Email'], json['email']]),
      postOffice: _firstNonEmpty([json['PostOffice'], json['postOffice']]),
      createdAt: _firstNonEmpty([json['CreatedAt'], json['createdAt']]),
      updatedAt: _firstNonEmpty([json['UpdatedAt'], json['updatedAt']]),
      emergenceNo: _firstNonEmpty([json['EmergenceNo'], json['emergenceNo']]),
      billedGroup: _firstNonEmpty([json['BilledGroup'], json['billedGroup']]),
    );
  }

  factory RetailerItem.fromHeader(RetailerHeader header) {
    return RetailerItem(
      id: header.id,
      visiterId: header.visiterId,
      empType: header.empType,
      empMobile: header.empMobile,
      visitFor: header.visitFor,
      country: header.country ?? 'India',
      state: header.state,
      district: header.district,
      block: header.block,
      businessName: header.businessName,
      personName: header.personName,
      mobile: header.mobile,
      address: header.address,
      purpose: header.purpose ?? 'Retailer',
      photo: header.photo,
      reVisited: header.reVisited,
      visitDate: header.visitDate,
      remark: header.remark,
      empName: header.empName,
      revisitDate: header.revisitDate,
      password: header.password,
      employeeId: header.employeeId,
      status: 'Active',
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'VisiterId': visiterId,
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
        'EmployeeId': employeeId,
      };

  // Backwards compatibility getters
  String? get retailerId => visiterId;
  String? get image => photo;
  String? get employeeType => empType ?? 'Retailer';

  String? get name {
    if (businessName != null && businessName!.trim().isNotEmpty) {
      return businessName!.trim();
    }
    if (personName != null && personName!.trim().isNotEmpty) {
      return personName!.trim();
    }
    if (nameField != null && nameField!.trim().isNotEmpty) {
      return nameField!.trim();
    }
    if (visiterId != null && visiterId!.trim().isNotEmpty) {
      return 'Retailer $visiterId';
    }
    return 'Retailer Partner';
  }

  String get displayName => name ?? 'Retailer Partner';

  String get resolvedImageUrl {
    final raw = photo ?? image;
    if (raw == null || raw.trim().isEmpty) return '';
    final path = raw.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$imageBaseUrl$path';
    return '$imageBaseUrl/$path';
  }

  bool get isActive {
    if (status == null) return true;
    final lower = status!.trim().toLowerCase();
    return lower == 'active' || lower == 'true' || lower == '1';
  }

  String get effectiveVisiterId => (visiterId != null && visiterId!.trim().isNotEmpty)
      ? visiterId!.trim()
      : (id != null ? id.toString() : '');

  String get displayId => effectiveVisiterId.isNotEmpty ? effectiveVisiterId : '--';

  String get displayMobile => (mobile != null && mobile!.trim().isNotEmpty)
      ? mobile!.trim()
      : ((empMobile != null && empMobile!.trim().isNotEmpty) ? empMobile!.trim() : 'N/A');

  String get displayLocation {
    final List<String> parts = [];
    if (block != null && block!.trim().isNotEmpty) parts.add(block!.trim());
    if (district != null && district!.trim().isNotEmpty) parts.add(district!.trim());
    if (state != null && state!.trim().isNotEmpty) parts.add(state!.trim());
    if (parts.isEmpty) return country ?? 'India';
    return parts.join(', ');
  }
}

String? _firstNonEmpty(List<dynamic> values) {
  for (final v in values) {
    if (v != null) {
      final str = v.toString().trim();
      if (str.isNotEmpty && str.toLowerCase() != 'null') {
        return str;
      }
    }
  }
  return null;
}
