 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/visit_history_service.dart';
import '../model/visit_history_model.dart';

class TaskScreen extends StatefulWidget {
  final dynamic employeeData;

  const TaskScreen({Key? key, this.employeeData}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Today', 'Tomorrow', 'Future', 'Expire'];

  bool isLoading = true;
  String errorMessage = '';
  List<Visitors> _allRevisits = [];

  @override
  void initState() {
    super.initState();
    _loadRevisitTasks();
  }

  Future<void> _loadRevisitTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Use passed mobile if available, otherwise fallback
      String empMobile = widget.employeeData?.mobile ?? '8024272651';
      final model = await VisitHistoryService.getVisitorList(empMobile);

      if (model != null && model.visitors != null) {
        setState(() {
          _allRevisits = model.visitors!
              .where((visit) => visit.reVisited?.toLowerCase() == 'yes')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No data found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load tasks.';
      });
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      if (dateString.contains('-')) {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } else if (dateString.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(dateString);
      } else {
        return DateTime.tryParse(dateString);
      }
    } catch (e) {
      return null;
    }
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<Visitors> _getFilteredTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _allRevisits.where((visit) {
      final visitDate = _parseDate(visit.visitDate);
      if (visitDate == null) return false; // Exclude if no valid date
      final vDate = DateTime(visitDate.year, visitDate.month, visitDate.day);

      switch (_selectedTab) {
        case 0: // Today
          return _isSameDay(vDate, today);
        case 1: // Tomorrow
          return _isSameDay(vDate, tomorrow);
        case 2: // Future
          return vDate.isAfter(tomorrow);
        case 3: // Expire
          return vDate.isBefore(today);
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Re-visit Tasks',
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : Column(
                          children: [
                            // Showing Tasks Text
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Showing ${_tabs[_selectedTab]} Tasks (${filteredTasks.length})',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // Task List
                            Expanded(
                              child: filteredTasks.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "No tasks found for this category.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredTasks.length,
                                      itemBuilder: (context, index) {
                                        return TaskItem(
                                          taskNumber: index + 1,
                                          visitor: filteredTasks[index],
                                        );
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
  final Visitors visitor;

  const TaskItem({
    Key? key,
    required this.taskNumber,
    required this.visitor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = visitor.businessName?.isNotEmpty == true
        ? visitor.businessName!
        : (visitor.personName ?? 'Unknown');
    String desc = visitor.purpose ?? 'No specific purpose';
    
    String formattedDate = visitor.visitDate ?? '';
    try {
      if (formattedDate.isNotEmpty) {
        // Simple parsing format for UI
        DateTime? dt;
        if (formattedDate.contains('-')) {
          dt = DateFormat('yyyy-MM-dd').parse(formattedDate);
        } else if (formattedDate.contains('/')) {
          dt = DateFormat('dd/MM/yyyy').parse(formattedDate);
        } else {
          dt = DateTime.tryParse(formattedDate);
        }
        if (dt != null) {
          formattedDate = DateFormat('dd MMM yyyy').format(dt);
        }
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
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
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Task Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
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
            child: const Icon(Icons.check, size: 16, color: Colors.transparent),
          ),
        ],
      ),
    );
  }
}
