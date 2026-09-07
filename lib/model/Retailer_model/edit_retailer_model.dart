class EditRetailerModel {
  final int? id;
  final String visiterId;
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
  final String? emergenceNo;
  final String? billedGroup;

  EditRetailerModel({
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
    this.password,
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

  // Backward compatibility getters
  String get retailerId => visiterId;
  String? get name => (personName != null && personName!.isNotEmpty)
      ? personName
      : businessName;
  String? get image => photo;

  factory EditRetailerModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['Id'] is int
        ? json['Id'] as int
        : int.tryParse(json['Id']?.toString() ?? json['id']?.toString() ?? '');

    final rawVisiterId = json['VisiterId'] ??
        json['visiterId'] ??
        json['visiterID'] ??
        json['RetailerId'] ??
        json['retailerId'] ??
        '';

    final rawPersonName = json['Person_Name'] ??
        json['person_name'] ??
        json['personName'] ??
        json['PersonName'] ??
        json['Name'] ??
        json['name'];

    final rawBusinessName = json['Business_Name'] ??
        json['business_name'] ??
        json['businessName'] ??
        json['BusinessName'];

    final rawEmpType = json['Emp_Type'] ??
        json['emp_type'] ??
        json['empType'] ??
        json['EmpType'] ??
        json['EmployeeType'] ??
        json['employeeType'];

    final rawEmpMobile = json['Emp_Mobile'] ??
        json['emp_mobile'] ??
        json['empMobile'] ??
        json['EmpMobile'];

    final rawVisitFor = json['Visit_for'] ??
        json['visit_for'] ??
        json['visitFor'] ??
        json['VisitFor'];

    final rawCountry = json['Country'] ?? json['country'] ?? 'India';
    final rawState = json['State'] ?? json['state'];
    final rawDistrict = json['District'] ?? json['district'];
    final rawBlock = json['Block'] ?? json['block'];
    final rawMobile = json['Mobile'] ?? json['mobile'] ?? json['phone'];
    final rawAddress = json['Address'] ?? json['address'] ?? json['businessAddress'];
    final rawPurpose = json['Purpose'] ?? json['purpose'] ?? 'Retailer';
    final rawPhoto = json['Photo'] ?? json['photo'] ?? json['Image'] ?? json['image'];
    final rawReVisited = json['Re_visited'] ?? json['re_visited'] ?? json['reVisited'] ?? json['ReVisited'];
    final rawVisitDate = json['VisitDate'] ?? json['visitDate'] ?? json['visit_date'];
    final rawRemark = json['Remark'] ?? json['remark'] ?? json['remarks'];
    final rawEmpName = json['Emp_Name'] ?? json['emp_name'] ?? json['empName'] ?? json['EmpName'];
    final rawRevisitDate = json['RevisitDate'] ?? json['revisitDate'] ?? json['revisit_date'];
    final rawPassword = json['Password'] ?? json['password'];
    final rawEmployeeId = json['EmployeeId'] ?? json['employeeId'] ?? json['empId'] ?? json['employee_id'];

    return EditRetailerModel(
      id: rawId,
      visiterId: rawVisiterId.toString().trim(),
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
      password: rawPassword?.toString().trim(),
      employeeId: rawEmployeeId?.toString().trim(),
      // Legacy fields
      status: json['Status']?.toString().trim() ?? json['status']?.toString().trim(),
      retailerCode: json['RetailerCode']?.toString().trim() ?? json['retailerCode']?.toString().trim(),
      joinDate: json['JoinDate']?.toString().trim() ?? json['joinDate']?.toString().trim(),
      gender: json['Gender']?.toString().trim() ?? json['gender']?.toString().trim(),
      fatherName: json['FatherName']?.toString().trim() ?? json['fatherName']?.toString().trim(),
      mobileAlt: json['MobileAlt']?.toString().trim() ?? json['mobileAlt']?.toString().trim(),
      email: json['Email']?.toString().trim() ?? json['email']?.toString().trim(),
      postOffice: json['PostOffice']?.toString().trim() ?? json['postOffice']?.toString().trim(),
      employeeType: rawEmpType?.toString().trim() ?? 'Retailer',
      emergenceNo: json['EmergenceNo']?.toString().trim() ?? json['emergenceNo']?.toString().trim(),
      billedGroup: json['BilledGroup']?.toString().trim() ?? json['billedGroup']?.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Exact C# Model: Tbl_Visiter properties
    if (id != null) {
      data['Id'] = id;
      data['id'] = id;
    }

    data['VisiterId'] = visiterId;
    data['visiterId'] = visiterId;
    data['RetailerId'] = visiterId;
    data['retailerId'] = visiterId;

    if (empType != null && empType!.isNotEmpty) {
      data['Emp_Type'] = empType;
      data['emp_type'] = empType;
      data['EmpType'] = empType;
      data['EmployeeType'] = empType;
    }

    if (empMobile != null && empMobile!.isNotEmpty) {
      data['Emp_Mobile'] = empMobile;
      data['emp_mobile'] = empMobile;
      data['EmpMobile'] = empMobile;
    }

    if (visitFor != null && visitFor!.isNotEmpty) {
      data['Visit_for'] = visitFor;
      data['visit_for'] = visitFor;
      data['VisitFor'] = visitFor;
    }

    if (country != null && country!.isNotEmpty) {
      data['Country'] = country;
      data['country'] = country;
    }

    if (state != null && state!.isNotEmpty) {
      data['State'] = state;
      data['state'] = state;
    }

    if (district != null && district!.isNotEmpty) {
      data['District'] = district;
      data['district'] = district;
    }

    if (block != null && block!.isNotEmpty) {
      data['Block'] = block;
      data['block'] = block;
    }

    if (businessName != null && businessName!.isNotEmpty) {
      data['Business_Name'] = businessName;
      data['business_name'] = businessName;
      data['BusinessName'] = businessName;
    }

    final effectivePersonName = personName ?? name;
    if (effectivePersonName != null && effectivePersonName.isNotEmpty) {
      data['Person_Name'] = effectivePersonName;
      data['person_name'] = effectivePersonName;
      data['PersonName'] = effectivePersonName;
      data['Name'] = effectivePersonName;
      data['name'] = effectivePersonName;
    }

    if (mobile != null && mobile!.isNotEmpty) {
      data['Mobile'] = mobile;
      data['mobile'] = mobile;
    }

    if (address != null && address!.isNotEmpty) {
      data['Address'] = address;
      data['address'] = address;
    }

    if (purpose != null && purpose!.isNotEmpty) {
      data['Purpose'] = purpose;
      data['purpose'] = purpose;
    }

    final effectivePhoto = photo ?? image;
    if (effectivePhoto != null && effectivePhoto.isNotEmpty) {
      data['Photo'] = effectivePhoto;
      data['photo'] = effectivePhoto;
      data['Image'] = effectivePhoto;
      data['image'] = effectivePhoto;
    }

    if (reVisited != null && reVisited!.isNotEmpty) {
      data['Re_visited'] = reVisited;
      data['re_visited'] = reVisited;
      data['ReVisited'] = reVisited;
    }

    if (visitDate != null && visitDate!.isNotEmpty) {
      data['VisitDate'] = visitDate;
      data['visitDate'] = visitDate;
    }

    if (remark != null && remark!.isNotEmpty) {
      data['Remark'] = remark;
      data['remark'] = remark;
    }

    if (empName != null && empName!.isNotEmpty) {
      data['Emp_Name'] = empName;
      data['emp_name'] = empName;
      data['EmpName'] = empName;
    }

    if (revisitDate != null && revisitDate!.isNotEmpty) {
      data['RevisitDate'] = revisitDate;
      data['revisitDate'] = revisitDate;
    }

    if (password != null && password!.isNotEmpty) {
      data['Password'] = password;
      data['password'] = password;
    }

    if (employeeId != null && employeeId!.isNotEmpty) {
      data['EmployeeId'] = employeeId;
      data['employeeId'] = employeeId;
    }

    // Optional legacy support fields
    if (status != null) data['Status'] = status;
    if (retailerCode != null) data['RetailerCode'] = retailerCode;
    if (joinDate != null) data['JoinDate'] = joinDate;
    if (gender != null) data['Gender'] = gender;
    if (fatherName != null) data['FatherName'] = fatherName;
    if (mobileAlt != null) data['MobileAlt'] = mobileAlt;
    if (email != null) data['Email'] = email;
    if (postOffice != null) data['PostOffice'] = postOffice;
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
    return s == 'success' || s == 'true' || s == '200' || data != null;
  }

  factory EditRetailerResponse.fromJson(Map<String, dynamic> json) {
    return EditRetailerResponse(
      status: json['status'] ?? json['Status'],
      message: json['message'] ?? json['Message'],
      data: json['data'] ?? json['Data'],
    );
  }
}

