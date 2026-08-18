import 'package:intl/intl.dart';

class AsmProfileModel {
  static const String imageBaseUrl = 'https://durvasaayurved.online';

  final int? asmId;
  final String? name;
  final String? mobile;
  final String? mobileAlt;
  final String? email;
  final String? district;
  final String? block;
  final String? fatherName;
  final String? address;
  final String? joinDate;
  final String? image;
  final String? empId;
  final String? status;
  final String? createdAt;
  final String? gender;
  final String? postOffice;
  final String? country;
  final String? state;
  final String? employeeCode;
  final String? employeeType;
  final String? region;
  final String? area;
  final String? emergenceNo;
  final String? billedGroup;

  AsmProfileModel({
    this.asmId,
    this.name,
    this.mobile,
    this.mobileAlt,
    this.email,
    this.district,
    this.block,
    this.fatherName,
    this.address,
    this.joinDate,
    this.image,
    this.empId,
    this.status,
    this.createdAt,
    this.gender,
    this.postOffice,
    this.country,
    this.state,
    this.employeeCode,
    this.employeeType,
    this.region,
    this.area,
    this.emergenceNo,
    this.billedGroup,
  });

  // ============================================================
  // BACKWARD COMPATIBILITY & HELPER GETTERS
  // ============================================================
  String? get uniqueId => empId ?? employeeCode;
  String? get fathersName => fatherName;
  String? get profileImage => image;
  String? get joiningDate => joinDate;
  String? get createdDate => createdAt;
  String? get emergencyNo => emergenceNo;
  String? get emergencyContact => emergenceNo;
  String? get bloodGroup => billedGroup;

  bool get isActive {
    if (status == null) return true;
    final lower = status!.trim().toLowerCase();
    return lower == 'active' || lower == 'true' || lower == '1';
  }

  // ============================================================
  // HELPER GETTERS & UTILITIES
  // ============================================================
  String get resolvedImageUrl {
    if (image == null || image!.trim().isEmpty) return '';
    final path = image!.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (path.startsWith('/')) {
      return '$imageBaseUrl$path';
    }
    return '$imageBaseUrl/$path';
  }

  String get displayDesignation {
    if (employeeType != null && employeeType!.trim().isNotEmpty) {
      final type = employeeType!.trim().toUpperCase();
      if (type == 'ASM') return 'Area Sales Manager (ASM)';
      return type;
    }
    return 'Area Sales Manager (ASM)';
  }

  String get displayLocation {
    final parts = <String>[];
    if (district != null && district!.trim().isNotEmpty) parts.add(district!.trim());
    if (state != null && state!.trim().isNotEmpty) parts.add(state!.trim());
    if (parts.isEmpty) {
      if (area != null && area!.trim().isNotEmpty) parts.add(area!.trim());
      if (region != null && region!.trim().isNotEmpty) parts.add(region!.trim());
    }
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }

  String get formattedJoinDate {
    if (joinDate == null || joinDate!.trim().isEmpty) return 'Not available';
    try {
      final parsed = DateTime.parse(joinDate!.trim());
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return joinDate!.trim();
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.trim().isEmpty) return 'Not available';
    try {
      final parsed = DateTime.parse(createdAt!.trim());
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return createdAt!.trim();
    }
  }

