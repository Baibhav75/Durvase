import 'package:flutter/material.dart';
import '/model/work_area_model.dart';
import '/service/work_Area_Service.dart';

class FieldAllotted extends StatefulWidget {
  final String employeeId; // Make employeeId a parameter

  const FieldAllotted({super.key, required this.employeeId});

  @override
  State<FieldAllotted> createState() => _FieldAllottedState();
}

class _FieldAllottedState extends State<FieldAllotted> {
  List<WorkAreaModel> workAreas = [];
  bool isLoading = true;
  String errorMessage = '';
  // Remove the static employeeId and use widget.employeeId instead

  @override
  void initState() {
    super.initState();
    _fetchWorkAreas();
  }

  Future<void> _fetchWorkAreas() async {
    try {
      final areas = await WorkAreaService.getWorkAreas(
        widget.employeeId,
      ); // Use dynamic employeeId
      setState(() {
        workAreas = areas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchWorkAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Working Area"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (workAreas.isEmpty) {
      return _buildEmptyState();
    }

    return _buildWorkAreasList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your work areas...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Work Areas Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have not been allotted any work areas yet.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkAreasList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allotted Work Areas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[800],
                          ),
                        ),
                        Text(
                          '${workAreas.length} area(s) assigned',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Employee ID: ${widget.employeeId}', // Show dynamic employee ID
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Work Areas List
            Expanded(
              child: ListView.builder(
                itemCount: workAreas.length,
                itemBuilder: (context, index) {
                  return _buildWorkAreaCard(workAreas[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkAreaCard(WorkAreaModel workArea, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withOpacity(0.05),
              Colors.purple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Work Area Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Block
                    _buildDetailItem(
                      icon: Icons.location_city,
                      title: 'Block',
                      value: workArea.block,
                    ),
                    const SizedBox(height: 12),

                    // District
                    _buildDetailItem(
                      icon: Icons.map,
                      title: 'District',
                      value: workArea.district,
                    ),
                    const SizedBox(height: 12),

                    // State
                    _buildDetailItem(
                      icon: Icons.public,
                      title: 'State',
                      value: workArea.state,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
