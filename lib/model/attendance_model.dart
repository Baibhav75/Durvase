class attendanceModel {
  String? employeeId;
  String? employeeName;
  String? checkInTime;
  String? checkOutTime;
  String? workDuration;
  String? latitude;
  String? longitude;
  String? locationName;
  String? status;
  String? imageBase64;

  attendanceModel({
    this.employeeId,
    this.employeeName,
    this.checkInTime,
    this.checkOutTime,
    this.workDuration,
    this.latitude,
    this.longitude,
    this.locationName,
    this.status,
    this.imageBase64,
  });

  attendanceModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    employeeName = json['employee_name'];
    checkInTime = json['check_in_time'];
    checkOutTime = json['check_out_time'];
    workDuration = json['work_duration'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    locationName = json['location_name'];
    status = json['status'];
    imageBase64 = json['image_base64'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_id'] = this.employeeId;
    data['employee_name'] = this.employeeName;
    data['check_in_time'] = this.checkInTime;
    data['check_out_time'] = this.checkOutTime;
    data['work_duration'] = this.workDuration;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['location_name'] = this.locationName;
    data['status'] = this.status;
    data['image_base64'] = this.imageBase64;
    return data;
  }
}
