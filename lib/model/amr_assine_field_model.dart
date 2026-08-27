class AmrAssineFieldResponse {
  final List<AmrAssineField> datas2;
  final String message;

  AmrAssineFieldResponse({
    required this.datas2,
    required this.message,
  });

  factory AmrAssineFieldResponse.fromJson(Map<String, dynamic> json) {
    return AmrAssineFieldResponse(
      datas2: (json['datas2'] as List<dynamic>?)
          ?.map(
            (item) => AmrAssineField.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }
}

class AmrAssineField {
  final int id;
  final String empId;
  final String empName;
  final int stateId;
  final String stateName;
  final int districtId;
  final String districtName;
  final String createDate;
  final String status;

  AmrAssineField({
    required this.id,
    required this.empId,
    required this.empName,
    required this.stateId,
    required this.stateName,
    required this.districtId,
    required this.districtName,
    required this.createDate,
    required this.status,
  });

  factory AmrAssineField.fromJson(Map<String, dynamic> json) {
    return AmrAssineField(
      id: json['Id'] ?? 0,
      empId: json['EmpId'] ?? '',
      empName: json['EmpName'] ?? '',
      stateId: json['StateId'] ?? 0,
      stateName: json['StateName'] ?? '',
      districtId: json['DistrictId'] ?? 0,
      districtName: json['DistrictName'] ?? '',
      createDate: json['CreateDate'] ?? '',
      status: json['Status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EmpId': empId,
      'EmpName': empName,
      'StateId': stateId,
      'StateName': stateName,
      'DistrictId': districtId,
      'DistrictName': districtName,
      'CreateDate': createDate,
      'Status': status,
    };
  }
}