import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel1.dart';
import '../model/visit_history_model.dart';
import '../service/visit_history_service.dart';

class Visitpage extends StatefulWidget {
  final Data1? employeeData;

  const Visitpage({super.key, this.employeeData});

  @override
  State<Visitpage> createState() => _VisitpageState();
}

class _VisitpageState extends State<Visitpage> {
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
      final model = await VisitHistoryService.getVisitorList(empMobile);

      if (mounted) {
        setState(() {
          visitHistoryModel = model;
          visitorsList = model?.visitors ?? [];
          filteredVisits = visitorsList;
          isLoading = false;
          isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage = 'Failed to load visit history. Please try again.';
        });
      }
    }
  }

  void _filterVisits(String filter) {
    if (visitorsList == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    setState(() {
      selectedFilter = filter;
      _searchQuery = '';
      _searchController.clear();

      switch (filter) {
        case 'Today':
          filteredVisits = visitorsList!.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null && _isSameDay(visitDate, today);
          }).toList();
          break;
        case 'Yesterday':
          filteredVisits = visitorsList!.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null && _isSameDay(visitDate, yesterday);
          }).toList();
          break;
        case 'This Week':
          filteredVisits = visitorsList!.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null &&
                visitDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                visitDate.isBefore(today.add(const Duration(days: 1)));
          }).toList();
          break;
        case 'This Month':
          filteredVisits = visitorsList!.where((visit) {
            final visitDate = _parseDate(visit.visitDate);
            return visitDate != null &&
                visitDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                visitDate.isBefore(DateTime(now.year, now.month + 1, 1));
          }).toList();
          break;
        default:
          filteredVisits = visitorsList;
      }
    });
  }

  void _searchVisits(String query) {
    if (visitorsList == null) return;

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filterVisits(selectedFilter);
      } else {
        List<Visitors> baseList = visitorsList!;

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
    } catch (_) {
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
    } catch (_) {
      return dateString;
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await _loadVisitHistory();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('Cannot make call to $phoneNumber', AppColors.error);
    }
  }

  void _viewOrder(Visitors visit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Visit Order Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Business', visit.businessName ?? 'N/A'),
                  const Divider(height: 14, color: AppColors.lightGold),
                  _buildDetailRow('Customer', visit.personName ?? 'N/A'),
                  const Divider(height: 14, color: AppColors.lightGold),
                  _buildDetailRow('Mobile', visit.mobile ?? 'N/A'),
                  const Divider(height: 14, color: AppColors.lightGold),
                  _buildDetailRow('Visit Date', _formatDate(visit.visitDate)),
                  const Divider(height: 14, color: AppColors.lightGold),
                  _buildDetailRow('Purpose', visit.purpose ?? 'N/A'),
                  const Divider(height: 14, color: AppColors.lightGold),
                  _buildDetailRow('Type', visit.visitFor ?? 'N/A'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewVisit(Visitors visit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_walk_rounded, color: AppColors.deepGold, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Start Visit',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  _buildVisitDetailItem(Icons.business_rounded, 'Business', visit.businessName),
                  _buildVisitDetailItem(Icons.person_rounded, 'Customer', visit.personName),
                  _buildVisitDetailItem(Icons.phone_rounded, 'Mobile', visit.mobile),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Start a visit follow-up for this customer?',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.lightGold.withOpacity(0.8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSnackBar(
                      'Visit initiated for ${visit.personName ?? 'customer'}',
                      AppColors.primaryGreen,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 2,
                  ),
                  child: Text(
                    'Start Visit',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisitDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
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
          style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          "Visit History",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.creamBackground,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by client, customer, mobile...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _searchVisits('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
          onChanged: _searchVisits,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      color: AppColors.creamBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: AppColors.white,
                    checkmarkColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.8),
                      ),
                    ),
                    onSelected: (bool selected) {
                      _filterVisits(filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Showing ${filteredVisits?.length ?? 0} visits${_searchQuery.isNotEmpty ? ' for "$_searchQuery"' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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
      color: AppColors.primaryGreen,
      backgroundColor: AppColors.white,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: filteredVisits!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildVisitCard(filteredVisits![index]);
        },
      ),
    );
  }

  Widget _buildVisitCard(Visitors visit) {
    final isRevisit = visit.reVisited?.toLowerCase() == 'yes';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isRevisit
                      ? AppColors.primaryGold.withOpacity(0.15)
                      : AppColors.leafGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isRevisit
                        ? AppColors.primaryGold
                        : AppColors.leafGreen,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRevisit ? Icons.replay_rounded : Icons.verified_rounded,
                      size: 12,
                      color: isRevisit ? AppColors.deepGold : AppColors.darkGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isRevisit ? 'Re-visit' : 'First Visit',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isRevisit ? AppColors.deepGold : AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Visit Date and ID
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                _formatDate(visit.visitDate),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.tag_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Text(
                'ID: ${visit.id ?? 'N/A'}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: AppColors.lightGold),

          // Contact Information
          _buildInfoRow(Icons.person_rounded, visit.personName ?? 'No Name'),
          const SizedBox(height: 5),
          _buildInfoRow(Icons.phone_rounded, visit.mobile ?? 'No Mobile'),
          const SizedBox(height: 5),
          _buildInfoRow(Icons.category_rounded, 'Type: ${visit.visitFor ?? 'N/A'}'),

          // Location chips
          if ((visit.block != null && visit.block!.isNotEmpty) ||
              (visit.district != null && visit.district!.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (visit.block != null && visit.block!.isNotEmpty)
                  _buildLocationChip(visit.block!, Icons.domain_rounded),
                if (visit.district != null && visit.district!.isNotEmpty)
                  _buildLocationChip(visit.district!, Icons.location_city_rounded),
              ],
            ),
          ],

          // Purpose
          if (visit.purpose != null && visit.purpose!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
              ),
              child: Text(
                'Purpose: ${visit.purpose!}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Remarks
          if (visit.remark != null && visit.remark!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarks:',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visit.remark!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons - View Order, Call, and Start Visit
          const SizedBox(height: 14),
          Row(
            children: [
              // View Order Button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.receipt_long_rounded,
                  label: 'View Order',
                  color: AppColors.darkGreen,
                  onPressed: () => _viewOrder(visit),
                ),
              ),
              const SizedBox(width: 8),

              // Call Button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.phone_forwarded_rounded,
                  label: 'Call',
                  color: AppColors.secondaryGreen,
                  onPressed: visit.mobile != null && visit.mobile!.isNotEmpty
                      ? () => _makePhoneCall(visit.mobile!)
                      : null,
                ),
              ),
              const SizedBox(width: 8),

              // Start Visit Button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.directions_walk_rounded,
                  label: 'Start Visit',
                  color: AppColors.primaryGold,
                  textColor: AppColors.darkGreen,
                  iconColor: AppColors.darkGreen,
                  onPressed: () => _startNewVisit(visit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = AppColors.white,
    Color iconColor = AppColors.white,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
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
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGold.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.primaryGreen),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Visit History...',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.warning),
            const SizedBox(height: 14),
            Text(
              'Unable to Load Visits',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadVisitHistory,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: const Icon(Icons.assignment_outlined, size: 50, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'No Visits Found',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No visits found matching "$_searchQuery"'
                  : selectedFilter == 'All'
                      ? 'Your visit history will appear here'
                      : 'No visits found for the selected period ($selectedFilter)',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
              label: Text(
                'Refresh Data',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}