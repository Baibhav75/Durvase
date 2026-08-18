import 'dart:convert';

class CountryResponse {
  final CountryHeader? header;
  final List<CountryModel> data;

  CountryResponse({
    this.header,
    required this.data,
  });

  factory CountryResponse.fromMap(Map<String, dynamic> map) {
    return CountryResponse(
      header: map['Header'] != null && map['Header'] is Map<String, dynamic>
          ? CountryHeader.fromMap(Map<String, dynamic>.from(map['Header']))
          : null,
      data: map['data'] != null && map['data'] is List
          ? (map['data'] as List)
              .whereType<Map>()
              .map((item) => CountryModel.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : [],
    );
  }

  factory CountryResponse.fromJson(String source) =>
      CountryResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'Header': header?.toMap(),
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class CountryHeader {
  final bool success;
  final int totalCount;
  final String? message;

  CountryHeader({
    this.success = false,
    this.totalCount = 0,
    this.message,
  });

  factory CountryHeader.fromMap(Map<String, dynamic> map) {
    return CountryHeader(
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

class CountryModel {
  final int countryId;
  final String countryName;

  CountryModel({
    required this.countryId,
    required this.countryName,
  });

  factory CountryModel.fromMap(Map<String, dynamic> map) {
    return CountryModel(
      countryId: int.tryParse(map['CountryId']?.toString() ?? '') ??
          int.tryParse(map['countryId']?.toString() ?? '') ??
          int.tryParse(map['id']?.toString() ?? '') ??
          0,
      countryName: map['CountryName']?.toString() ??
          map['countryName']?.toString() ??
          map['name']?.toString() ??
          '',
    );
  }

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'CountryId': countryId,
      'CountryName': countryName,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'CountryModel(countryId: $countryId, countryName: $countryName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryModel &&
        other.countryId == countryId &&
        other.countryName == countryName;
  }

  @override
  int get hashCode => countryId.hashCode ^ countryName.hashCode;
}