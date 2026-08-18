class EditEmployeeProfileResponse {
  final bool success;
  final String message;
  final UpdatedEmployeeData? data;

  EditEmployeeProfileResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditEmployeeProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditEmployeeProfileResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? UpdatedEmployeeData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UpdatedEmployeeData {
  final int? id;
  final String? empId;
  final String? name;
  final String? mobile;
  final String? email;
  final String? status;
  final String? gender;
  final String? district;
  final String? block;
  final String? address;
  final String? image;
  final String? updatedTime;

  UpdatedEmployeeData({
    this.id,
    this.empId,
    this.name,
    this.mobile,
    this.email,
    this.status,
    this.gender,
    this.district,
    this.block,
    this.address,
    this.image,
    this.updatedTime,
  });

  factory UpdatedEmployeeData.fromJson(Map<String, dynamic> json) {
    return UpdatedEmployeeData(
      id: json['Id'] is int ? json['Id'] : int.tryParse('${json['Id']}'),
      empId: json['EmpId']?.toString(),
      name: json['Name']?.toString(),
      mobile: json['Mobile']?.toString(),
      email: json['Email']?.toString(),
      status: json['Status']?.toString(),
      gender: json['Gender']?.toString(),
      district: json['District']?.toString(),
      block: json['Block']?.toString(),
      address: json['Address']?.toString(),
      image: json['Image']?.toString(),
      updatedTime: json['UpdatedTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EmpId': empId,
      'Name': name,
      'Mobile': mobile,
      'Email': email,
      'Status': status,
      'Gender': gender,
      'District': district,
      'Block': block,
      'Address': address,
      'Image': image,
      'UpdatedTime': updatedTime,
    };
  }
}
