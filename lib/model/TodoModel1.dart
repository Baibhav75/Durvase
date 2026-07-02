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
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    employeeId = _parseString(json['EmployeeId']);
    status = _parseString(json['Status']);
    employeeCode = _parseString(json['EmployeeCode']);
    userId = _parseString(json['UserId']);
    password = _parseString(json['Password']);
    joinDate = _parseString(json['JoinDate']);
    gender = _parseString(json['Gender']);
    name = _parseString(json['Name']);
    fatherName = _parseString(json['FatherName']);
    address = _parseString(json['Address']);
    mobile = _parseString(json['Mobile']);
    mobileAlt = _parseString(json['MobileAlt']);
    email = _parseString(json['Email']);
    postOffice = _parseString(json['PostOffice']);
    country = _parseString(json['Country']);
    state = _parseString(json['State']);
    district = _parseString(json['District']);
    block = _parseString(json['Block']);
    employeeType = _parseString(json['EmployeeType']);
    createdAt = _parseString(json['CreatedAt']);
    updatedAt = _parseString(json['UpdatedAt']);
    empId = _parseString(json['EmpId']);
    image = _parseString(json['Image']);
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
    return data;
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
