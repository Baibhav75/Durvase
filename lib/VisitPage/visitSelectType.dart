import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel1.dart';
import '../model/visit_history_model.dart';
import '../service/visit_history_service.dart';
import '/VisitPage/VisitPage.dart';
import 'NewVisitPage.dart';
import 'ReVisitpage.dart';

class VisitTypeScreen extends StatefulWidget {
  final Data1? employeeData;

  const VisitTypeScreen({super.key, this.employeeData});

  @override
  State<VisitTypeScreen> createState() => _VisitTypeScreenState();
}

class _VisitTypeScreenState extends State<VisitTypeScreen> {
  int _selectedVisitType = 0;
  final List<Map<String, dynamic>> _visitTypeOptions = [
    {
      'title': 'New Visit',
      'subtitle': 'Create a new doctor or retailer visit entry',
      'icon': Icons.add_business_rounded,
    },
    {
      'title': 'Visit History',
      'subtitle': 'Browse and search past customer visits',
      'icon': Icons.history_rounded,
    },
    {
      'title': 'Re-Visit',
      'subtitle': 'Follow up on previous client visits',
      'icon': Icons.replay_rounded,
    },
  ];

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
      String empMobile = widget.employeeData?.mobile ?? '';
      final model = await VisitHistoryService.getVisitorList(empMobile);

      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
          errorMessage = 'Failed to load today visits. Please try again.';
        });
      }
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
    await _loadTodayVisits();
  }

  // Call function
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

  // View Order function
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

  // Start Visit function
  void _startVisit(Visitors visit) {
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
              'Do you want to initiate a visit for this customer now?',
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
                      'Visit started for ${visit.personName ?? 'customer'}',
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

  void _handleVisitTypeSelection(int index, BuildContext context) {
    setState(() {
      _selectedVisitType = index;
    });

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
          employeeData: widget.employeeData,
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
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Visit Type',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Refresh',
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisitTypeSection(),
          _buildVisitListSection(),
        ],
      ),
    );
  }

  Widget _buildVisitTypeSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.touch_app_rounded, color: AppColors.primaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Choose Visit Action',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: List.generate(_visitTypeOptions.length, (index) {
                return _buildVisitTypeItem(_visitTypeOptions[index], index);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitTypeItem(Map<String, dynamic> item, int index) {
    bool isSelected = _selectedVisitType == index;
    bool isLastItem = index == _visitTypeOptions.length - 1;

    return InkWell(
      onTap: () => _handleVisitTypeSelection(index, context),
      borderRadius: BorderRadius.vertical(
        top: index == 0 ? const Radius.circular(18) : Radius.zero,
        bottom: isLastItem ? const Radius.circular(18) : Radius.zero,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.04) : Colors.transparent,
          border: isLastItem
              ? null
              : Border(bottom: BorderSide(color: AppColors.lightGold.withOpacity(0.4), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                size: 20,
                color: isSelected ? AppColors.white : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: GoogleFonts.poppins(
                      color: isSelected ? AppColors.primaryGreen : AppColors.textDark,
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  Text(
                    item['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitListSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: const Icon(Icons.today_rounded, color: AppColors.primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Today\'s Visit List',
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (todayVisits != null && todayVisits!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${todayVisits!.length} visits',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
      color: AppColors.primaryGreen,
      backgroundColor: AppColors.white,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
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
                  onPressed: () => _startVisit(visit),
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
            'Loading Today\'s Visits...',
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
              onPressed: _loadTodayVisits,
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
              'No Visits Today',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your scheduled or completed visits for today will appear here',
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