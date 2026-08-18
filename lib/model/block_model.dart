import 'dart:convert';

class BlockResponse {
  final BlockHeader? header;
  final List<BlockModel> data;

  BlockResponse({
    this.header,
    required this.data,
  });

  factory BlockResponse.fromMap(Map<String, dynamic> map) {
    return BlockResponse(
      header: map['Header'] != null && map['Header'] is Map<String, dynamic>
          ? BlockHeader.fromMap(Map<String, dynamic>.from(map['Header']))
          : null,
      data: map['data'] != null && map['data'] is List
          ? (map['data'] as List)
              .whereType<Map>()
              .map((item) => BlockModel.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : [],
    );
  }

  factory BlockResponse.fromJson(String source) =>
      BlockResponse.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'Header': header?.toMap(),
      'data': data.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}

class BlockHeader {
  final bool success;
  final int totalCount;
  final String? message;

  BlockHeader({
    this.success = false,
    this.totalCount = 0,
    this.message,
  });

  factory BlockHeader.fromMap(Map<String, dynamic> map) {
    return BlockHeader(
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

class BlockModel {
  final int blockId;
  final String blockName;
  final int? districtId;
  final int? stateId;

  BlockModel({
    required this.blockId,
    required this.blockName,
    this.districtId,
    this.stateId,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map) {
    return BlockModel(
      blockId: int.tryParse(map['BlockId']?.toString() ?? '') ??
          int.tryParse(map['blockId']?.toString() ?? '') ??
          int.tryParse(map['BlockID']?.toString() ?? '') ??
          int.tryParse(map['Id']?.toString() ?? '') ??
          int.tryParse(map['id']?.toString() ?? '') ??
          0,
      blockName: map['BlockName']?.toString() ??
          map['blockName']?.toString() ??
          map['Block']?.toString() ??
          map['block']?.toString() ??
          map['Name']?.toString() ??
          map['name']?.toString() ??
          '',
      districtId: int.tryParse(map['DistrictId']?.toString() ?? '') ??
          int.tryParse(map['districtId']?.toString() ?? ''),
      stateId: int.tryParse(map['StateId']?.toString() ?? '') ??
          int.tryParse(map['stateId']?.toString() ?? ''),
    );
  }

  factory BlockModel.fromJson(String source) =>
      BlockModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'BlockId': blockId,
      'BlockName': blockName,
      if (districtId != null) 'DistrictId': districtId,
      if (stateId != null) 'StateId': stateId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'BlockModel(blockId: $blockId, blockName: $blockName, districtId: $districtId, stateId: $stateId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlockModel &&
        other.blockId == blockId &&
        other.blockName == blockName &&
        other.districtId == districtId &&
        other.stateId == stateId;
  }

  @override
  int get hashCode =>
      blockId.hashCode ^
      blockName.hashCode ^
      (districtId?.hashCode ?? 0) ^
      (stateId?.hashCode ?? 0);
}
