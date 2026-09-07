// model/mr_work_report_history_model.dart

class MRWorkReportHistoryModel {
  final MRWorkReportHistoryHeader? header;
  final List<MRWorkReportHistoryItem>? data;

  MRWorkReportHistoryModel({this.header, this.data});

  factory MRWorkReportHistoryModel.fromJson(Map<String, dynamic> json) {
    return MRWorkReportHistoryModel(
      header: json['Header'] != null
          ? MRWorkReportHistoryHeader.fromJson(json['Header'] as Map<String, dynamic>)
          : null,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => MRWorkReportHistoryItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Header': header?.toJson(),
      'data': data?.map((i) => i.toJson()).toList(),
    };
  }
}

class MRWorkReportHistoryHeader {
  final bool? success;
  final int? totalCount;
  final String? empId;

  MRWorkReportHistoryHeader({
    this.success,
    this.totalCount,
    this.empId,
  });

  factory MRWorkReportHistoryHeader.fromJson(Map<String, dynamic> json) {
    return MRWorkReportHistoryHeader(
      success: json['success'] is bool
          ? json['success']
          : (json['success']?.toString().toLowerCase() == 'true'),
      totalCount: json['totalCount'] is int
          ? json['totalCount']
          : int.tryParse('${json['totalCount']}'),
      empId: json['EmpId']?.toString() ?? json['empId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalCount': totalCount,
      'EmpId': empId,
    };
  }
}

class MRWorkReportHistoryItem {
  final int? id;
  final String? empId;
  final String? employeeCode;
  final String? reportDate;
  final String? state;
  final String? zone;
  final String? block;
  final String? totalDoctorVisits;
  final String? totalChemistVisits;
  final String? totalStockistVisits;
  final String? primaryOrderValue;
  final String? secondaryOrderValue;
  final String? workingArea;
  final String? latitude;
  final String? longitude;
  final String? dailyExpense;
  final String? expenseRemarks;
  final String? workDetails;
  final String? reportStatus;
  final String? createdAt;
  final String? updatedAt;

  MRWorkReportHistoryItem({
    this.id,
    this.empId,
    this.employeeCode,
    this.reportDate,
    this.state,
    this.zone,
    this.block,
    this.totalDoctorVisits,
    this.totalChemistVisits,
    this.totalStockistVisits,
    this.primaryOrderValue,
    this.secondaryOrderValue,
    this.workingArea,
    this.latitude,
    this.longitude,
    this.dailyExpense,
    this.expenseRemarks,
    this.workDetails,
    this.reportStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory MRWorkReportHistoryItem.fromJson(Map<String, dynamic> json) {
    return MRWorkReportHistoryItem(
      id: json['Id'] is int ? json['Id'] : int.tryParse('${json['Id']}'),
      empId: json['EmpId']?.toString() ?? json['empId']?.toString(),
      employeeCode: json['EmployeeCode']?.toString() ?? json['employeeCode']?.toString(),
      reportDate: json['ReportDate']?.toString() ?? json['reportDate']?.toString(),
      state: json['State']?.toString() ?? json['state']?.toString(),
      zone: json['Zone']?.toString() ?? json['zone']?.toString(),
      block: json['Block']?.toString() ?? json['block']?.toString(),
      totalDoctorVisits: json['TotalDoctorVisits']?.toString() ?? json['totalDoctorVisits']?.toString(),
      totalChemistVisits: json['TotalChemistVisits']?.toString() ?? json['totalChemistVisits']?.toString(),
      totalStockistVisits: json['TotalStockistVisits']?.toString() ?? json['totalStockistVisits']?.toString(),
      primaryOrderValue: json['PrimaryOrderValue']?.toString() ?? json['primaryOrderValue']?.toString(),
      secondaryOrderValue: json['SecondaryOrderValue']?.toString() ?? json['secondaryOrderValue']?.toString(),
      workingArea: json['WorkingArea']?.toString() ?? json['workingArea']?.toString(),
      latitude: json['Latitude']?.toString() ?? json['latitude']?.toString(),
      longitude: json['Longitude']?.toString() ?? json['longitude']?.toString(),
      dailyExpense: json['DailyExpense']?.toString() ?? json['dailyExpense']?.toString(),
      expenseRemarks: json['ExpenseRemarks']?.toString() ?? json['expenseRemarks']?.toString(),
      workDetails: json['WorkDetails']?.toString() ?? json['workDetails']?.toString(),
      reportStatus: json['ReportStatus']?.toString() ?? json['reportStatus']?.toString(),
      createdAt: json['CreatedAt']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['UpdatedAt']?.toString() ?? json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EmpId': empId,
      'EmployeeCode': employeeCode,
      'ReportDate': reportDate,
      'State': state,
      'Zone': zone,
      'Block': block,
      'TotalDoctorVisits': totalDoctorVisits,
      'TotalChemistVisits': totalChemistVisits,
      'TotalStockistVisits': totalStockistVisits,
      'PrimaryOrderValue': primaryOrderValue,
      'SecondaryOrderValue': secondaryOrderValue,
      'WorkingArea': workingArea,
      'Latitude': latitude,
      'Longitude': longitude,
      'DailyExpense': dailyExpense,
      'ExpenseRemarks': expenseRemarks,
      'WorkDetails': workDetails,
      'ReportStatus': reportStatus,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }

  // Calculated helpers
  int get totalVisits {
    final doc = int.tryParse(totalDoctorVisits ?? '0') ?? 0;
    final chem = int.tryParse(totalChemistVisits ?? '0') ?? 0;
    final stock = int.tryParse(totalStockistVisits ?? '0') ?? 0;
    return doc + chem + stock;
  }

  double get totalOrder {
    final prim = double.tryParse(primaryOrderValue ?? '0') ?? 0.0;
    final sec = double.tryParse(secondaryOrderValue ?? '0') ?? 0.0;
    return prim + sec;
  }

  double get expenseValue {
    return double.tryParse(dailyExpense ?? '0') ?? 0.0;
  }
}
