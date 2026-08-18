import 'dart:convert';

class StateResponse {
  final StateHeader? header;
  final List<StateModel> data;

  StateResponse({
    this.header,
    required this.data,
  });

  factory StateResponse.fromMap(Map<String, dynamic> map) {
    return StateResponse(
      header: map['Header'] != null && map['Header'] is Map<String, dynamic>
          ? StateHeader.fromMap(Map<String, dynamic>.from(map['Header']))
          : null,
      data: map['data'] != null && map['data'] is List
          ? (map['data'] as List)
              .whereType<Map>()
              .map((item) => StateModel.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : [],
    );
  }

  factory StateResponse.fromJson(String source) =>
      StateResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'Header': header?.toMap(),
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class StateHeader {
  final bool success;
  final int totalCount;
  final String? message;

  StateHeader({
    this.success = false,
    this.totalCount = 0,
    this.message,
  });

  factory StateHeader.fromMap(Map<String, dynamic> map) {
    return StateHeader(
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

class StateModel {
  final int stateId;
  final String stateName;
  final int? countryId;

  StateModel({
    required this.stateId,
    required this.stateName,
    this.countryId,
  });

  factory StateModel.fromMap(Map<String, dynamic> map) {
    return StateModel(
      stateId: int.tryParse(map['StateId']?.toString() ?? '') ??
          int.tryParse(map['stateId']?.toString() ?? '') ??
          int.tryParse(map['StateID']?.toString() ?? '') ??
          int.tryParse(map['Id']?.toString() ?? '') ??
          int.tryParse(map['id']?.toString() ?? '') ??
          0,
      stateName: map['StateName']?.toString() ??
          map['stateName']?.toString() ??
          map['State']?.toString() ??
          map['state']?.toString() ??
          map['Name']?.toString() ??
          map['name']?.toString() ??
          '',
      countryId: int.tryParse(map['CountryId']?.toString() ?? '') ??
          int.tryParse(map['countryId']?.toString() ?? ''),
    );
  }

  factory StateModel.fromJson(String source) =>
      StateModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'StateId': stateId,
      'StateName': stateName,
      if (countryId != null) 'CountryId': countryId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StateModel(stateId: $stateId, stateName: $stateName, countryId: $countryId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateModel &&
        other.stateId == stateId &&
        other.stateName == stateName &&
        other.countryId == countryId;
  }

  @override
  int get hashCode =>
      stateId.hashCode ^ stateName.hashCode ^ countryId.hashCode;
}
