// model/selectVisitlist_model.dart

class selectVisitlist_model {
  String? message;
  List<Visitors>? visitors;

  selectVisitlist_model({this.message, this.visitors});

  selectVisitlist_model.fromJson(Map<String, dynamic> json) {
    message = json['Message'];
    if (json['Visitors'] != null) {
      visitors = <Visitors>[];
      json['Visitors'].forEach((v) {
        visitors!.add(new Visitors.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Message'] = this.message;
    if (this.visitors != null) {
      data['Visitors'] = this.visitors!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Visitors {
  int? id;
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
  String? remark;
  dynamic empName;

  Visitors({
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
  });

  Visitors.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    empType = json['Emp_Type'];
    empMobile = json['Emp_Mobile'];
    visitFor = json['Visit_for'];
    country = json['Country'];
    state = json['State'];
    district = json['District'];
    block = json['Block'];
    businessName = json['Business_Name'];
    personName = json['Person_Name'];
    mobile = json['Mobile'];
    address = json['Address'];
    purpose = json['Purpose'];
    photo = json['Photo'];
    reVisited = json['Re_visited'];
    visitDate = json['VisitDate'];
    remark = json['Remark'];
    empName = json['Emp_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Emp_Type'] = this.empType;
    data['Emp_Mobile'] = this.empMobile;
    data['Visit_for'] = this.visitFor;
    data['Country'] = this.country;
    data['State'] = this.state;
    data['District'] = this.district;
    data['Block'] = this.block;
    data['Business_Name'] = this.businessName;
    data['Person_Name'] = this.personName;
    data['Mobile'] = this.mobile;
    data['Address'] = this.address;
    data['Purpose'] = this.purpose;
    data['Photo'] = this.photo;
    data['Re_visited'] = this.reVisited;
    data['VisitDate'] = this.visitDate;
    data['Remark'] = this.remark;
    data['Emp_Name'] = this.empName;
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