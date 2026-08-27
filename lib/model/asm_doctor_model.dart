class DoctorResponseModel {
  final bool? status;
  final String? message;
  final int? totalVisitors;
  final List<DoctorModel> data;

  DoctorResponseModel({
    this.status,
    this.message,
    this.totalVisitors,
    this.data = const [],
  });

  factory DoctorResponseModel.fromJson(Map<String, dynamic> json) {
    return DoctorResponseModel(
      status: json['status'] as bool?,
      message: json['message']?.toString(),
      totalVisitors: json['TotalVisitors'] is int
          ? json['TotalVisitors']
          : int.tryParse(json['TotalVisitors']?.toString() ?? ''),
      data: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => DoctorModel.fromJson(item))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'TotalVisitors': totalVisitors,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class DoctorModel {
  final int? id;
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
  final DateTime? visitDate;
  final String? remark;
  final String? empName;
  final DateTime? revisitDate;

  DoctorModel({
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
    this.revisitDate,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: _parseInt(json['Id']),
      empType: _parseString(json['Emp_Type']),
      empMobile: _parseString(json['Emp_Mobile']),
      visitFor: _parseString(json['Visit_for']),
      country: _parseString(json['Country']),
      state: _parseString(json['State']),
      district: _parseString(json['District']),
      block: _parseString(json['Block']),
      businessName: _parseString(json['Business_Name']),
      personName: _parseString(json['Person_Name']),
      mobile: _parseString(json['Mobile']),
      address: _parseString(json['Address']),
      purpose: _parseString(json['Purpose']),
      photo: _parseString(json['Photo']),
      reVisited: _parseString(json['Re_visited']),
      visitDate: _parseDateTime(json['VisitDate']),
      remark: _parseString(json['Remark']),
      empName: _parseString(json['Emp_Name']),
      revisitDate: _parseDateTime(json['RevisitDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
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
      'VisitDate': visitDate?.toIso8601String(),
      'Remark': remark,
      'Emp_Name': empName,
      'RevisitDate': revisitDate?.toIso8601String(),
    };
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}