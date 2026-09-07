// viewHome/widgets/mr_work_report_history_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../model/TodoModel.dart';
import '../../model/mr_work_report_history_model.dart';
import '../../service/mr_work_report_history_service.dart';
import '../../service/session_manager.dart';
import 'mr_work_report_page.dart';

class MRWorkReportHistoryPage extends StatefulWidget {
  final TodoModel? userData;
  final String? empId;

  const MRWorkReportHistoryPage({
    super.key,
    this.userData,
    this.empId,
  });

  @override
  State<MRWorkReportHistoryPage> createState() => _MRWorkReportHistoryPageState();
}

class _MRWorkReportHistoryPageState extends State<MRWorkReportHistoryPage> {
  late Future<MRWorkReportHistoryModel> _historyFuture;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month', 'Submitted'];

  String? _resolvedEmpId;
  String? _resolvedEmpName;

  @override
  void initState() {
    super.initState();
    _initSessionAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSessionAndLoad() async {
    String? id = widget.empId ?? widget.userData?.empId ?? widget.userData?.asmId;
    if (id == null || id.isEmpty) {
      id = await SessionManager.getEmpId();
    }
    if (id == null || id.isEmpty) {
      final loginData = await SessionManager.getLoginData();
      id = loginData?.empId ?? loginData?.asmId;
    }

    String? name = widget.userData?.name;
    if (name == null || name.isEmpty) {
      name = await SessionManager.getName();
    }

    if (mounted) {
      setState(() {
        _resolvedEmpId = id;
        _resolvedEmpName = name;
        _historyFuture = MRWorkReportHistoryService.getWorkReportHistory(_resolvedEmpId);
      });
    }
  }

  void _reloadHistory() {
    setState(() {
      _historyFuture = MRWorkReportHistoryService.getWorkReportHistory(_resolvedEmpId);
    });
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateTime.tryParse(dateStr.trim());
    } catch (_) {
      return null;
    }
  }