  // ============================================================
  // JSON FACTORY WITH RESILIENT MULTI-KEY SUPPORT
  // ============================================================
  factory AsmProfileModel.fromMap(Map<String, dynamic> map) {
    // Helper to safely extract string
    String? getString(List<String> keys) {
      for (final key in keys) {
        if (map.containsKey(key) && map[key] != null) {
          final val = map[key].toString().trim();
          if (val.isNotEmpty && val.toLowerCase() != 'null') return val;
        }
      }
      return null;
    }

    // Helper to safely extract int
    int? getInt(List<String> keys) {
      for (final key in keys) {
        if (map.containsKey(key) && map[key] != null) {
          if (map[key] is int) return map[key] as int;
          final parsed = int.tryParse('${map[key]}'.replaceAll(RegExp(r'[^0-9]'), ''));
          if (parsed != null) return parsed;
        }
      }
      return null;
    }

    return AsmProfileModel(
      asmId: getInt(['ASMId', 'AsmId', 'asmId', 'asm_id', 'id']),
      name: getString(['Name', 'name', 'FullName', 'fullName']),
      mobile: getString(['Mobile', 'mobile', 'Phone', 'phone', 'MobileNo']),
      mobileAlt: getString(['MobileAlt', 'mobileAlt', 'mobile_alt', 'AlternateMobile', 'AltMobile']),
      email: getString(['Email', 'email', 'EmailAddress', 'email_address']),
      district: getString(['District', 'district', 'City', 'city']),
      block: getString(['Block', 'block']),
      fatherName: getString(['FatherName', 'fatherName', 'FathersName', 'fathersName', 'father_name']),
      address: getString(['Address', 'address', 'FullAddress', 'fullAddress']),
      joinDate: getString(['JoinDate', 'joinDate', 'JoiningDate', 'joiningDate', 'join_date']),
      image: getString(['Image', 'image', 'ProfileImage', 'profileImage', 'profile_image', 'Photo', 'photo']),
      empId: getString(['EmpId', 'empId', 'UniqueId', 'uniqueId', 'EmployeeId', 'employee_id']),
      status: getString(['Status', 'status', 'AccountStatus', 'account_status']) ??
          (map['IsActive'] != null ? (map['IsActive'] == true || '${map['IsActive']}'.toLowerCase() == 'true' ? 'Active' : 'Inactive') : null),
      createdAt: getString(['CreatedAt', 'createdAt', 'CreatedDate', 'createdDate', 'created_at']),
      gender: getString(['Gender', 'gender', 'Sex', 'sex']),
      postOffice: getString(['PostOffice', 'postOffice', 'post_office', 'PostOfficeName']),
      country: getString(['Country', 'country']),
      state: getString(['State', 'state']),
      employeeCode: getString(['EmployeeCode', 'employeeCode', 'employee_code']),
      employeeType: getString(['EmployeeType', 'employeeType', 'employee_type', 'Role', 'role']),
      region: getString(['Region', 'region']),
      area: getString(['Area', 'area']),
      emergenceNo: getString(['EmergenceNo', 'emergenceNo', 'emergence_no', 'EmergencyNo', 'emergencyNo', 'emergency_no', 'EmergencyContact']),
      billedGroup: getString(['BilledGroup', 'billedGroup', 'billed_group', 'BloodGroup', 'bloodGroup', 'blood_group']),
    );
  }

  // ============================================================
  // SERIALIZATION
  // ============================================================
  Map<String, dynamic> toMap() {
    return {
      'ASMId': asmId,
      'Name': name,
      'Mobile': mobile,
      'MobileAlt': mobileAlt,
      'Email': email,
      'District': district,
      'Block': block,
      'FatherName': fatherName,
      'Address': address,
      'JoinDate': joinDate,
      'Image': image,
      'EmpId': empId,
      'Status': status,
      'CreatedAt': createdAt,
      'Gender': gender,
      'PostOffice': postOffice,
      'Country': country,
      'State': state,
      'EmployeeCode': employeeCode,
      'EmployeeType': employeeType,
      'Region': region,
      'Area': area,
      'EmergenceNo': emergenceNo,
      'BilledGroup': billedGroup,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================
  AsmProfileModel copyWith({
    int? asmId,
    String? name,
    String? mobile,
    String? mobileAlt,
    String? email,
    String? district,
    String? block,
    String? fatherName,
    String? address,
    String? joinDate,
    String? image,
    String? empId,
    String? status,
    String? createdAt,
    String? gender,
    String? postOffice,
    String? country,
    String? state,
    String? employeeCode,
    String? employeeType,
    String? region,
    String? area,
    String? emergenceNo,
    String? billedGroup,
  }) {
    return AsmProfileModel(
      asmId: asmId ?? this.asmId,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      mobileAlt: mobileAlt ?? this.mobileAlt,
      email: email ?? this.email,
      district: district ?? this.district,
      block: block ?? this.block,
      fatherName: fatherName ?? this.fatherName,
      address: address ?? this.address,
      joinDate: joinDate ?? this.joinDate,
      image: image ?? this.image,
      empId: empId ?? this.empId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender,
      postOffice: postOffice ?? this.postOffice,
      country: country ?? this.country,
      state: state ?? this.state,
      employeeCode: employeeCode ?? this.employeeCode,
      employeeType: employeeType ?? this.employeeType,
      region: region ?? this.region,
      area: area ?? this.area,
      emergenceNo: emergenceNo ?? this.emergenceNo,
      billedGroup: billedGroup ?? this.billedGroup,
    );
  }
}

