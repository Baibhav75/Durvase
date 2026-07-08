class AttendanceHistoryResponse {
  bool? status;
  String? message;
  List<AttendanceHistoryData>? data;

  AttendanceHistoryResponse({this.status, this.message, this.data});

  AttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    status = json['Status'];
    message = json['Message'];
    if (json['Data'] != null) {
      data = <AttendanceHistoryData>[];
      json['Data'].forEach((v) {
        data!.add(new AttendanceHistoryData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Status'] = this.status;
    data['Message'] = this.message;
    if (this.data != null) {
      data['Data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttendanceHistoryData {
  int? id;
  String? employeeName;
  String? checkInTime;
  String? checkOutTime;
  String? workHours;
  String? checkInLocation;
  String? checkOutLocation;
  String? checkInImage;
  String? checkOutImage;
  String? status;

  AttendanceHistoryData(
      {this.id,
      this.employeeName,
      this.checkInTime,
      this.checkOutTime,
      this.workHours,
      this.checkInLocation,
      this.checkOutLocation,
      this.checkInImage,
      this.checkOutImage,
      this.status});

  AttendanceHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    employeeName = json['EmployeeName'];
    checkInTime = json['CheckInTime'];
    checkOutTime = json['CheckOutTime'];
    workHours = json['WorkHours'];
    checkInLocation = json['CheckInLocation'];
    checkOutLocation = json['CheckOutLocation'];
    checkInImage = json['CheckInImage'];
    checkOutImage = json['CheckOutImage'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['EmployeeName'] = this.employeeName;
    data['CheckInTime'] = this.checkInTime;
    data['CheckOutTime'] = this.checkOutTime;
    data['WorkHours'] = this.workHours;
    data['CheckInLocation'] = this.checkInLocation;
    data['CheckOutLocation'] = this.checkOutLocation;
    data['CheckInImage'] = this.checkInImage;
    data['CheckOutImage'] = this.checkOutImage;
    data['Status'] = this.status;
    return data;
  }
}
