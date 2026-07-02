// test_work_area.dart - Simple test file to verify work area functionality
import 'package:flutter/material.dart';
import 'model/TodoModel1.dart';
import 'VisitPage/NewVisitPage.dart';

class TestWorkAreaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create a sample employee data for testing
    final sampleEmployee = Data1(
      employeeId: 'EMP785291',
      name: 'Test Employee',
      mobile: '1234567890',
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Test Work Area')),
        body: NewVisitForm(employeeData: sampleEmployee),
      ),
    );
  }
}
