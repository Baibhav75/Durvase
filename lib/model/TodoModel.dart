class TodoModel {
  String? message;
  String? status;
  String? loginData;
  String? name;
  String? email;
  String? mobile;
  String? employeeType;
  String? empId;
  String? asmId;
  String? region;

  TodoModel({
    this.message,
    this.status,
    this.loginData,
    this.name,
    this.email,
    this.mobile,
    this.employeeType,
    this.empId,
    this.asmId,
    this.region,
  });

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  TodoModel.fromJson(Map<String, dynamic> json) {
    message = _parseString(json['message'] ?? json['Message']);
    status = _parseString(json['status'] ?? json['Status']);
    loginData = _parseString(json['LoginData'] ?? json['loginData'] ?? json['login_data']);
    name = _parseString(json['name'] ?? json['Name'] ?? json['emp_name'] ?? json['employee_name']);
    email = _parseString(json['email'] ?? json['Email']);
    mobile = _parseString(json['mobile'] ?? json['Mobile'] ?? json['phone'] ?? json['Phone']);
    asmId = _parseString(json['AsmId'] ?? json['asmId'] ?? json['asm_id']);
    region = _parseString(json['region'] ?? json['Region']);
    employeeType = _parseString(
      json['EmployeeType'] ??
      json['employeeType'] ??
      json['employee_type'] ??
      (asmId != null ? 'ASM' : null),
    );
    empId = _parseString(
      json['EmpId'] ??
      json['empId'] ??
      json['emp_id'] ??
      json['AsmId'] ??
      json['asmId'] ??
      json['asm_id'] ??
      json['EmployeeId'] ??
      json['employeeId'] ??
      json['employee_id'] ??
      json['userId'] ??
      json['user_id'] ??
      json['UserId'] ??
      json['id'] ??
      json['Id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['LoginData'] = loginData;
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['EmployeeType'] = employeeType;
    data['EmpId'] = empId;
    data['AsmId'] = asmId;
    data['region'] = region;
    return data;
  }
}

