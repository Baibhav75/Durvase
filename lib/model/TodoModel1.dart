class TodoModel1 {
  List<Data1>? data1;
  String? message;

  TodoModel1({this.data1, this.message});

  TodoModel1.fromJson(Map<String, dynamic> json) {
    if (json['data1'] != null) {
      data1 = <Data1>[];
      json['data1'].forEach((v) {
        data1!.add(Data1.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data1 != null) {
      data['data1'] = this.data1!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }

  // Helper method to get first employee data
  Data1? get firstEmployee {
    if (data1 != null && data1!.isNotEmpty) {
      return data1!.first;
    }
    return null;
  }
}

class Data1 {
  int? id;
  String? employeeId;
  String? status;
  String? employeeCode;
  String? userId;
  String? password;
  String? joinDate;
  String? gender;
  String? name;
  String? fatherName;
  String? address;
  String? mobile;
  String? mobileAlt;
  String? email;
  String? postOffice;
  String? country;
  String? state;
  String? district;
  String? block;
  String? employeeType;
  String? createdAt;
  String? updatedAt;
  String? empId;
  String? image;
  String? emergenceNo;
  String? billedGroup;

  Data1({
    this.id,
    this.employeeId,
    this.status,
    this.employeeCode,
    this.userId,
    this.password,
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
    this.empId,
    this.image,
    this.emergenceNo,
    this.billedGroup,
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['Id'] is int ? json['Id'] : int.tryParse('${json['Id']}');
    final resolvedEmpId = _parseString(
      json['EmpId'] ??
      json['empId'] ??
      json['EmployeeId'] ??
      json['employeeId'] ??
      json['EmployeeCode'] ??
      json['employeeCode'] ??
      json['id'] ??
      json['Id'],
    );
    empId = resolvedEmpId;
    employeeId = resolvedEmpId;

    status = _parseString(json['Status'] ?? json['status']);
    employeeCode = _parseString(json['EmployeeCode'] ?? json['employeeCode'] ?? json['employee_code']) ?? resolvedEmpId;
    userId = _parseString(json['UserId'] ?? json['userId'] ?? json['user_id']);
    password = _parseString(json['Password'] ?? json['password']);
    joinDate = _parseString(json['JoinDate'] ?? json['joinDate'] ?? json['join_date']);
    gender = _parseString(json['Gender'] ?? json['gender']);
    name = _parseString(json['Name'] ?? json['name'] ?? json['emp_name']);
    fatherName = _parseString(json['FatherName'] ?? json['fatherName'] ?? json['father_name']);
    address = _parseString(json['Address'] ?? json['address']);
    mobile = _parseString(json['Mobile'] ?? json['mobile'] ?? json['Phone'] ?? json['phone']);
    mobileAlt = _parseString(json['MobileAlt'] ?? json['mobileAlt'] ?? json['mobile_alt']);
    email = _parseString(json['Email'] ?? json['email']);
    postOffice = _parseString(json['PostOffice'] ?? json['postOffice'] ?? json['post_office']);
    country = _parseString(json['Country'] ?? json['country']);
    state = _parseString(json['State'] ?? json['state'] ?? json['Region'] ?? json['region']);
    district = _parseString(json['District'] ?? json['district'] ?? json['City'] ?? json['city'] ?? json['Area'] ?? json['area']);
    block = _parseString(json['Block'] ?? json['block']);
    employeeType = _parseString(json['EmployeeType'] ?? json['employeeType'] ?? json['employee_type']) ?? 'MR';
    createdAt = _parseString(json['CreatedAt'] ?? json['createdAt'] ?? json['created_at']);
    updatedAt = _parseString(json['UpdatedAt'] ?? json['updatedAt'] ?? json['updated_at']);
    image = _parseString(json['Image'] ?? json['image'] ?? json['ProfileImage'] ?? json['profile_image'] ?? json['Photo']);
    emergenceNo = _parseString(json['EmergenceNo'] ?? json['emergenceNo'] ?? json['EmergencyNo'] ?? json['emergencyNo'] ?? json['emergency_no']);
    billedGroup = _parseString(json['BilledGroup'] ?? json['billedGroup'] ?? json['BloodGroup'] ?? json['bloodGroup'] ?? json['blood_group']);
  }

  // Helper method to handle null and empty strings
  String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['EmployeeId'] = employeeId;
    data['Status'] = status;
    data['EmployeeCode'] = employeeCode;
    data['UserId'] = userId;
    data['Password'] = password;
    data['JoinDate'] = joinDate;
    data['Gender'] = gender;
    data['Name'] = name;
    data['FatherName'] = fatherName;
    data['Address'] = address;
    data['Mobile'] = mobile;
    data['MobileAlt'] = mobileAlt;
    data['Email'] = email;
    data['PostOffice'] = postOffice;
    data['Country'] = country;
    data['State'] = state;
    data['District'] = district;
    data['Block'] = block;
    data['EmployeeType'] = employeeType;
    data['CreatedAt'] = createdAt;
    data['UpdatedAt'] = updatedAt;
    data['EmpId'] = empId;
    data['Image'] = image;
    data['EmergenceNo'] = emergenceNo;
    data['BilledGroup'] = billedGroup;
    return data;
  }

  String get resolvedImageUrl {
    if (image == null || image!.trim().isEmpty) return '';
    final path = image!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    const baseUrl = 'https://durvasaayurved.online';
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }

  // Helper methods to check location data availability
  bool get hasCountry => country != null && country!.isNotEmpty;
  bool get hasState => state != null && state!.isNotEmpty;
  bool get hasDistrict => district != null && district!.isNotEmpty;
  bool get hasBlock => block != null && block!.isNotEmpty;
  bool get hasPostOffice => postOffice != null && postOffice!.isNotEmpty;

  // Get location details with fallbacks
  String get displayCountry => country ?? 'Not Available';
  String get displayState => state ?? 'Not Available';
  String get displayDistrict => district ?? 'Not Available';
  String get displayBlock => block ?? 'Not Available';
  String get displayPostOffice => postOffice ?? 'Not Available';
}
