class DealerProfileModel {
  final int? id;
  final String? dealerId;
  final String? name;
  final String? email;
  final String? phone;
  final String? gstNumber;
  final String? businessAddress;
  final String? profile;
  final bool isActive;
  final String? createdAt;
  final String? empType;
  final String? empMobile;
  final String? visitFor;
  final String? country;
  final String? state;
  final String? district;
  final String? block;
  final String? businessName;
  final String? purpose;
  final String? reVisited;
  final String? remark;
  final String? empName;
  final String? revisitDate;
  final String? employeeId;

  DealerProfileModel({
    this.id,
    this.dealerId,
    this.name,
    this.email,
    this.phone,
    this.gstNumber,
    this.businessAddress,
    this.profile,
    this.isActive = false,
    this.createdAt,
    this.empType,
    this.empMobile,
    this.visitFor,
    this.country,
    this.state,
    this.district,
    this.block,
    this.businessName,
    this.purpose,
    this.reVisited,
    this.remark,
    this.empName,
    this.revisitDate,
    this.employeeId,
  });

  factory DealerProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely extract and trim string values
    String? extract(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key) && json[key] != null) {
          final val = json[key].toString().trim();
          if (val.isNotEmpty && val.toLowerCase() != 'null') {
            return val;
          }
        }
      }
      return null;
    }

    final rawId = json['id'] ?? json['ID'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    final rawActive = json['isActive'] ?? json['is_active'] ?? json['status'];
    final bool activeFlag = (rawActive?.toString().toLowerCase() == 'true' ||
        rawActive?.toString().toLowerCase() == '1' ||
        rawActive?.toString().toLowerCase() == 'active');

    return DealerProfileModel(
      id: parsedId,
      dealerId: extract(['dealerID', 'dealerId', 'DealerID', 'VisiterId', 'visiterId', 'id']),
      name: extract(['name', 'DealerName', 'dealerName']),
      email: extract(['email', 'dealerEmail']),
      phone: extract(['phone', 'mobile', 'Phone', 'Mobile']),
      gstNumber: extract(['gstNumber', 'gst', 'GST', 'gst_number']),
      businessAddress: extract(['businessAddress', 'address', 'BusinessAddress']),
      profile: extract(['profile', 'photo', 'Profile', 'Photo', 'image']),
      isActive: activeFlag,
      createdAt: extract(['createdAt', 'created_at', 'CreatedDate']),
      empType: extract(['empType', 'employeeType', 'emp_type']),
      empMobile: extract(['empMobile', 'employeeMobile', 'emp_mobile']),
      visitFor: extract(['visitFor', 'visit_for']),
      country: extract(['country', 'Country']),
      state: extract(['state', 'State']),
      district: extract(['district', 'District', 'city']),
      block: extract(['block', 'Block']),
      businessName: extract(['businessName', 'BusinessName', 'firmName', 'shopName']),
      purpose: extract(['purpose', 'Purpose']),
      reVisited: extract(['reVisited', 're_visited', 'revisited']),
      remark: extract(['remark', 'Remark', 'notes']),
      empName: extract(['empName', 'employeeName', 'emp_name']),
      revisitDate: extract(['revisitDate', 'revisit_date', 'reVisitDate']),
      employeeId: extract(['employeeId', 'empId', 'employee_id', 'employeeCode']),
    );
  }

  static const String _baseImageUrl = 'https://durvasaayurved.com';

  String get resolvedImageUrl {
    if (profile == null || profile!.trim().isEmpty) return '';
    final clean = profile!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) return clean;
    if (clean.startsWith('/')) return '$_baseImageUrl$clean';
    return '$_baseImageUrl/$clean';
  }

  String get formattedCreatedAt => _formatDate(createdAt);

  String get formattedRevisitDate => _formatDate(revisitDate);

  static String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty || raw.trim().toLowerCase() == 'null') {
      return 'Not available';
    }
    try {
      final date = DateTime.parse(raw.trim());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return raw.trim();
    }
  }

  String get locationSummary {
    final parts = [block, district, state, country]
        .where((s) => s != null && s.trim().isNotEmpty && s.trim().toLowerCase() != 'null')
        .map((s) => s!.trim())
        .toList();
    return parts.isEmpty ? 'Not available' : parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealerID': dealerId,
      'name': name,
      'email': email,
      'phone': phone,
      'gstNumber': gstNumber,
      'businessAddress': businessAddress,
      'profile': profile,
      'isActive': isActive,
      'createdAt': createdAt,
      'empType': empType,
      'empMobile': empMobile,
      'visitFor': visitFor,
      'country': country,
      'state': state,
      'district': district,
      'block': block,
      'businessName': businessName,
      'purpose': purpose,
      'reVisited': reVisited,
      'remark': remark,
      'empName': empName,
      'revisitDate': revisitDate,
      'employeeId': employeeId,
    };
  }
}