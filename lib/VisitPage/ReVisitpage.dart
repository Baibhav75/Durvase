

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/visit_history_model.dart';
import '../service/visit_history_service.dart';
import '../model/TodoModel.dart';
import '/model/TodoModel1.dart';

class ReVisitPage extends StatefulWidget {
  final Data1? employeeData;

  const ReVisitPage({super.key, this.employeeData});

  @override
  State<ReVisitPage> createState() => _ReVisitPageState();
}

class _ReVisitPageState extends State<ReVisitPage> {
  VisitHistory_model? visitHistoryModel;
  List<Visitors>? visitorsList;
  List<Visitors>? filteredVisits;
  bool isLoading = true;
  String errorMessage = '';
  bool isRefreshing = false;

  // Filter variables
  String selectedFilter = 'All';
  final List<String> filters = [
    'All',
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
  ];

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadVisitHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVisitHistory() async {
    if (!isRefreshing) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      String empMobile = widget.employeeData?.mobile ?? '8024272651';
      print('Loading re-visit history for mobile: $empMobile');

      final model = await VisitHistoryService.getVisitorList(empMobile);

      setState(() {
        visitHistoryModel = model;
        visitorsList = model?.visitors ?? [];
        // Filter to show only re-visits
        filteredVisits = visitorsList?.where((visit) => 
          visit.reVisited?.toLowerCase() == 'yes').toList() ?? [];
        isLoading = false;
        isRefreshing = false;
      });

      print('✅ Loaded ${filteredVisits?.length ?? 0} re-visits');
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = 'Failed to load re-visit history. Please try again.';
      });
      print('❌ Error loading re-visit history: $e');
    }
  }

  void _filterVisits(String filter) {
    if (visitorsList == null) return;

    // First filter for re-visits only
    List<Visitors> revisitList = visitorsList!.where((visit) => 
      visit.reVisited?.toLowerCase() == 'yes').toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    setState(() {
      selectedFilter = filter;
      _searchQuery = ''; // Clear search when filter changes
      _searchController.clear();

      switch (filter) {
        case 'Today':
          filteredVisits = revisitList.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null && _isSameDay(visitDate, today);
          }).toList();
          break;
        case 'Yesterday':
          filteredVisits = revisitList.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null && _isSameDay(visitDate, yesterday);
          }).toList();
          break;
        case 'This Week':
          filteredVisits = revisitList.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null &&
                visitDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                visitDate.isBefore(today.add(const Duration(days: 1)));
          }).toList();
          break;
        case 'This Month':
          filteredVisits = revisitList.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null &&
                visitDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                visitDate.isBefore(DateTime(now.year, now.month + 1, 1));
          }).toList();
          break;
        default:
          filteredVisits = revisitList;
      }
    });
  }

  void _searchVisits(String query) {
    if (visitorsList == null) return;

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        // If search is empty, apply current filter
        _filterVisits(selectedFilter);
      } else {
        // Apply search on currently filtered list
        List<Visitors> baseList = visitorsList!;

        // Apply current filter first
        if (selectedFilter != 'All') {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          final monthStart = DateTime(now.year, now.month, 1);

          switch (selectedFilter) {
            case 'Today':
              baseList = visitorsList!.where((visit) {
                final visitDate = _parseDate(visit.visitDate);
                return visitDate != null && _isSameDay(visitDate, today);
              }).toList();
              break;
            case 'Yesterday':
              baseList = visitorsList!.where((visit) {
                final visitDate = _parseDate(visit.visitDate);
                return visitDate != null && _isSameDay(visitDate, yesterday);
              }).toList();
              break;
            case 'This Week':
              baseList = visitorsList!.where((visit) {
                final visitDate = _parseDate(visit.visitDate);
                return visitDate != null &&
                    visitDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                    visitDate.isBefore(today.add(const Duration(days: 1)));
              }).toList();
              break;
            case 'This Month':
              baseList = visitorsList!.where((visit) {
                final visitDate = _parseDate(visit.visitDate);
                return visitDate != null &&
                    visitDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                    visitDate.isBefore(DateTime(now.year, now.month + 1, 1));
              }).toList();
              break;
          }
        }

        // Filter for re-visits only
        baseList = baseList.where((visit) => 
          visit.reVisited?.toLowerCase() == 'yes').toList();

        // Then apply search
        filteredVisits = baseList.where((visit) {
          final businessName = visit.businessName?.toLowerCase() ?? '';
          final personName = visit.personName?.toLowerCase() ?? '';
          final mobile = visit.mobile?.toLowerCase() ?? '';
          final purpose = visit.purpose?.toLowerCase() ?? '';
          final visitFor = visit.visitFor?.toLowerCase() ?? '';

          return businessName.contains(query.toLowerCase()) ||
              personName.contains(query.toLowerCase()) ||
              mobile.contains(query.toLowerCase()) ||
              purpose.contains(query.toLowerCase()) ||
              visitFor.contains(query.toLowerCase());
        }).toList();
      }
    });
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
    await _loadVisitHistory();
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
              'Re-Visit Order Details',
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
            _buildDetailRow('Re-Visit Date', _formatDate(visit.visitDate)),
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

  // Continue Re-Visit function
  void _continueReVisit(Visitors visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Continue Re-Visit',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.green[800],
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
              'Continue the re-visit for this customer?',
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
                      'Re-visit continued for ${visit.personName ?? 'customer'}',
                      Colors.green,
                    );
                    // TODO: Add your actual re-visit continuing logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Continue',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Re-Visit History",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    return Column(
      children: [
        // Search Bar
        _buildSearchBar(),

        // Filter Chips
        _buildFilterSection(),

        // Visits List
        Expanded(child: _buildVisitsList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search re-visits by business, customer, mobile...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              _searchVisits('');
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.poppins(),
        onChanged: _searchVisits,
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selectedFilter == filter ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                    selected: selectedFilter == filter,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.grey[100],
                    checkmarkColor: Colors.white,
                    onSelected: (bool selected) {
                      _filterVisits(filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing ${filteredVisits?.length ?? 0} re-visits${_searchQuery.isNotEmpty ? ' for "$_searchQuery"' : ''}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList() {
    if (filteredVisits == null || filteredVisits!.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredVisits!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildVisitCard(filteredVisits![index]);
        },
      ),
    );
  }

  Widget _buildVisitCard(Visitors visit) {
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
                      color: Colors.green[50]!,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.green[100]!,
                      ),
                    ),
                    child: Text(
                      'Re-visit',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800]!,
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

              // Action Buttons - View Order, Call, and Continue Re-Visit
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

                  // Continue Re-Visit Button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.refresh,
                      label: 'Continue',
                      color: Colors.orange,
                      onPressed: () => _continueReVisit(visit),
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
            'Loading Re-Visit History...',
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
              'Unable to Load Re-Visits',
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
              onPressed: _loadVisitHistory,
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
            Icon(Icons.refresh_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Re-Visits Found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No re-visits found for "$_searchQuery"'
                  : selectedFilter == 'All'
                  ? 'Your re-visit history will appear here'
                  : 'No re-visits found for the selected period',
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