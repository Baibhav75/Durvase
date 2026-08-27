import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../OrderPage/utils/theme_constants.dart';

import '../model/asm_doctor_model.dart';
import '../service/asm_doctor_service.dart';

class DoctorReportPage extends StatefulWidget {
  const DoctorReportPage({super.key});

  @override
  State<DoctorReportPage> createState() => _DoctorReportPageState();
}

class _DoctorReportPageState extends State<DoctorReportPage> {
  List<DoctorModel> _visitors = [];
  List<DoctorModel> _filteredVisitors = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalVisitors = 0;
  String _searchQuery = '';
  String _activeFilter = 'all'; // all, Doctor, Business, revisit

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVisitors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DoctorService.fetchDoctorVisitors();
      setState(() {
        _visitors = response.data;
        _filteredVisitors = response.data;
        _totalVisitors = response.totalVisitors ?? response.data.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load report. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<DoctorModel> result = _visitors;

    if (_activeFilter == 'revisit') {
      result = result
          .where((v) => v.reVisited?.toLowerCase() == 'yes')
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((v) {
        final haystack = [
          v.personName,
          v.businessName,
          v.mobile,
          v.district,
          v.block,
          v.id?.toString(),
        ].where((e) => e != null).join(' ').toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    setState(() => _filteredVisitors = result);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _makeCall(String? mobile) async {
    if (mobile == null || mobile.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No mobile number available', style: GoogleFonts.poppins(color: ThemeConstants.white)),
          backgroundColor: ThemeConstants.error,
        ),
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: mobile.trim());

    try {
      final launched = await launchUrl(callUri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer', style: GoogleFonts.poppins(color: ThemeConstants.white)),
            backgroundColor: ThemeConstants.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open dialer', style: GoogleFonts.poppins(color: ThemeConstants.white)),
            backgroundColor: ThemeConstants.error,
          ),
        );
      }
    }
  }

  void _showOrderDialog(DoctorModel visitor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeConstants.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF534AB7).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart, color: Color(0xFF534AB7)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ThemeConstants.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Order details',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: ThemeConstants.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                (visitor.businessName ?? visitor.personName ?? 'Unknown') + ' • ID #${visitor.id ?? "-"}',
                style: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ThemeConstants.creamBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: ThemeConstants.textSecondary, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      'No order has been placed for this visitor yet.',
                      style: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close', style: GoogleFonts.poppins(color: ThemeConstants.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVisitDialog(DoctorModel visitor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeConstants.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF854F0B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFF854F0B)),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: ThemeConstants.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Visit location',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: ThemeConstants.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                (visitor.businessName ?? visitor.personName ?? 'Unknown') + ' • ID #${visitor.id ?? "-"}',
                style: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textSecondary),
              ),
              const SizedBox(height: 16),
              if (visitor.address != null) _dialogInfoRow(Icons.home_outlined, visitor.address!),
              if (visitor.district != null) _dialogInfoRow(Icons.location_city_outlined, visitor.district!),
              if (visitor.block != null) _dialogInfoRow(Icons.map_outlined, visitor.block!),
              if (visitor.country != null) _dialogInfoRow(Icons.public, visitor.country!),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close', style: GoogleFonts.poppins(color: ThemeConstants.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: ThemeConstants.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: ThemeConstants.bodyStyle),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Doctor Visits',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: ThemeConstants.white,
          ),
        ),
        backgroundColor: ThemeConstants.primaryGreen,
        iconTheme: const IconThemeData(color: ThemeConstants.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: ThemeConstants.primaryGreen,
        onRefresh: _loadVisitors,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor:
          AlwaysStoppedAnimation<Color>(ThemeConstants.primaryGreen),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: ThemeConstants.error),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: ThemeConstants.bodyStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVisitors,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryGreen,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(color: ThemeConstants.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_visitors.isEmpty) {
      return Center(
        child: Text('No visitor records found', style: ThemeConstants.bodyStyle),
      );
    }

    return Column(
      children: [
        _buildSearchAndFilters(),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingMedium),
          padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
          decoration: ThemeConstants.luxuryGradientDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Visitors',
                style: GoogleFonts.poppins(
                  color: ThemeConstants.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_totalVisitors',
                style: GoogleFonts.poppins(
                  color: ThemeConstants.lightGold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSmall),
        Expanded(
          child: _filteredVisitors.isEmpty
              ? _buildEmptySearchState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeConstants.spacingMedium),
            itemCount: _filteredVisitors.length,
            itemBuilder: (context, index) =>
                _buildVisitorCard(_filteredVisitors[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: ThemeConstants.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            'No visits match your search.',
            style: ThemeConstants.bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacingMedium),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              _searchQuery = val;
              _applyFilters();
            },
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search name, mobile, business, ID...',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: ThemeConstants.textSecondary),
              prefixIcon:
              const Icon(Icons.search, color: ThemeConstants.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close,
                    color: ThemeConstants.textSecondary, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                },
              )
                  : null,
              filled: true,
              fillColor: ThemeConstants.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: ThemeConstants.textSecondary.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: ThemeConstants.textSecondary.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: ThemeConstants.primaryGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('all', 'All'),
                _filterChip('revisit', 'Re-visit only'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final isActive = _activeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _activeFilter = value;
          _applyFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? ThemeConstants.primaryGreen : ThemeConstants.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? ThemeConstants.primaryGreen
                  : ThemeConstants.textSecondary.withOpacity(0.25),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? ThemeConstants.white : ThemeConstants.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorCard(DoctorModel visitor) {
    final isRevisit = visitor.reVisited?.toLowerCase() == 'yes';
    final displayName = visitor.businessName ?? visitor.personName ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeConstants.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ThemeConstants.textPrimary,
                  ),
                ),
              ),
              if (isRevisit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeConstants.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ThemeConstants.success.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Re-visit',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeConstants.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: ThemeConstants.textSecondary),
                const SizedBox(width: 6),
                Text(_formatDate(visitor.visitDate), style: ThemeConstants.captionStyle),
              ]),
              Text('# ID: ${visitor.id ?? "-"}', style: ThemeConstants.captionStyle),
            ],
          ),
          const SizedBox(height: 10),
          if (visitor.personName != null) _infoRow(Icons.person_outline, visitor.personName!),
          if (visitor.mobile != null) _infoRow(Icons.phone_outlined, visitor.mobile!),
          if (visitor.visitFor != null)
            _infoRow(Icons.category_outlined, 'Type: ${visitor.visitFor}'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (visitor.district != null) _tagChip(visitor.district!),
              if (visitor.block != null) _tagChip(visitor.block!),
            ],
          ),
          if (visitor.purpose != null) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Purpose: ',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w500, color: ThemeConstants.textPrimary),
                children: [
                  TextSpan(
                    text: visitor.purpose,
                    style: GoogleFonts.poppins(fontSize: 14, color: ThemeConstants.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          if (visitor.remark != null && visitor.remark!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeConstants.creamBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remarks:',
                      style: GoogleFonts.poppins(fontSize: 12, color: ThemeConstants.textSecondary)),
                  const SizedBox(height: 2),
                  Text(visitor.remark!,
                      style: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textPrimary)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  Icons.shopping_cart,
                  'View order',
                  const Color(0xFF534AB7),
                      () => _showOrderDialog(visitor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  Icons.call,
                  'Call',
                  ThemeConstants.primaryGreen,
                      () => _makeCall(visitor.mobile),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  Icons.location_on,
                  'Visit',
                  const Color(0xFF854F0B),
                      () => _showVisitDialog(visitor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ThemeConstants.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ThemeConstants.bodyStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.primaryGreen,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ThemeConstants.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: ThemeConstants.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}