// lib/models/mr_model.dart
class MrModel {
  List<Datas1>? datas1;
  String? message;

  MrModel({this.datas1, this.message});

  MrModel.fromJson(Map<String, dynamic> json) {
    if (json['datas1'] != null) {
      datas1 = <Datas1>[];
      json['datas1'].forEach((v) {
        datas1!.add(Datas1.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (datas1 != null) {
      data['datas1'] = datas1!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Datas1 {
  int? id;
  dynamic empId;
  String? empName;
  int? stateId;
  String? state;
  int? districtId;
  String? district;
  int? blockId;
  String? blockName;
  String? status;
  String? createDate;
  dynamic updateDate;
  String? employeeId;

  Datas1({
    this.id,
    this.empId,
    this.empName,
    this.stateId,
    this.state,
    this.districtId,
    this.district,
    this.blockId,
    this.blockName,
    this.status,
    this.createDate,
    this.updateDate,
    this.employeeId,
  });

  Datas1.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    empId = json['EmpId'];
    empName = json['EmpName'];
    stateId = json['StateId'];
    state = json['State'];
    districtId = json['DistrictId'];
    district = json['District'];
    blockId = json['BlockId'];
    blockName = json['BlockName'];
    status = json['Status'];
    createDate = json['CreateDate'];
    updateDate = json['Update_Date'];
    employeeId = json['EmployeeId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['EmpId'] = empId;
    data['EmpName'] = empName;
    data['StateId'] = stateId;
    data['State'] = state;
    data['DistrictId'] = districtId;
    data['District'] = district;
    data['BlockId'] = blockId;
    data['BlockName'] = blockName;
    data['Status'] = status;
    data['CreateDate'] = createDate;
    data['Update_Date'] = updateDate;
    data['EmployeeId'] = employeeId;
    return data;
  }
}
