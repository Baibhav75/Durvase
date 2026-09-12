class RetailerModel {
  final String visiterId;
  final String loginData;
  final String personName;
  final String businessName;
  final String phone;
  final String address;
  final String photo;
  final String empType;
  final String visitFor;
  final String purpose;
  final String status;
  final String message;
  final String email;

  RetailerModel({
    String visiterId = '',
    this.loginData = '',
    String personName = '',
    this.businessName = '',
    this.phone = '',
    String address = '',
    String photo = '',
    this.empType = '',
    this.visitFor = '',
    this.purpose = '',
    this.status = '',
    this.message = '',
    this.email = '',
    // Legacy support named parameters
    String? retailerId,
    String? name,
    String? businessAddress,
    String? profile,
  })  : visiterId = visiterId.isNotEmpty ? visiterId : (retailerId ?? ''),
        personName = personName.isNotEmpty ? personName : (name ?? ''),
        address = address.isNotEmpty ? address : (businessAddress ?? ''),
        photo = photo.isNotEmpty ? photo : (profile ?? '');


  // Backward compatibility getters
  String get retailerId => visiterId;
  String get name => personName.isNotEmpty ? personName : businessName;
  String get businessAddress => address;
  String get profile => photo;

  // Convenient full photo URL generator
  String get fullPhotoUrl {
    if (photo.isEmpty) return '';
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }
    return 'https://durvasaayurved.com${photo.startsWith('/') ? '' : '/'}$photo';
  }

  factory RetailerModel.fromJson(Map<String, dynamic> json) {
    final rawVisiterId = json['VisiterID'] ??
        json['visiterID'] ??
        json['visiterId'] ??
        json['RetailerID'] ??
        json['retailerId'] ??
        json['retailerID'] ??
        '';

    final rawPersonName = json['personName'] ?? json['name'] ?? '';
    final rawBusinessName = json['businessName'] ?? json['business_name'] ?? '';
    final rawPhone = json['phone'] ?? json['mobile'] ?? '';
    final rawAddress = json['address'] ?? json['businessAddress'] ?? '';
    final rawPhoto = json['photo'] ?? json['profile'] ?? '';
    final rawLoginData = json['LoginData'] ?? json['loginData'] ?? '';
    final rawEmpType = json['empType'] ?? json['emp_type'] ?? '';
    final rawVisitFor = json['visitFor'] ?? json['visit_for'] ?? '';
    final rawPurpose = json['purpose'] ?? '';
    final rawStatus = json['status'] ?? '';
    final rawMessage = json['message'] ?? '';
    final rawEmail = json['email'] ?? '';

    return RetailerModel(
      visiterId: rawVisiterId.toString().trim(),
      loginData: rawLoginData.toString().trim(),
      personName: rawPersonName.toString().trim(),
      businessName: rawBusinessName.toString().trim(),
      phone: rawPhone.toString().trim(),
      address: rawAddress.toString().trim(),
      photo: rawPhoto.toString().trim(),
      empType: rawEmpType.toString().trim(),
      visitFor: rawVisitFor.toString().trim(),
      purpose: rawPurpose.toString().trim(),
      status: rawStatus.toString().trim(),
      message: rawMessage.toString().trim(),
      email: rawEmail.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'VisiterID': visiterId,
      'RetailerID': visiterId,
      'LoginData': loginData,
      'personName': personName,
      'name': name,
      'businessName': businessName,
      'phone': phone,
      'address': address,
      'businessAddress': address,
      'photo': photo,
      'profile': photo,
      'empType': empType,
      'visitFor': visitFor,
      'purpose': purpose,
      'status': status,
      'message': message,
      'email': email,
    };
  }

  RetailerModel copyWith({
    String? visiterId,
    String? loginData,
    String? personName,
    String? businessName,
    String? phone,
    String? address,
    String? photo,
    String? empType,
    String? visitFor,
    String? purpose,
    String? status,
    String? message,
    String? email,
  }) {
    return RetailerModel(
      visiterId: visiterId ?? this.visiterId,
      loginData: loginData ?? this.loginData,
      personName: personName ?? this.personName,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      empType: empType ?? this.empType,
      visitFor: visitFor ?? this.visitFor,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      message: message ?? this.message,
      email: email ?? this.email,
    );
  }
}