  String _formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return 'N/A';
    try {
      final date = DateTime.tryParse(dateStr.trim());
      if (date != null) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return 'N/A';
    try {
      final date = DateTime.tryParse(dateStr.trim());
      if (date != null) {
        return DateFormat('dd MMM yyyy, hh:mm a').format(date);
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  List<MRWorkReportHistoryItem> _filterReports(List<MRWorkReportHistoryItem> list) {
    var result = list;

    // 1. Time / Status Filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    if (_selectedFilter == 'Today') {
      result = result.where((item) {
        final d = _parseDate(item.reportDate ?? item.createdAt);
        return d != null && d.year == today.year && d.month == today.month && d.day == today.day;
      }).toList();
    } else if (_selectedFilter == 'This Week') {
      result = result.where((item) {
        final d = _parseDate(item.reportDate ?? item.createdAt);
        return d != null &&
            d.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            d.isBefore(today.add(const Duration(days: 1)));
      }).toList();
    } else if (_selectedFilter == 'This Month') {
      result = result.where((item) {
        final d = _parseDate(item.reportDate ?? item.createdAt);
        return d != null &&
            d.isAfter(monthStart.subtract(const Duration(days: 1))) &&
            d.isBefore(DateTime(now.year, now.month + 1, 1));
      }).toList();
    } else if (_selectedFilter == 'Submitted') {
      result = result.where((item) {
        return (item.reportStatus ?? '').trim().toLowerCase() == 'submitted';
      }).toList();
    }

    // 2. Text Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((item) {
        final area = (item.workingArea ?? '').toLowerCase();
        final block = (item.block ?? '').toLowerCase();
        final zone = (item.zone ?? '').toLowerCase();
        final state = (item.state ?? '').toLowerCase();
        final status = (item.reportStatus ?? '').toLowerCase();
        final details = (item.workDetails ?? '').toLowerCase();
        final date = (item.reportDate ?? '').toLowerCase();
        final id = (item.id?.toString() ?? '').toLowerCase();

        return area.contains(q) ||
            block.contains(q) ||
            zone.contains(q) ||
            state.contains(q) ||
            status.contains(q) ||
            details.contains(q) ||
            date.contains(q) ||
            id.contains(q);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Work Report History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.lightGold),
            tooltip: 'New Work Report',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MrWorkReportPage(userData: widget.userData),
                ),
              ).then((_) => _reloadHistory());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Refresh',
            onPressed: _reloadHistory,
          ),
        ],
      ),
      body: FutureBuilder<MRWorkReportHistoryModel>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data?.data == null || snapshot.data!.data!.isEmpty) {
            return _buildEmptyState();
          }

          final allReports = snapshot.data!.data!;
          final filteredReports = _filterReports(allReports);

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.white,
            onRefresh: () async {
              _reloadHistory();
              await _historyFuture;
            },
            child: Column(
              children: [
                // Top Summary Header Card
                _buildHeroBanner(allReports),

                // Search Box
                _buildSearchBar(),

                // Filter Chips Row
                _buildFilterChips(),

                // Result list count info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reports (${filteredReports.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'All';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: Text(
                            'Reset Filters',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Reports List
                Expanded(
                  child: filteredReports.isEmpty
                      ? _buildNoSearchResults()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, index) {
                            final report = filteredReports[index];
                            return _buildReportCard(report);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO STATS BANNER
  // ------------------------------------------------------------
  Widget _buildHeroBanner(List<MRWorkReportHistoryItem> reports) {
    int totalCalls = 0;
    double totalOrders = 0.0;
    double totalExpenses = 0.0;

    for (final r in reports) {
      totalCalls += r.totalVisits;
      totalOrders += r.totalOrder;
      totalExpenses += r.expenseValue;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [AppColors.lightGold, AppColors.primaryGold, AppColors.deepGold],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primaryGreen, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resolvedEmpName ?? 'MR Work History',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Employee ID: ${_resolvedEmpId ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 12),

          // 4 Metric Badges
          Row(
            children: [
              _buildStatChip(
                icon: Icons.description_rounded,
                label: 'Reports',
                value: '${reports.length}',
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.people_outline_rounded,
                label: 'Field Calls',
                value: '$totalCalls',
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.shopping_bag_outlined,
                label: 'Orders',
                value: '₹${totalOrders.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                icon: Icons.payments_outlined,
                label: 'Expenses',
                value: '₹${totalExpenses.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.lightGold),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: AppColors.cream.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
            hintText: 'Search by working area, block, zone, date...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
          onChanged: (val) {
            setState(() => _searchQuery = val.trim());
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER CHIPS
  // ------------------------------------------------------------
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
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
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WORK REPORT CARD
  // ------------------------------------------------------------
  Widget _buildReportCard(MRWorkReportHistoryItem report) {
    final status = report.reportStatus ?? 'Submitted';
    final isSubmitted = status.toLowerCase() == 'submitted';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withOpacity(0.55)),
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
          // Header Row: Date & Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.event_note_rounded, size: 16, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDisplayDate(report.reportDate ?? report.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (report.id != null)
                        Text(
                          'Report ID: #${report.id}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isSubmitted
                      ? AppColors.primaryGreen.withOpacity(0.12)
                      : AppColors.primaryGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSubmitted ? AppColors.primaryGreen : AppColors.primaryGold,
                    width: 1,
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSubmitted ? AppColors.primaryGreen : AppColors.deepGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.lightGold),
          const SizedBox(height: 10),

          // Working Area & Location Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 15, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.workingArea?.isNotEmpty == true
                          ? report.workingArea!
                          : 'Area not specified',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (report.block != null && report.block!.isNotEmpty)
                          _buildLocationChip(report.block!, Icons.domain_rounded),
                        if (report.zone != null && report.zone!.isNotEmpty)
                          _buildLocationChip(report.zone!, Icons.explore_rounded),
                        if (report.state != null && report.state!.isNotEmpty)
                          _buildLocationChip(report.state!, Icons.public_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Calls & Visits Count Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.creamBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCallCountItem(
                  icon: Icons.person_search_rounded,
                  label: 'Doctors',
                  count: report.totalDoctorVisits ?? '0',
                ),
                Container(width: 1, height: 24, color: AppColors.lightGold),
                _buildCallCountItem(
                  icon: Icons.local_pharmacy_rounded,
                  label: 'Chemists',
                  count: report.totalChemistVisits ?? '0',
                ),
                Container(width: 1, height: 24, color: AppColors.lightGold),
                _buildCallCountItem(
                  icon: Icons.store_rounded,
                  label: 'Stockists',
                  count: report.totalStockistVisits ?? '0',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Order & Expense Financial Summary Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_rounded, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orders (P+S)',
                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                            ),
                            Text(
                              '₹${report.totalOrder.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, size: 16, color: AppColors.deepGold),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Expense',
                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                            ),
                            Text(
                              '₹${report.expenseValue.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Work Details Text snippet if available
          if (report.workDetails != null && report.workDetails!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
              ),
              child: Text(
                '📝 ${report.workDetails!.trim()}',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Button: View Full Details
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () => _showReportDetailModal(report),
              icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primaryGreen),
              label: Text(
                'View Complete Details',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallCountItem({
    required IconData icon,
    required String label,
    required String count,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGold.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.primaryGreen),
          const SizedBox(width: 3),
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

  // ------------------------------------------------------------
  // DETAILED MODAL BOTTOM SHEET
  // ------------------------------------------------------------
  void _showReportDetailModal(MRWorkReportHistoryItem report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            // Modal Header
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Report Details',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Date: ${_formatDisplayDate(report.reportDate ?? report.createdAt)} • #${report.id ?? ""}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.lightGold),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Territory & Route
                    _buildModalSectionTitle('Territory & Working Route', Icons.map_outlined),
                    _buildModalInfoRow('State', report.state ?? 'N/A'),
                    _buildModalInfoRow('Zone', report.zone ?? 'N/A'),
                    _buildModalInfoRow('Block', report.block ?? 'N/A'),
                    _buildModalInfoRow('Working Area / HQ', report.workingArea ?? 'N/A'),

                    const SizedBox(height: 14),

                    // Section 2: Calls Breakdown
                    _buildModalSectionTitle('Field Calls & Visits', Icons.medical_services_outlined),
                    _buildModalInfoRow('Doctor Visits', report.totalDoctorVisits ?? '0'),
                    _buildModalInfoRow('Chemist Visits', report.totalChemistVisits ?? '0'),
                    _buildModalInfoRow('Stockist Visits', report.totalStockistVisits ?? '0'),
                    _buildModalInfoRow('Total Field Calls', '${report.totalVisits} Calls', isBold: true),

                    const SizedBox(height: 14),

                    // Section 3: Orders Booked
                    _buildModalSectionTitle('Orders Booked', Icons.shopping_cart_outlined),
                    _buildModalInfoRow('Primary Order Value', '₹${report.primaryOrderValue ?? "0"}'),
                    _buildModalInfoRow('Secondary Order Value', '₹${report.secondaryOrderValue ?? "0"}'),
                    _buildModalInfoRow('Total Orders Value', '₹${report.totalOrder.toStringAsFixed(0)}', isBold: true),

                    const SizedBox(height: 14),

                    // Section 4: Daily Expenses
                    _buildModalSectionTitle('Daily Expenses', Icons.account_balance_wallet_outlined),
                    _buildModalInfoRow('Daily Expense Claimed', '₹${report.dailyExpense ?? "0"}', isBold: true),
                    _buildModalInfoRow('Expense Remarks', report.expenseRemarks ?? 'N/A'),

                    const SizedBox(height: 14),

                    // Section 5: Work Details & Notes
                    if (report.workDetails != null && report.workDetails!.isNotEmpty) ...[
                      _buildModalSectionTitle('Work Details & Observations', Icons.notes_rounded),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
                        ),
                        child: Text(
                          report.workDetails!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.textDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Section 6: Geo Location & System Info
                    _buildModalSectionTitle('System & Location Info', Icons.info_outline_rounded),
                    if (report.latitude != null || report.longitude != null)
                      _buildModalInfoRow('GPS Coordinates', '${report.latitude ?? "-"}, ${report.longitude ?? "-"}'),
                    _buildModalInfoRow('Report Status', report.reportStatus ?? 'Submitted'),
                    _buildModalInfoRow('Submission Time', _formatDateTime(report.createdAt)),
                    if (report.updatedAt != null)
                      _buildModalInfoRow('Last Updated', _formatDateTime(report.updatedAt)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Close Details',
                  style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalInfoRow(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.lightGold.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: isBold ? AppColors.primaryGreen : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY & ERROR STATES
  // ------------------------------------------------------------
  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No Reports Found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No work reports matching "$_searchQuery".',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: const Icon(Icons.assignment_outlined, size: 54, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'No Work Reports Yet',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You haven\'t submitted any daily MR work reports yet. Tap below to create your first report.',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MrWorkReportPage(userData: widget.userData),
                  ),
                ).then((_) => _reloadHistory());
              },
              icon: const Icon(Icons.add_rounded, color: AppColors.white),
              label: Text(
                'Submit Today\'s Report',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.warning),
            const SizedBox(height: 14),
            Text(
              'Unable to Load Reports',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reloadHistory,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
              label: Text(
                'Retry',
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
