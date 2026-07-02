import 'package:flutter/material.dart';
import 'model/work_area_model.dart';
import 'service/work_Area_Service.dart';

class WorkAreaDebugPage extends StatefulWidget {
  final String employeeId; // Make employeeId a parameter

  const WorkAreaDebugPage({
    super.key,
    this.employeeId = 'EMP785291',
  }); // Default value

  @override
  State<WorkAreaDebugPage> createState() => _WorkAreaDebugPageState();
}

class _WorkAreaDebugPageState extends State<WorkAreaDebugPage> {
  List<WorkAreaModel> workAreas = [];
  bool isLoading = true;
  String errorMessage = '';
  // Remove static employeeId and use widget.employeeId

  @override
  void initState() {
    super.initState();
    _fetchWorkAreas();
  }

  Future<void> _fetchWorkAreas() async {
    try {
      print('🔍 Debug: Fetching work areas for employee ${widget.employeeId}');
      final areas = await WorkAreaService.getWorkAreas(widget.employeeId);
      setState(() {
        workAreas = areas;
        isLoading = false;
      });
      print('✅ Successfully fetched ${areas.length} work areas');
      for (var area in areas) {
        print(
          '📍 Work Area - Block: ${area.block}, District: ${area.district}, State: ${area.state}',
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('❌ Error fetching work areas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Area Debug"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee ID: ${widget.employeeId}', // Show dynamic employee ID
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Found ${workAreas.length} work area(s)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: workAreas.length,
                        itemBuilder: (context, index) {
                          final area = workAreas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Work Area #${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Block', area.block),
                                  _buildDetailRow('District', area.district),
                                  _buildDetailRow('State', area.state),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
