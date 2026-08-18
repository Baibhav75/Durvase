class AttendanceHistoryModel {
  final int id;
  final String employeeName;
  final DateTime? createDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? checkInImage;
  final String? checkOutImage;
  final String? status;
  final String? hoursWorked;
  final String empId;
  final String? empType;
  final String? state;
  final String? district;
  final String? action;

  AttendanceHistoryModel({
    required this.id,
    required this.employeeName,
    this.createDate,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInImage,
    this.checkOutImage,
    this.status,
    this.hoursWorked,
    required this.empId,
    this.empType,
    this.state,
    this.district,
    this.action,
  });

  factory AttendanceHistoryModel.fromMap(Map<String, dynamic> map) {
    return AttendanceHistoryModel(
      id: map['Id'] ?? 0,
      employeeName: map['EmployeeName'] ?? '',
      createDate: _parseDate(map['CreateDate']),
      checkInTime: _parseDate(map['CheckInTime']),
      checkOutTime: _parseDate(map['CheckOutTime']),
      checkInLocation: map['CheckInLocation'],
      checkOutLocation: map['CheckOutLocation'],
      checkInImage: map['CheckInImage'],
      checkOutImage: map['CheckOutImage'],
      status: map['Status'],
      hoursWorked: map['HoursWorked']?.toString(),
      empId: map['EmpId'] ?? '',
      empType: map['EmpType'],
      state: map['State'],
      district: map['District'],
      action: map['Action'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'EmployeeName': employeeName,
      'CreateDate': createDate?.toIso8601String(),
      'CheckInTime': checkInTime?.toIso8601String(),
      'CheckOutTime': checkOutTime?.toIso8601String(),
      'CheckInLocation': checkInLocation,
      'CheckOutLocation': checkOutLocation,
      'CheckInImage': checkInImage,
      'CheckOutImage': checkOutImage,
      'Status': status,
      'HoursWorked': hoursWorked,
      'EmpId': empId,
      'EmpType': empType,
      'State': state,
      'District': district,
      'Action': action,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(value.toString());

      // Ignore .NET default date
      if (date.year == 1) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }
}