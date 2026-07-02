import 'package:flutter/material.dart';

class AttendanceHistoryPage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendanceHistoryPage> {
  int _selectedTab = 0;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceData = [];

  final List<Map<String, dynamic>> _monthlySummary = [
    {
      'month': 'November 2024',
      'present': 22,
      'absent': 3,
      'late': 2,
      'leave': 3,
    },
    {
      'month': 'October 2024',
      'present': 20,
      'absent': 5,
      'late': 1,
      'leave': 4,
    },
    {
      'month': 'September 2024',
      'present': 23,
      'absent': 2,
      'late': 0,
      'leave': 5,
    },
  ];

  final List<Map<String, dynamic>> _recentAttendance = [
    {
      'date': '2024-11-28',
      'day': 'Thursday',
      'check_in': '08:45 AM',
      'check_out': '05:30 PM',
      'status': 'Present',
      'statusColor': Colors.green,
      'working_hours': '8h 45m',
      'location': 'Office Main Gate',
    },
    {
      'date': '2024-11-27',
      'day': 'Wednesday',
      'check_in': '09:15 AM',
      'check_out': '05:25 PM',
      'status': 'Late',
      'statusColor': Colors.orange,
      'working_hours': '8h 10m',
      'location': 'Office Main Gate',
    },
    {
      'date': '2024-11-26',
      'day': 'Tuesday',
      'check_in': '08:30 AM',
      'check_out': '05:45 PM',
      'status': 'Present',
      'statusColor': Colors.green,
      'working_hours': '9h 15m',
      'location': 'Office Main Gate',
    },
    {
      'date': '2024-11-25',
      'day': 'Monday',
      'check_in': '--:--',
      'check_out': '--:--',
      'status': 'Absent',
      'statusColor': Colors.red,
      'working_hours': '0h 0m',
      'location': '--',
    },
    {
      'date': '2024-11-22',
      'day': 'Friday',
      'check_in': '08:50 AM',
      'check_out': '05:20 PM',
      'status': 'Present',
      'statusColor': Colors.green,
      'working_hours': '8h 30m',
      'location': 'Office Main Gate',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    setState(() {
      _attendanceData = _recentAttendance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _showCalendar,
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _downloadReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Summary
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'This Month Summary',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Present',
                      '22',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildSummaryItem('Absent', '3', Icons.cancel, Colors.red),
                    _buildSummaryItem(
                      'Late',
                      '2',
                      Icons.watch_later,
                      Colors.orange,
                    ),
                    _buildSummaryItem(
                      'Leave',
                      '3',
                      Icons.beach_access,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab('Daily Log', 0),
                _buildTab('Monthly Report', 1),
                _buildTab('Statistics', 2),
              ],
            ),
          ),

          // Tab Content
          Expanded(child: _buildTabContent()),
        ],
      ),

      // Check-in/Check-out Button
      bottomNavigationBar: _buildAttendanceButton(),
    );
  }

  Widget _buildSummaryItem(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index
                    ? Colors.blue[700]!
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTab == index
                  ? Colors.blue[700]
                  : Colors.grey[600],
              fontWeight: _selectedTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildDailyLog();
      case 1:
        return _buildMonthlyReport();
      case 2:
        return _buildStatistics();
      default:
        return _buildDailyLog();
    }
  }

  Widget _buildDailyLog() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _attendanceData.length,
      itemBuilder: (context, index) {
        return _buildAttendanceCard(_attendanceData[index]);
      },
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['day'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      record['date'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: record['statusColor'].withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    record['status'],
                    style: TextStyle(
                      color: record['statusColor'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Time Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeDetail('Check In', record['check_in'], Icons.login),
                _buildVerticalDivider(),
                _buildTimeDetail(
                  'Check Out',
                  record['check_out'],
                  Icons.logout,
                ),
                _buildVerticalDivider(),
                _buildTimeDetail(
                  'Working Hours',
                  record['working_hours'],
                  Icons.access_time,
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Location: ${record['location']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(String title, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[700]),
        SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 30, color: Colors.grey[300]);
  }

  Widget _buildMonthlyReport() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _monthlySummary.length,
      itemBuilder: (context, index) {
        return _buildMonthlyCard(_monthlySummary[index]);
      },
    );
  }

  Widget _buildMonthlyCard(Map<String, dynamic> summary) {
    int totalDays =
        summary['present'] +
            summary['absent'] +
            summary['late'] +
            summary['leave'];
    double presentPercentage = (summary['present'] / totalDays) * 100;

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary['month'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),

            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: summary['present'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: summary['absent'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: summary['late'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: summary['leave'],
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItemSmall(
                  'Present',
                  summary['present'].toString(),
                  Colors.green,
                ),
                _buildStatItemSmall(
                  'Absent',
                  summary['absent'].toString(),
                  Colors.red,
                ),
                _buildStatItemSmall(
                  'Late',
                  summary['late'].toString(),
                  Colors.orange,
                ),
                _buildStatItemSmall(
                  'Leave',
                  summary['leave'].toString(),
                  Colors.purple,
                ),
              ],
            ),

            SizedBox(height: 8),

            // Percentage
            Center(
              child: Text(
                'Attendance Rate: ${presentPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItemSmall(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildStatistics() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Attendance Rate
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Overall Attendance Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 120,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: 0.87,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                        Center(
                          child: Text(
                            '87%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Monthly Comparison
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Comparison',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildComparisonBar('Nov 2024', 87, Colors.blue[700]!),
                  _buildComparisonBar('Oct 2024', 78, Colors.orange),
                  _buildComparisonBar('Sep 2024', 92, Colors.green),
                  _buildComparisonBar('Aug 2024', 85, Colors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String month, int percentage, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              month,
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton() {
    bool isCheckedIn = true; // This would come from your logic
    String currentTime = '09:15 AM';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCheckedIn ? 'Checked In' : 'Not Checked In',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    isCheckedIn ? currentTime : '--:--',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isCheckedIn ? _checkOut : _checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.orange : Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCheckedIn ? 'Check Out' : 'Check In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 50, color: Colors.blue[700]),
            SizedBox(height: 16),
            Text('Confirm check in at current location?'),
            SizedBox(height: 8),
            Text(
              'Office Main Gate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Checked in successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _checkOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 50, color: Colors.orange),
            SizedBox(height: 16),
            Text('Confirm check out?'),
            SizedBox(height: 8),
            Text(
              'Working Hours: 8h 15m',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Checked out successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Check Out'),
          ),
        ],
      ),
    );
  }

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Date'),
        content: Container(
          height: 300,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading attendance report...'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}
