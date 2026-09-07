class DealerModel {
  final String dealerId;
  final String loginData;
  final String visiterId;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String businessAddress;
  final String purpose;
  final String photo;
  final String state;
  final String district;
  final String gstNumber;

  DealerModel({
    required this.dealerId,
    this.loginData = '',
    this.visiterId = '',
    required this.name,
    this.email = '',
    required this.phone,
    this.businessName = '',
    required this.businessAddress,
    this.purpose = 'Dealer',
    this.photo = '',
    this.state = '',
    this.district = '',
    this.gstNumber = '',
  });

  /// Alias for businessAddress
  String get address => businessAddress;

  /// Full image URL helper with Durvasa Ayurved base URL resolution
  String get resolvedImageUrl {
    if (photo.trim().isEmpty) return '';
    final cleanPhoto = photo.trim();
    if (cleanPhoto.startsWith('http://') || cleanPhoto.startsWith('https://')) {
      return cleanPhoto;
    }
    if (cleanPhoto.startsWith('/')) {
      return 'https://durvasaayurved.com$cleanPhoto';
    }
    return 'https://durvasaayurved.com/$cleanPhoto';
  }

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely extract and trim string values
    String extract(List<String> keys, [String defaultValue = '']) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          final val = json[key].toString().trim();
          if (val.isNotEmpty && val.toLowerCase() != 'null') {
            return val;
          }
        }
      }
      return defaultValue;
    }

    final id = extract(['VisiterId', 'VisiterID', 'visiterId', 'visiterID', 'DealerID', 'dealerId', 'dealerID', 'LoginData', 'id']);
    final loginDataVal = extract(['LoginData', 'loginData', 'login_data']);
    final visiterIdVal = extract(['VisiterId', 'VisiterID', 'visiterId', 'visiterID']);
    final nameVal = extract(['name', 'DealerName', 'dealerName', 'userName']);
    final emailVal = extract(['email', 'dealerEmail', 'mail']);
    final phoneVal = extract(['phone', 'mobile', 'Phone', 'Mobile', 'contactNo']);
    final businessNameVal = extract(['businessName', 'BusinessName', 'firmName', 'shopName']);
    final addressVal = extract(['address', 'businessAddress', 'Address', 'BusinessAddress', 'dealerAddress']);
    final purposeVal = extract(['purpose', 'Purpose', 'role'], 'Dealer');
    final photoVal = extract(['photo', 'Photo', 'image', 'profile_photo', 'photoUrl']);
    final stateVal = extract(['state', 'State', 'stateName']);
    final districtVal = extract(['district', 'District', 'city', 'cityName']);
    final gstVal = extract(['gstNumber', 'gst', 'GstNumber', 'GST', 'gst_number']);

    return DealerModel(
      dealerId: id.isNotEmpty ? id : visiterIdVal,
      loginData: loginDataVal,
      visiterId: visiterIdVal.isNotEmpty ? visiterIdVal : id,
      name: nameVal,
      email: emailVal,
      phone: phoneVal,
      businessName: businessNameVal,
      businessAddress: addressVal,
      purpose: purposeVal,
      photo: photoVal,
      state: stateVal,
      district: districtVal,
      gstNumber: gstVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DealerID': dealerId,
      'dealerId': dealerId,
      'LoginData': loginData,
      'VisiterId': visiterId,
      'name': name,
      'email': email,
      'phone': phone,
      'mobile': phone,
      'businessName': businessName,
      'address': businessAddress,
      'businessAddress': businessAddress,
      'purpose': purpose,
      'photo': photo,
      'state': state,
      'district': district,
      'gstNumber': gstNumber,
    };
  }

  DealerModel copyWith({
    String? dealerId,
    String? loginData,
    String? visiterId,
    String? name,
    String? email,
    String? phone,
    String? businessName,
    String? businessAddress,
    String? purpose,
    String? photo,
    String? state,
    String? district,
    String? gstNumber,
  }) {
    return DealerModel(
      dealerId: dealerId ?? this.dealerId,
      loginData: loginData ?? this.loginData,
      visiterId: visiterId ?? this.visiterId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      purpose: purpose ?? this.purpose,
      photo: photo ?? this.photo,
      state: state ?? this.state,
      district: district ?? this.district,
      gstNumber: gstNumber ?? this.gstNumber,
    );
  }
}