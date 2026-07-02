// model/visit_history_model.dart

class VisitHistory_model {
  String? message;
  List<Visitors>? visitors;

  VisitHistory_model({this.message, this.visitors});

  VisitHistory_model.fromJson(Map<String, dynamic> json) {
    message = json['Message'];
    if (json['Visitors'] != null) {
      visitors = <Visitors>[];
      json['Visitors'].forEach((v) {
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
  String? empName;

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
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
    data['Remark'] = remark;
    data['Emp_Name'] = empName;
    return data;
  }
}