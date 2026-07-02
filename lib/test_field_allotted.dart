import 'package:flutter/material.dart';
import '/HomeDrawerpage/FieldAllotted.dart';
import '';

class TestFieldAllottedPage extends StatefulWidget {
  const TestFieldAllottedPage({super.key});

  @override
  State<TestFieldAllottedPage> createState() => _TestFieldAllottedPageState();
}

class _TestFieldAllottedPageState extends State<TestFieldAllottedPage> {
  final TextEditingController _employeeIdController = TextEditingController();
  String _employeeId = 'EMP785291'; // Default employee ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Field Allotted"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _employeeId = _employeeIdController.text.isNotEmpty
                      ? _employeeIdController.text
                      : 'EMP785291';
                });
              },
              child: const Text('Update Employee ID'),
            ),
            const SizedBox(height: 16),
            Expanded(child: FieldAllotted(employeeId: _employeeId)),
          ],
        ),
      ),
    );
  }
}
