import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Today', 'Tomorrow', 'Future', 'Expire'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          'All Active Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == index
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: _selectedTab == index
                                ? Colors.blue
                                : Colors.grey,
                            fontWeight: _selectedTab == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content Area
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  // Showing Today Tasks Text
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Showing Today Tasks',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Task List
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5, // Replace with your actual task count
                      itemBuilder: (context, index) {
                        return TaskItem(taskNumber: index + 1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final int taskNumber;

  const TaskItem({Key? key, required this.taskNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Task Number Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                taskNumber.toString(),
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: 16),

          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Title $taskNumber',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Task description goes here...',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '2:00 PM',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.check, size: 16, color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
