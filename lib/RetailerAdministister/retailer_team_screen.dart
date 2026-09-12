import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../model/Retailer_model/asm_list_model.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../service/api_service.dart';

class RetailerTeamScreen extends StatefulWidget {
  final String employeeId;
  final String employeeType;

  const RetailerTeamScreen({
    super.key,
    required this.employeeId,
    required this.employeeType,
  });

  @override
  State<RetailerTeamScreen> createState() => _RetailerTeamScreenState();
}

class _RetailerTeamScreenState extends State<RetailerTeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Retailer API state
  bool _isLoadingRetailers = true;
  String? _retailerError;
  List<RetailerItem> _allRetailers = [];
  List<RetailerItem> _filteredRetailers = [];

  // ASM Live API state
  bool _isLoadingAsm = true;
  String? _asmError;
  List<AsmItem> _allAsm = [];
  List<AsmItem> _filteredAsm = [];

  // MR Sample list
  final List<Map<String, dynamic>> _mrList = [
    {
      'id': 'MR-UP-101',
      'name': 'Vikramaditya Singh',
      'role': 'Senior Medical Representative',
      'mobile': '9876543210',
      'email': 'vikram.singh@durvasa.online',
      'district': 'Lucknow',
      'state': 'Uttar Pradesh',
      'headquarters': 'Hazratganj HQ',
      'status': 'Active',
      'image': '',
    },
    {
      'id': 'MR-UP-102',
      'name': 'Rahul Verma',
      'role': 'Medical Representative',
      'mobile': '9876543211',
      'email': 'rahul.verma@durvasa.online',
      'district': 'Kanpur Nagar',
      'state': 'Uttar Pradesh',
      'headquarters': 'Civil Lines HQ',
      'status': 'Active',
      'image': '',
    },
    {
      'id': 'MR-DL-103',
      'name': 'Ankit Sharma',
      'role': 'Territory Executive (MR)',
      'mobile': '9876543212',
      'email': 'ankit.sharma@durvasa.online',
      'district': 'Central Delhi',
      'state': 'Delhi',
      'headquarters': 'Connaught Place HQ',
      'status': 'Active',
      'image': '',
    },
    {
      'id': 'MR-BH-104',
      'name': 'Saurabh Kumar',
      'role': 'Medical Representative',
      'mobile': '9876543213',
      'email': 'saurabh.kumar@durvasa.online',
      'district': 'Patna',
      'state': 'Bihar',
      'headquarters': 'Danapur HQ',
      'status': 'Active',
      'image': '',
    },
  ];

  String _statusFilter = 'ALL'; // ALL, Active, Inactive

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _searchController.addListener(_onSearchChanged);
    _loadRetailers();
    _loadAsm();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _loadAsm() async {
    setState(() {
      _isLoadingAsm = true;
      _asmError = null;
    });

    try {
      final response = await RetailerProfileService.getAsmList();

      debugPrint('========== ASM DATA ==========');

      for (final asm in response.data) {
        debugPrint('EmpId: ${asm.empId}');
        debugPrint('Name: ${asm.name}');
        debugPrint('State: ${asm.state}');
        debugPrint('District: ${asm.district}');
        debugPrint('Block: ${asm.block}');
        debugPrint('Address: ${asm.address}');
        debugPrint('Location: ${asm.displayLocation}');
        debugPrint('==============================');
      }

      if (!mounted) return;

      setState(() {
        _allAsm = response.data;
        _applyFilters();
        _isLoadingAsm = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _asmError = e.toString().replaceAll('Exception: ', '');
        _isLoadingAsm = false;
      });
    }
  }


  Future<void> _loadRetailers() async {
    setState(() {
      _isLoadingRetailers = true;
      _retailerError = null;
    });

    try {
      final response = await ApiService.getAllRetailers();
      if (!mounted) return;

      for (int i = 0; i < response.data.length; i++) {
        final r = response.data[i];
        debugPrint('🏢 Retailer [${i + 1} - ${r.visiterId ?? r.id}]: "Country": "${r.country}", "State": "${r.state}", "District": "${r.district}", "Block": "${r.block}", "Address": "${r.address}"');
      }

      setState(() {
        _allRetailers = response.data;
        _applyFilters();
        _isLoadingRetailers = false;
      });
    } catch (e) {
      try {
        final fallbackResponse = await RetailerProfileService.getAllRetailers();
        if (!mounted) return;

        for (int i = 0; i < fallbackResponse.data.length; i++) {
          final r = fallbackResponse.data[i];
          debugPrint('🏢 Retailer Fallback [${i + 1} - ${r.visiterId ?? r.id}]: "Country": "${r.country}", "State": "${r.state}", "District": "${r.district}", "Block": "${r.block}", "Address": "${r.address}"');
        }

        setState(() {
          _allRetailers = fallbackResponse.data;
          _applyFilters();
          _isLoadingRetailers = false;
        });
      } catch (err) {
        if (!mounted) return;
        setState(() {
          _retailerError = e.toString().replaceAll('Exception: ', '');
          _isLoadingRetailers = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredRetailers = _allRetailers.where((item) {
        final matchesStatus = _statusFilter == 'ALL' ||
            (_statusFilter == 'Active' && item.isActive) ||
            (_statusFilter == 'Inactive' && !item.isActive);

        final matchesQuery = query.isEmpty ||
            (item.businessName?.toLowerCase().contains(query) ?? false) ||
            (item.personName?.toLowerCase().contains(query) ?? false) ||
            (item.name?.toLowerCase().contains(query) ?? false) ||
            (item.visiterId?.toLowerCase().contains(query) ?? false) ||
            (item.mobile?.toLowerCase().contains(query) ?? false) ||
            (item.address?.toLowerCase().contains(query) ?? false) ||
            (item.district?.toLowerCase().contains(query) ?? false) ||
            (item.state?.toLowerCase().contains(query) ?? false) ||
            (item.block?.toLowerCase().contains(query) ?? false) ||
            (item.purpose?.toLowerCase().contains(query) ?? false) ||
            (item.empName?.toLowerCase().contains(query) ?? false) ||
            (item.retailerCode?.toLowerCase().contains(query) ?? false);

        return matchesStatus && matchesQuery;
      }).toList();

      _filteredAsm = _allAsm.where((asm) {
        final matchesStatus = _statusFilter == 'ALL' ||
            (_statusFilter == 'Active' && asm.isActive) ||
            (_statusFilter == 'Inactive' && !asm.isActive);

        final matchesQuery = query.isEmpty ||
            (asm.name?.toLowerCase().contains(query) ?? false) ||
            (asm.empId?.toLowerCase().contains(query) ?? false) ||
            (asm.employeeCode?.toLowerCase().contains(query) ?? false) ||
            (asm.mrId?.toLowerCase().contains(query) ?? false) ||
            (asm.mobile?.toLowerCase().contains(query) ?? false) ||
            (asm.email?.toLowerCase().contains(query) ?? false) ||
            (asm.district?.toLowerCase().contains(query) ?? false) ||
            (asm.state?.toLowerCase().contains(query) ?? false) ||
            (asm.block?.toLowerCase().contains(query) ?? false);

        return matchesStatus && matchesQuery;
      }).toList();
    });
  }

  // ============================================================
  // ACTION HELPERS (CALL, EMAIL, COPY)
  // ============================================================
  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyToClipboard(phoneNumber, 'Phone Number');
      }
    } catch (_) {
      _copyToClipboard(phoneNumber, 'Phone Number');
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final uri = Uri.parse('mailto:${email.trim()}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyToClipboard(email, 'Email Address');
      }
    } catch (_) {
      _copyToClipboard(email, 'Email Address');
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 10),
            Text(
              '$label copied to clipboard',
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showRetailerDetailsModal(RetailerItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Sheet Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, color: AppColors.primaryGold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Retailer Partner Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Banner
                    Row(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.primaryGold, width: 2),
                          ),
                          child: item.resolvedImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    item.resolvedImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.storefront_rounded,
                                      color: AppColors.primaryGreen,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.businessName?.isNotEmpty == true
                                    ? item.businessName!
                                    : (item.name ?? 'Retailer Partner'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (item.personName != null && item.personName!.isNotEmpty)
                                Text(
                                  'Contact: ${item.personName}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ID: ${item.visiterId ?? 'N/A'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  if (item.purpose != null && item.purpose!.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryGreen.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.purpose!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Contact Details Card
                    _buildModalSectionTitle(Icons.contact_phone_outlined, 'Contact & Address Details'),
                    const SizedBox(height: 8),
                    _buildModalInfoCard([
                      _buildModalRow(Icons.phone_rounded, 'Mobile', item.mobile ?? 'N/A',
                          onAction: item.mobile != null ? () => _makePhoneCall(item.mobile) : null),
                      if (item.mobileAlt != null && item.mobileAlt!.isNotEmpty)
                        _buildModalRow(Icons.phone_iphone_rounded, 'Alt Mobile', item.mobileAlt!,
                            onAction: () => _makePhoneCall(item.mobileAlt)),
                      if (item.email != null && item.email!.isNotEmpty)
                        _buildModalRow(Icons.email_outlined, 'Email', item.email!,
                            onAction: () => _sendEmail(item.email)),
                      if (item.address != null && item.address!.isNotEmpty)
                        _buildModalRow(Icons.business_outlined, 'Address', item.address!),
                      if (item.block != null && item.block!.isNotEmpty)
                        _buildModalRow(Icons.grid_view_outlined, 'Block', item.block!),
                      if (item.district != null && item.district!.isNotEmpty)
                        _buildModalRow(Icons.location_city_outlined, 'District', item.district!),
                      if (item.state != null && item.state!.isNotEmpty)
                        _buildModalRow(Icons.map_outlined, 'State', item.state!),
                      if (item.country != null && item.country!.isNotEmpty)
                        _buildModalRow(Icons.public_outlined, 'Country', item.country!),
                    ]),
                    const SizedBox(height: 14),

                    // Visit & Employee Assignment Card
                    _buildModalSectionTitle(Icons.badge_outlined, 'Visit & Assigned Employee'),
                    const SizedBox(height: 8),
                    _buildModalInfoCard([
                      if (item.empName != null && item.empName!.isNotEmpty)
                        _buildModalRow(Icons.person_outline, 'Assigned MR/ASM', item.empName!),
                      if (item.empType != null && item.empType!.isNotEmpty)
                        _buildModalRow(Icons.work_outline, 'Employee Type', item.empType!),
                      if (item.empMobile != null && item.empMobile!.isNotEmpty)
                        _buildModalRow(Icons.phone_outlined, 'Emp Mobile', item.empMobile!,
                            onAction: () => _makePhoneCall(item.empMobile)),
                      if (item.employeeId != null && item.employeeId!.isNotEmpty)
                        _buildModalRow(Icons.badge_outlined, 'Employee ID', item.employeeId!),
                      if (item.visitFor != null && item.visitFor!.isNotEmpty)
                        _buildModalRow(Icons.explore_outlined, 'Visit For', item.visitFor!),
                      if (item.visitDate != null && item.visitDate!.isNotEmpty)
                        _buildModalRow(Icons.calendar_today_outlined, 'Visit Date', item.visitDate!),
                      if (item.revisitDate != null && item.revisitDate!.isNotEmpty)
                        _buildModalRow(Icons.event_repeat_outlined, 'Revisit Date', item.revisitDate!),
                      if (item.remark != null && item.remark!.isNotEmpty)
                        _buildModalRow(Icons.notes_outlined, 'Remark', item.remark!),
                      _buildModalRow(
                        item.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                        'Status',
                        item.status ?? 'Active',
                        valueColor: item.isActive ? AppColors.leafGreen : AppColors.error,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildModalInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModalRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primaryGreen),
              ),
            ),
          ],
        ],
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
          'Our Team',
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
            onPressed: () {
              _loadRetailers();
              _loadAsm();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 3,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_rounded, size: 18),
              text: 'Retailers (${_filteredRetailers.length})',
            ),
            Tab(
              icon: const Icon(Icons.badge_outlined, size: 18),
              text: 'MR List (${_mrList.length})',
            ),
            Tab(
              icon: const Icon(Icons.military_tech_outlined, size: 18),
              text: 'ASM List (${_filteredAsm.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.white,
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Search by Name, ID, Mobile, District...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGold, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Status Filter Chips
                Row(
                  children: [
                    Text(
                      'Filter: ',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildFilterChip('ALL', 'All'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Active', 'Active'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Inactive', 'Inactive'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRetailersTab(),
                _buildMrTab(),
                _buildAsmTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _statusFilter == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = key;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB 1: RETAILERS LIST (LIVE API)
  // ============================================================
  Widget _buildRetailersTab() {
    if (_isLoadingRetailers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_retailerError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Unable to load retailers',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                _retailerError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRetailers,
                icon: const Icon(Icons.refresh_rounded),
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

    if (_filteredRetailers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 54, color: AppColors.lightGold),
              const SizedBox(height: 10),
              Text(
                'No retailers found',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              Text(
                'Try adjusting your search query or status filter.',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadRetailers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _filteredRetailers.length,
        itemBuilder: (context, index) {
          final item = _filteredRetailers[index];
          return _buildRetailerCard(item);
        },
      ),
    );
  }

  Widget _buildRetailerCard(RetailerItem item) {
    final String title = item.businessName?.isNotEmpty == true
        ? item.businessName!
        : (item.name ?? 'Retailer Partner');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showRetailerDetailsModal(item),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                ),
                child: item.resolvedImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          item.resolvedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primaryGreen,
                            size: 26,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primaryGreen,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.isActive
                                ? AppColors.leafGreen.withValues(alpha: 0.15)
                                : AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.status ?? 'Active',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.isActive ? AppColors.secondaryGreen : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.personName != null && item.personName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 12.5, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.personName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'ID: ${item.visiterId ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        if (item.purpose != null && item.purpose!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.purpose!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.empName != null && item.empName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.badge_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'MR/ASM: ${item.empName!}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Location Information: Block, District, State, Country
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (item.block != null && item.block!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.grid_view_rounded, size: 11, color: AppColors.primaryGreen),
                                const SizedBox(width: 3),
                                Text(
                                  'Block: ${item.block!.trim()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.district != null && item.district!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_city_rounded, size: 11, color: AppColors.deepGold),
                                const SizedBox(width: 3),
                                Text(
                                  'District: ${item.district!.trim()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.deepGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.state != null && item.state!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined, size: 11, color: Colors.blue.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'State: ${item.state!.trim()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.country != null && item.country!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.public_outlined, size: 11, color: Colors.purple.shade700),
                                const SizedBox(width: 3),
                                Text(
                                  'Country: ${item.country!.trim()}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Address Line
                    if (item.address != null && item.address!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.home_outlined, size: 13, color: AppColors.primaryGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark),
                                children: [
                                  TextSpan(
                                    text: 'Address: ',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  TextSpan(text: item.address!.trim()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Quick Call & Details action
              if (item.mobile != null && item.mobile!.isNotEmpty)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_rounded, size: 16, color: AppColors.primaryGreen),
                  ),
                  onPressed: () => _makePhoneCall(item.mobile),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAB 2: MEDICAL REPRESENTATIVE (MR) LIST
  // ============================================================
  Widget _buildMrTab() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _mrList.where((mr) {
      return query.isEmpty ||
          (mr['name']?.toString().toLowerCase().contains(query) ?? false) ||
          (mr['id']?.toString().toLowerCase().contains(query) ?? false) ||
          (mr['district']?.toString().toLowerCase().contains(query) ?? false) ||
          (mr['mobile']?.toString().toLowerCase().contains(query) ?? false);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final mr = filtered[index];
        return _buildTeamCard(
          name: mr['name'],
          role: mr['role'],
          id: mr['id'],
          mobile: mr['mobile'],
          email: mr['email'],
          location: '${mr['district']}, ${mr['state']}',
          badge: mr['headquarters'],
          badgeIcon: Icons.business_rounded,
          icon: Icons.person_rounded,
        );
      },
    );
  }

  // ============================================================
  // TAB 3: AREA SALES MANAGER (ASM) LIST (LIVE API)
  // ============================================================
  Widget _buildAsmTab() {
    if (_isLoadingAsm) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_asmError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load ASM Team',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _asmError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadAsm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredAsm.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_outlined, size: 54, color: AppColors.primaryGold),
              const SizedBox(height: 12),
              Text(
                _allAsm.isEmpty ? 'No ASM Team Members Found' : 'No ASM matching search/filter',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _allAsm.isEmpty
                  ? 'Area Sales Managers list from durvasaayurved.com/api/ASMlist is empty.'
                  : 'Try searching with a different name, Employee ID, or district.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: _loadAsm,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _filteredAsm.length,
        itemBuilder: (context, index) {
          final asm = _filteredAsm[index];
          return _buildAsmCard(asm);
        },
      ),
    );
  }

  Widget _buildAsmCard(AsmItem asm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showAsmDetailsModal(asm),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location + Contact Actions Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= LOCATION =================
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // State
                          if (asm.state != null && asm.state!.trim().isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.map_outlined,
                                  size: 14,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'State: ${asm.state!.trim()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          // District
                          if (asm.district != null && asm.district!.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_city_outlined,
                                  size: 14,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'District: ${asm.district!.trim()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Block
                          if (asm.block != null && asm.block!.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.grid_view_outlined,
                                  size: 14,
                                  color: AppColors.secondaryGreen,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'Block: ${asm.block!.trim()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // If all location fields are empty
                          if ((asm.state == null || asm.state!.trim().isEmpty) &&
                              (asm.district == null || asm.district!.trim().isEmpty) &&
                              (asm.block == null || asm.block!.trim().isEmpty))
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_off_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Location not available',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // ================= CONTACT BUTTONS =================
                    if (asm.mobile != null)
                      const SizedBox(),

                    if (asm.email != null)
                      const SizedBox(),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.lightGold.withValues(alpha: 0.3)),
                const SizedBox(height: 6),

                // Territory & ID Badge
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Emp ID: ${asm.displayId}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (asm.mrId != null && asm.mrId!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(
                        '• MR: ${asm.mrId}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),

                // Contact Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          asm.displayLocation,
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (asm.mobile != null && asm.mobile!.isNotEmpty)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.leafGreen.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone_rounded, size: 15, color: AppColors.leafGreen),
                            ),
                            onPressed: () => _makePhoneCall(asm.mobile),
                          ),
                        if (asm.email != null && asm.email!.isNotEmpty)
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.email_outlined, size: 15, color: AppColors.primaryGreen),
                            ),
                            onPressed: () => _sendEmail(asm.email),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAsmDetailsModal(AsmItem asm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Sheet Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.military_tech_rounded, color: AppColors.primaryGold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'ASM Executive Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Banner
                    Row(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.primaryGold, width: 2),
                          ),
                          child: asm.resolvedImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    asm.resolvedImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.military_tech_rounded,
                                      color: AppColors.primaryGreen,
                                      size: 32,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.military_tech_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asm.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                asm.employeeType ?? 'Area Sales Manager (ASM)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Detail rows
                    _buildModalInfoCard([
                      _buildModalRow(Icons.badge_outlined, 'Employee ID', asm.displayId),
                      if (asm.mrId != null && asm.mrId!.isNotEmpty)
                        _buildModalRow(Icons.pin_outlined, 'MR ID', asm.mrId!),
                      if (asm.employeeCode != null && asm.employeeCode!.isNotEmpty)
                        _buildModalRow(Icons.qr_code_2_rounded, 'Employee Code', asm.employeeCode!),
                      if (asm.mobile != null && asm.mobile!.isNotEmpty)
                        _buildModalRow(Icons.phone_rounded, 'Mobile', asm.mobile!,
                            onAction: () => _makePhoneCall(asm.mobile)),
                      if (asm.mobileAlt != null && asm.mobileAlt!.isNotEmpty)
                        _buildModalRow(Icons.phone_iphone_rounded, 'Alt Mobile', asm.mobileAlt!,
                            onAction: () => _makePhoneCall(asm.mobileAlt)),
                      if (asm.email != null && asm.email!.isNotEmpty)
                        _buildModalRow(Icons.email_outlined, 'Email', asm.email!,
                            onAction: () => _sendEmail(asm.email)),
                      if (asm.gender != null && asm.gender!.isNotEmpty)
                        _buildModalRow(Icons.person_outline, 'Gender', asm.gender!),
                      if (asm.fatherName != null && asm.fatherName!.isNotEmpty)
                        _buildModalRow(Icons.family_restroom, 'Father Name', asm.fatherName!),
                      _buildModalRow(Icons.location_on_outlined, 'Territory', asm.displayLocation),
                      if (asm.block != null && asm.block!.isNotEmpty)
                        _buildModalRow(Icons.map_outlined, 'Block', asm.block!),
                      if (asm.address != null && asm.address!.isNotEmpty)
                        _buildModalRow(Icons.home_work_outlined, 'Address', asm.address!),
                      if (asm.joinDate != null && asm.joinDate!.isNotEmpty)
                        _buildModalRow(Icons.calendar_today_outlined, 'Join Date', asm.joinDate!),
                      _buildModalRow(
                        asm.isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                        'Status',
                        asm.status ?? (asm.isActive ? 'Active' : 'Inactive'),
                        valueColor: asm.isActive ? AppColors.leafGreen : AppColors.error,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard({
    required String name,
    required String role,
    required String id,
    required String mobile,
    required String email,
    required String location,
    required String badge,
    required IconData badgeIcon,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      role,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  id,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.lightGold.withValues(alpha: 0.3)),
          const SizedBox(height: 6),

          // Territory Badge
          Row(
            children: [
              Icon(badgeIcon, size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Contact Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.leafGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_rounded, size: 15, color: AppColors.leafGreen),
                    ),
                    onPressed: () => _makePhoneCall(mobile),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email_outlined, size: 15, color: AppColors.primaryGreen),
                    ),
                    onPressed: () => _sendEmail(email),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
