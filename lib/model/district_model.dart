import 'dart:convert';

class DistrictResponse {
  final DistrictHeader? header;
  final List<DistrictModel> data;

  DistrictResponse({
    this.header,
    required this.data,
  });

  factory DistrictResponse.fromMap(Map<String, dynamic> map) {
    return DistrictResponse(
      header: map['Header'] != null && map['Header'] is Map<String, dynamic>
          ? DistrictHeader.fromMap(Map<String, dynamic>.from(map['Header']))
          : null,
      data: map['data'] != null && map['data'] is List
          ? (map['data'] as List)
              .whereType<Map>()
              .map((item) => DistrictModel.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : [],
    );
  }

  factory DistrictResponse.fromJson(String source) =>
      DistrictResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'Header': header?.toMap(),
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class DistrictHeader {
  final bool success;
  final int totalCount;
  final String? message;

  DistrictHeader({
    this.success = false,
    this.totalCount = 0,
    this.message,
  });

  factory DistrictHeader.fromMap(Map<String, dynamic> map) {
    return DistrictHeader(
      success: map['success'] == true || map['Success'] == true,
      totalCount: int.tryParse(map['totalCount']?.toString() ?? '') ??
          int.tryParse(map['TotalCount']?.toString() ?? '') ??
          0,
      message: map['message']?.toString() ?? map['Message']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'totalCount': totalCount,
      if (message != null) 'message': message,
    };
  }

  String toJson() => json.encode(toMap());
}

class DistrictModel {
  final int districtId;
  final String districtName;
  final int? stateId;
  final int? countryId;

  DistrictModel({
    required this.districtId,
    required this.districtName,
    this.stateId,
    this.countryId,
  });

  factory DistrictModel.fromMap(Map<String, dynamic> map) {
    return DistrictModel(
      districtId: int.tryParse(map['DistrictId']?.toString() ?? '') ??
          int.tryParse(map['districtId']?.toString() ?? '') ??
          int.tryParse(map['DistrictID']?.toString() ?? '') ??
          int.tryParse(map['Id']?.toString() ?? '') ??
          int.tryParse(map['id']?.toString() ?? '') ??
          0,
      districtName: map['DistrictName']?.toString() ??
          map['districtName']?.toString() ??
          map['District']?.toString() ??
          map['district']?.toString() ??
          map['Name']?.toString() ??
          map['name']?.toString() ??
          '',
      stateId: int.tryParse(map['StateId']?.toString() ?? '') ??
          int.tryParse(map['stateId']?.toString() ?? ''),
      countryId: int.tryParse(map['CountryId']?.toString() ?? '') ??
          int.tryParse(map['countryId']?.toString() ?? ''),
    );
  }

  factory DistrictModel.fromJson(String source) =>
      DistrictModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'DistrictId': districtId,
      'DistrictName': districtName,
      if (stateId != null) 'StateId': stateId,
      if (countryId != null) 'CountryId': countryId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'DistrictModel(districtId: $districtId, districtName: $districtName, stateId: $stateId, countryId: $countryId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DistrictModel &&
        other.districtId == districtId &&
        other.districtName == districtName &&
        other.stateId == stateId &&
        other.countryId == countryId;
  }

  @override
  int get hashCode =>
      districtId.hashCode ^
      districtName.hashCode ^
      (stateId?.hashCode ?? 0) ^
      (countryId?.hashCode ?? 0);
}
