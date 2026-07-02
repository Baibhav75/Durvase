class TodoModel {
  String? message;
  String? status;
  String? loginData;
  String? name;
  String? email;
  String? mobile;
  String? employeeType;
  String? empId;

  TodoModel({
    this.message,
    this.status,
    this.loginData,
    this.name,
    this.email,
    this.mobile,
    this.employeeType,
    this.empId,
  });

  TodoModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String?;
    status = json['status'] as String?;
    loginData = json['LoginData'] as String?;
    name = json['name'] as String?;
    email = json['email'] as String?;
    mobile = json['mobile'] as String?;
    employeeType = json['EmployeeType'] as String?;
    empId = json['EmpId'] as String?;
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
    return data;
  }
}
