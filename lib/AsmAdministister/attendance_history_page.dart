import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../model/Asmattendance_history_model.dart';
import '../model/TodoModel.dart';
import '../model/asm_profile_model.dart';
import '../service/asm_profile_service.dart';
import '../service/attendance_history_service.dart';

class AsmAttendanceHistoryPage extends StatefulWidget {
  final AsmProfileModel? asmProfileModel;
  final TodoModel? userData;
  final String? empId;

  const AsmAttendanceHistoryPage({
    super.key,
    this.asmProfileModel,
    this.userData,
    this.empId,
  });

  @override
  State<AsmAttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AsmAttendanceHistoryPage> {
  final AttendanceHistoryService _service = AttendanceHistoryService();

  List<AttendanceHistoryModel> _allAttendanceList = [];
  List<AttendanceHistoryModel> _filteredList = [];
  AsmProfileModel? _profile;

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'ALL'; // 'ALL', 'COMPLETED', 'CHECKED_IN'

  static const String _imageBaseUrl = 'https://durvasaayurved.online';

  int get _resolvedAsmId {
    final rawId = widget.userData?.asmId ??
        widget.userData?.empId ??
        widget.asmProfileModel?.asmId?.toString() ??
        '1';
    return int.tryParse(rawId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
  }

  String get _resolvedEmpId {
    if (widget.empId != null && widget.empId!.trim().isNotEmpty) {
      return widget.empId!.trim();
    }
    final activeProfile = _profile ?? widget.asmProfileModel;
    if (activeProfile != null) {
      final id = activeProfile.empId ??
          activeProfile.uniqueId ??
          activeProfile.employeeCode;
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }
    if (widget.userData != null) {
      final id = widget.userData!.empId ?? widget.userData!.asmId;
      if (id != null && id.trim().isNotEmpty) return id.trim();
    }
    return '';
  }

  String get _displayName {
    return _profile?.name ??
        widget.asmProfileModel?.name ??
        widget.userData?.name ??
        'ASM Member';
  }

  @override
  void initState() {
    super.initState();
    if (widget.asmProfileModel != null) {
      _profile = widget.asmProfileModel;
    }
    _loadAttendanceHistory();
  }

  Future<void> _loadAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. If we don't have the full ASM Profile yet, fetch it to resolve the exact EmpId (e.g. EMP241281)
      if (_profile == null) {
        try {
          final fetched = await AsmProfileService.getAsmProfile(_resolvedAsmId);
          _profile = fetched;
        } catch (e) {
          debugPrint('Notice: AsmProfile fetch before attendance: $e');
        }
      }

      final empId = _resolvedEmpId;
      if (empId.isEmpty) {
        throw Exception('Employee ID is missing. Unable to fetch attendance.');
      }

      final result = await _service.getAttendanceHistory(empId);

      if (!mounted) return;

      setState(() {
        _allAttendanceList = result;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'COMPLETED') {
      _filteredList = _allAttendanceList.where((a) => a.checkOutTime != null).toList();
    } else if (_selectedFilter == 'CHECKED_IN') {
      _filteredList = _allAttendanceList.where((a) => a.checkOutTime == null).toList();
    } else {
      _filteredList = List.from(_allAttendanceList);
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatDayName(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEEE').format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('hh:mm a').format(date);
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$_imageBaseUrl$trimmed';
    }
    return '$_imageBaseUrl/$trimmed';
  }

  void _showImagePreviewDialog(String imageUrl, String title) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_rounded, size: 45, color: AppColors.warning),
                        const SizedBox(height: 10),
                        Text('Unable to preview photo', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Attendance History',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Refresh',
            onPressed: _loadAttendanceHistory,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      backgroundColor: AppColors.white,
      onRefresh: _loadAttendanceHistory,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Top Summary Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildSummaryHeader(),
            ),
          ),

          // 2. Filter Pills Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildFilterChips(),
            ),
          ),

          // 3. Attendance List or Empty State
          if (_filteredList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmpty(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _filteredList[index];
                    return _buildAttendanceCard(item);
                  },
                  childCount: _filteredList.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP SUMMARY HEADER
  // ============================================================
  Widget _buildSummaryHeader() {
    final totalDays = _allAttendanceList.length;
    final completedDays = _allAttendanceList.where((a) => a.checkOutTime != null).length;
    final activeDays = _allAttendanceList.where((a) => a.checkOutTime == null).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Emp ID: $_resolvedEmpId',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: AppColors.primaryGold),
                    const SizedBox(width: 5),
                    Text(
                      'ASM Logs',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),

          // Stats 3-column row
          Row(
            children: [
              _buildStatItem('Total Shifts', '$totalDays', Icons.calendar_today_rounded),
              _buildStatDivider(),
              _buildStatItem('Completed', '$completedDays', Icons.check_circle_outline_rounded,
                  color: AppColors.leafGreen),
              _buildStatDivider(),
              _buildStatItem('Checked In', '$activeDays', Icons.timelapse_rounded,
                  color: AppColors.primaryGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color color = AppColors.white}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS ROW
  // ============================================================
  Widget _buildFilterChips() {
    return Row(
      children: [
        _buildFilterChip('ALL', 'All Records (${_allAttendanceList.length})'),
        const SizedBox(width: 8),
        _buildFilterChip('COMPLETED', 'Completed'),
        const SizedBox(width: 8),
        _buildFilterChip('CHECKED_IN', 'Checked In'),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Expanded(
      child: InkWell(
        onTap: () => _onFilterChanged(key),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.primaryGold.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE CARD
  // ============================================================
  Widget _buildAttendanceCard(AttendanceHistoryModel attendance) {
    final bool isCheckedOut = attendance.checkOutTime != null;
    final checkInImageUrl = _resolveImageUrl(attendance.checkInImage);
    final checkOutImageUrl = _resolveImageUrl(attendance.checkOutImage);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Date Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(attendance.checkInTime ?? attendance.createDate),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        _formatDayName(attendance.checkInTime ?? attendance.createDate),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(attendance.status, isCheckedOut),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: AppColors.primaryGreen.withOpacity(0.08)),
            const SizedBox(height: 14),

            // 2. Check In & Check Out Columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Check In Details
                Expanded(
                  child: _buildTimeItem(
                    icon: Icons.login_rounded,
                    title: 'CHECK IN',
                    time: _formatTime(attendance.checkInTime),
                    location: attendance.checkInLocation,
                    imageUrl: checkInImageUrl,
                    imageLabel: 'Check-In Photo',
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  height: 90,
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),

                // Check Out Details
                Expanded(
                  child: _buildTimeItem(
                    icon: Icons.logout_rounded,
                    title: 'CHECK OUT',
                    time: isCheckedOut ? _formatTime(attendance.checkOutTime) : 'In Progress',
                    location: attendance.checkOutLocation,
                    imageUrl: checkOutImageUrl,
                    imageLabel: 'Check-Out Photo',
                    isPending: !isCheckedOut,
                  ),
                ),
              ],
            ),

            // 3. Hours Worked & Territory Footer
            if (attendance.hoursWorked != null && attendance.hoursWorked!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.deepGold,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Shift Duration',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      attendance.hoursWorked!.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem({
    required IconData icon,
    required String title,
    required String time,
    String? location,
    String? imageUrl,
    required String imageLabel,
    bool isPending = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: isPending ? AppColors.warning : AppColors.primaryGreen),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isPending ? AppColors.warning : AppColors.textDark,
          ),
        ),
        if (location != null && location.trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  location.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (imageUrl != null && imageUrl.isNotEmpty) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showImagePreviewDialog(imageUrl, imageLabel),
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(String? status, bool isCheckedOut) {
    final String text = (status != null && status.trim().isNotEmpty)
        ? status.trim().toUpperCase()
        : (isCheckedOut ? 'COMPLETED' : 'CHECKED IN');

    final bool isSuccess = text.contains('COMPLET') || text.contains('PRESENT') || text.contains('FULL');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.leafGreen.withOpacity(0.12)
            : AppColors.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSuccess
              ? AppColors.leafGreen.withOpacity(0.4)
              : AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isSuccess ? AppColors.secondaryGreen : AppColors.warning,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY & ERROR STATES
  // ============================================================
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 55,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Attendance Records',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Attendance punch-ins for $_resolvedEmpId will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.warning,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load attendance',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Something went wrong while fetching data.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadAttendanceHistory,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
