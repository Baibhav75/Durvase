// model/selectVisitlist_model.dart

class selectVisitlist_model {
  String? message;
  List<Visitors>? visitors;

  selectVisitlist_model({this.message, this.visitors});

  selectVisitlist_model.fromJson(Map<String, dynamic> json) {
    message = json['Message'] ?? json['message'];
    if (json['Visitors'] != null) {
      visitors = <Visitors>[];
      json['Visitors'].forEach((v) {
        visitors!.add(Visitors.fromJson(v));
      });
    } else if (json['visitors'] != null) {
      visitors = <Visitors>[];
      json['visitors'].forEach((v) {
        visitors!.add(Visitors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Message'] = message;
    if (visitors != null) {
      data['Visitors'] = visitors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Visitors {
  int? id;
  String? empName;
  String? empType;
  String? empMobile;
  String? visitFor;
  String? country;
  String? state;
  String? district;
  String? block;
  String? businessName;
  String? personName;
  String? mobile;
  String? address;
  String? purpose;
  String? photo;
  String? reVisited;
  String? visitDate;
  String? revisitDate;
  String? remark;
  String? message;
  String? photoBase64;

  // New properties
  String? password;
  String? visiterId;
  String? employeeId;

  Visitors({
    this.id,
    this.empName,
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
    this.revisitDate,
    this.remark,
    this.message,
    this.photoBase64,
    this.password,
    this.visiterId,
    this.employeeId,
  });

  Visitors.fromJson(Map<String, dynamic> json) {
    id = json['Id'] is int ? json['Id'] : int.tryParse('${json['Id']}');
    empName = json['Emp_Name'] ?? json['emp_name'] ?? json['EmpName'];
    empType = json['Emp_Type'] ?? json['emp_type'] ?? json['EmpType'];
    empMobile = json['Emp_Mobile'] ?? json['emp_mobile'] ?? json['EmpMobile'];
    visitFor = json['Visit_for'] ?? json['visit_for'] ?? json['VisitFor'];
    country = json['Country'] ?? json['country'];
    state = json['State'] ?? json['state'];
    district = json['District'] ?? json['district'];
    block = json['Block'] ?? json['block'];
    businessName = json['Business_Name'] ?? json['business_name'] ?? json['BusinessName'];
    personName = json['Person_Name'] ?? json['person_name'] ?? json['PersonName'];
    mobile = json['Mobile'] ?? json['mobile'];
    address = json['Address'] ?? json['address'];
    purpose = json['Purpose'] ?? json['purpose'];
    photo = json['Photo'] ?? json['photo'];
    reVisited = json['Re_visited'] ?? json['re_visited'] ?? json['ReVisited'];
    visitDate = json['VisitDate'] ?? json['visitDate'] ?? json['visit_date'];
    revisitDate = json['RevisitDate'] ?? json['revisitDate'] ?? json['revisit_date'];
    remark = json['Remark'] ?? json['remark'];
    message = json['message'] ?? json['Message'];
    photoBase64 = json['PhotoBase64'] ?? json['photoBase64'];

    // New properties
    password = json['Password'] ?? json['password'];
    visiterId = json['VisiterId']?.toString() ?? json['visiterId']?.toString();
    employeeId = json['EmployeeId']?.toString() ??
        json['employeeId']?.toString() ??
        json['Emp_Id']?.toString() ??
        json['emp_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Emp_Name'] = empName;
    data['Emp_Type'] = empType;
    data['Emp_Mobile'] = empMobile;
    data['Visit_for'] = visitFor;
    data['Country'] = country;
    data['State'] = state;
    data['District'] = district;
    data['Block'] = block;
    data['Business_Name'] = businessName;
    data['Person_Name'] = personName;
    data['Mobile'] = mobile;
    data['Address'] = address;
    data['Purpose'] = purpose;
    data['Photo'] = photo;
    data['Re_visited'] = reVisited;
    data['VisitDate'] = visitDate;
    data['RevisitDate'] = revisitDate;
    data['Remark'] = remark;
    data['message'] = message;
    data['PhotoBase64'] = photoBase64;

    // New properties
    data['Password'] = password;
    data['VisiterId'] = visiterId;
    data['EmployeeId'] = employeeId;
    return data;
  }

  // Helper methods for better data handling
  String get displayName {
    return personName ?? businessName ?? 'Unknown Visitor';
  }

  String get displayMobile {
    return mobile ?? 'No Mobile Number';
  }

  String get displayAddress {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }

    final addressParts = [block, district, state, country]
        .where((part) => part != null && part!.isNotEmpty)
        .toList();

    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Address not available';
  }

  String get displayPurpose {
    return purpose ?? 'No Purpose Specified';
  }

  bool get hasBusinessInfo {
    return businessName != null && businessName!.isNotEmpty;
  }
}