class ASMWorkReportModel {
  final String empId;
  final String employeeCode;
  final String reportDate;
  final String state;
  final String zone;

  final String totalDoctorVisits;
  final String totalChemistVisits;
  final String totalStockistVisits;

  final String primaryOrderValue;
  final String secondaryOrderValue;

  final String workingArea;

  final String latitude;
  final String longitude;

  final String dailyExpense;
  final String expenseRemarks;

  final String workDetails;

  ASMWorkReportModel({
    required this.empId,
    required this.employeeCode,
    required this.reportDate,
    required this.state,
    required this.zone,
    required this.totalDoctorVisits,
    required this.totalChemistVisits,
    required this.totalStockistVisits,
    required this.primaryOrderValue,
    required this.secondaryOrderValue,
    required this.workingArea,
    required this.latitude,
    required this.longitude,
    required this.dailyExpense,
    required this.expenseRemarks,
    required this.workDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      "empId": empId,
      "employeeCode": employeeCode,
      "reportDate": reportDate,
      "state": state,
      "zone": zone,
      "totalDoctorVisits": totalDoctorVisits,
      "totalChemistVisits": totalChemistVisits,
      "totalStockistVisits": totalStockistVisits,
      "primaryOrderValue": primaryOrderValue,
      "secondaryOrderValue": secondaryOrderValue,
      "workingArea": workingArea,
      "latitude": latitude,
      "longitude": longitude,
      "dailyExpense": dailyExpense,
      "expenseRemarks": expenseRemarks,
      "workDetails": workDetails,
    };
  }
}