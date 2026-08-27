class EditRetailerModel {
  final String retailerId;
  final String? status;
  final String? retailerCode;
  final String? password;
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
  final String? image;
  final String? emergenceNo;
  final String? billedGroup;

  EditRetailerModel({
    required this.retailerId,
    this.status,
    this.retailerCode,
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
    this.image,
    this.emergenceNo,
    this.billedGroup,
  });

  factory EditRetailerModel.fromJson(Map<String, dynamic> json) {
    return EditRetailerModel(
      retailerId: json['RetailerId']?.toString() ?? '',
      status: json['Status']?.toString(),
      retailerCode: json['RetailerCode']?.toString(),
      password: json['Password']?.toString(),
      joinDate: json['JoinDate']?.toString(),
      gender: json['Gender']?.toString(),
      name: json['Name']?.toString(),
      fatherName: json['FatherName']?.toString(),
      address: json['Address']?.toString(),
      mobile: json['Mobile']?.toString(),
      mobileAlt: json['MobileAlt']?.toString(),
      email: json['Email']?.toString(),
      postOffice: json['PostOffice']?.toString(),
      country: json['Country']?.toString(),
      state: json['State']?.toString(),
      district: json['District']?.toString(),
      block: json['Block']?.toString(),
      employeeType: json['EmployeeType']?.toString(),
      image: json['Image']?.toString(),
      emergenceNo: json['EmergenceNo']?.toString(),
      billedGroup: json['BilledGroup']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'RetailerId': retailerId,
    };

    if (status != null) data['Status'] = status;
    if (retailerCode != null) data['RetailerCode'] = retailerCode;
    if (password != null && password!.isNotEmpty) data['Password'] = password;
    if (joinDate != null) data['JoinDate'] = joinDate;
    if (gender != null) data['Gender'] = gender;
    if (name != null) data['Name'] = name;
    if (fatherName != null) data['FatherName'] = fatherName;
    if (address != null) data['Address'] = address;
    if (mobile != null) data['Mobile'] = mobile;
    if (mobileAlt != null) data['MobileAlt'] = mobileAlt;
    if (email != null) data['Email'] = email;
    if (postOffice != null) data['PostOffice'] = postOffice;
    if (country != null) data['Country'] = country;
    if (state != null) data['State'] = state;
    if (district != null) data['District'] = district;
    if (block != null) data['Block'] = block;
    if (employeeType != null) data['EmployeeType'] = employeeType;
    if (image != null) data['Image'] = image;
    if (emergenceNo != null) data['EmergenceNo'] = emergenceNo;
    if (billedGroup != null) data['BilledGroup'] = billedGroup;

    return data;
  }
}

class EditRetailerResponse {
  final dynamic status;
  final dynamic message;
  final dynamic data;

  EditRetailerResponse({
    this.status,
    this.message,
    this.data,
  });

  bool get isSuccess {
    final s = status?.toString().toLowerCase();
    return s == 'success' || s == 'true' || s == '200';
  }

  factory EditRetailerResponse.fromJson(Map<String, dynamic> json) {
    return EditRetailerResponse(
      status: json['status'] ?? json['Status'],
      message: json['message'] ?? json['Message'],
      data: json['data'] ?? json['Data'],
    );
  }
}
