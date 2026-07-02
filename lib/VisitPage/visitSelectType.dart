import 'package:flutter/material.dart';
import '/VisitPage/VisitPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/TodoModel1.dart'; // Added import for employee data
import '../model/visit_history_model.dart';
import '../service/visit_history_service.dart';
import 'NewVisitPage.dart';
import 'ReVisitpage.dart';

class VisitTypeScreen extends StatefulWidget {
  final Data1? employeeData; // Added employee data parameter

  const VisitTypeScreen({Key? key, this.employeeData})
      : super(key: key); // Updated constructor

  @override
  _VisitTypeScreenState createState() => _VisitTypeScreenState();
}

class _VisitTypeScreenState extends State<VisitTypeScreen> {
  int _selectedVisitType = 0;
  final List<String> _visitTypes = ['New', 'Visit', 'Re-Visit'];

  // API Integration variables
  VisitHistory_model? visitHistoryModel;
  List<Visitors>? visitorsList;
  List<Visitors>? todayVisits;
  bool isLoading = true;
  String errorMessage = '';
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTodayVisits();
  }

  Future<void> _loadTodayVisits() async {
    if (!isRefreshing) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      String empMobile = widget.employeeData?.mobile ?? '8024272651';
      print('Loading today visits for mobile: $empMobile');

      final model = await VisitHistoryService.getVisitorList(empMobile);

      setState(() {
        visitHistoryModel = model;
        visitorsList = model?.visitors ?? [];
        
        // Filter for today's visits
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        todayVisits = visitorsList?.where((visit) {
          final visitDate = _parseDate(visit.visitDate);
          return visitDate != null && _isSameDay(visitDate, today);
        }).toList() ?? [];
        
        isLoading = false;
        isRefreshing = false;
      });

      print('✅ Loaded ${todayVisits?.length ?? 0} today visits');
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = 'Failed to load today visits. Please try again.';
      });
      print('❌ Error loading today visits: $e');
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

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = _parseDate(dateString);
      if (date != null) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await _loadTodayVisits();
  }

  // Call function
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('Cannot make call to $phoneNumber', Colors.red);
    }
  }

  // View Order function
  void _viewOrder(Visitors visit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Business', visit.businessName ?? 'N/A'),
            _buildDetailRow('Customer', visit.personName ?? 'N/A'),
            _buildDetailRow('Mobile', visit.mobile ?? 'N/A'),
            _buildDetailRow('Visit Date', _formatDate(visit.visitDate)),
            _buildDetailRow('Purpose', visit.purpose ?? 'N/A'),
            _buildDetailRow('Type', visit.visitFor ?? 'N/A'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Start Visit function
  void _startVisit(Visitors visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Start Visit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.orange[800],
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisitDetailItem(Icons.business, 'Business', visit.businessName),
            _buildVisitDetailItem(Icons.person, 'Customer', visit.personName),
            _buildVisitDetailItem(Icons.phone, 'Mobile', visit.mobile),
            const SizedBox(height: 16),
            Text(
              'Start a visit for this customer?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(
                      'Visit started for ${visit.personName ?? 'customer'}',
                      Colors.green,
                    );
                    // TODO: Add your actual visit starting logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Start Visit',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleVisitTypeSelection(int index, BuildContext context) {
    setState(() {
      _selectedVisitType = index;
    });

    // Navigate to different pages based on selection
    if (index == 0) {
      _navigateToNewVisitPage(context);
    } else if (index == 1) {
      _navigateToVisitPage(context);
    } else if (index == 2) {
      _navigateToReVisitPage(context);
    }
  }

  void _navigateToNewVisitPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewVisitForm(
          employeeData:
          widget.employeeData, // Pass employee data to NewVisitForm
        ),
      ),
    );
  }

  void _navigateToVisitPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Visitpage(employeeData: widget.employeeData)),
    );
  }

  void _navigateToReVisitPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReVisitPage(employeeData: widget.employeeData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select Visit Type',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisitTypeSection(),
          _buildDivider(),
          _buildVisitListSection(),
        ],
      ),
    );
  }

  Widget _buildVisitTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit Type',
            style: GoogleFonts.inter(
              color: const Color(0xFF666666),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(_visitTypes.length, (index) {
                return _buildVisitTypeItem(_visitTypes[index], index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTypeItem(String type, int index) {
    bool isSelected = _selectedVisitType == index;
    bool isLastItem = index == _visitTypes.length - 1;

    return Container(
      decoration: BoxDecoration(
        border: isLastItem
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isSelected
              ? Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2563EB),
            ),
          )
              : null,
        ),
        title: Text(
          type,
          style: GoogleFonts.inter(
            color: const Color(0xFF333333),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF2563EB),
          size: 20,
        )
            : null,
        onTap: () {
          _handleVisitTypeSelection(index, context);
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 8, color: const Color(0xFFF1F5F9));
  }

  Widget _buildVisitListSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today Visit List',
              style: GoogleFonts.inter(
                color: const Color(0xFF333333),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
                ),
                if (todayVisits != null && todayVisits!.isNotEmpty)
                  Text(
                    '${todayVisits!.length} visits',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF666666),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Visit List Content
            Expanded(
              child: _buildVisitListContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitListContent() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (todayVisits == null || todayVisits!.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      child: ListView.separated(
        itemCount: todayVisits!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildVisitCard(todayVisits![index]);
        },
      ),
    );
  }

  Widget _buildVisitCard(Visitors visit) {
    final isRevisit = visit.reVisited?.toLowerCase() == 'yes';

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      visit.businessName ?? 'No Business Name',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRevisit ? Colors.green[50]! : Colors.blue[50]!,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isRevisit ? Colors.green[100]! : Colors.blue[100]!,
                      ),
                    ),
                    child: Text(
                      isRevisit ? 'Re-visit' : 'First Visit',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isRevisit ? Colors.green[800]! : Colors.blue[800]!,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Visit Date and ID
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(visit.visitDate),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${visit.id ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contact Information
              _buildInfoRow(Icons.person, visit.personName ?? 'No Name'),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.phone, visit.mobile ?? 'No Mobile'),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.category, 'Type: ${visit.visitFor ?? 'N/A'}'),

              // Location
              if (visit.block != null || visit.district != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (visit.block != null && visit.block!.isNotEmpty)
                      _buildLocationChip(visit.block!),
                    if (visit.district != null && visit.district!.isNotEmpty)
                      _buildLocationChip(visit.district!),
                  ],
                ),
              ],

              // Purpose
              if (visit.purpose != null && visit.purpose!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Purpose: ${visit.purpose!}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Remarks
              if (visit.remark != null && visit.remark!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remarks:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        visit.remark!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons - View Order, Call, and Visit
              const SizedBox(height: 16),
              Row(
                children: [
                  // View Order Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.shopping_cart,
                      label: 'View Order',
                      color: Colors.deepPurple,
                      onPressed: () => _viewOrder(visit),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Call Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.phone,
                      label: 'Call',
                      color: Colors.green,
                      onPressed: visit.mobile != null && visit.mobile!.isNotEmpty
                          ? () => _makePhoneCall(visit.mobile!)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Visit Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.location_on,
                      label: 'Visit',
                      color: Colors.orange,
                      onPressed: () => _startVisit(visit),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String text) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue[800]),
      ),
      backgroundColor: Colors.blue[50],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Today Visits...',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Visits',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTodayVisits,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Visits Today',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your today\'s visits will appear here',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Refresh Data',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }


}