import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../service/Retailer_service/retailer_profile_service.dart';

class RetailerTeamScreen extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerTeamScreen({
    super.key,
    required this.retailer,
  });

  @override
  State<RetailerTeamScreen> createState() => _RetailerTeamScreenState();
}

class _RetailerTeamScreenState extends State<RetailerTeamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingRetailers = true;
  String? _retailerError;
  List<RetailerItem> _allRetailers = [];
  List<RetailerItem> _filteredRetailers = [];

  // MR & ASM Sample/Live lists
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

  final List<Map<String, dynamic>> _asmList = [
    {
      'id': 'ASM-UP-001',
      'name': 'Rajeshwar Nath Shukla',
      'role': 'Area Sales Manager (ASM)',
      'mobile': '9415012345',
      'email': 'rajeshwar.asm@durvasa.online',
      'district': 'Lucknow & Eastern UP',
      'state': 'Uttar Pradesh',
      'assignedDistricts': 'Lucknow, Kanpur, Ayodhya, Varanasi',
      'status': 'Active',
      'image': '',
    },
    {
      'id': 'ASM-DL-002',
      'name': 'Pradeep Kumar Mittal',
      'role': 'Area Sales Manager (ASM)',
      'mobile': '9811098765',
      'email': 'pradeep.mittal@durvasa.online',
      'district': 'Delhi NCR Region',
      'state': 'Delhi',
      'assignedDistricts': 'North, South & Central Delhi, Noida, Ghaziabad',
      'status': 'Active',
      'image': '',
    },
    {
      'id': 'ASM-BH-003',
      'name': 'Deepak Kumar Jha',
      'role': 'Area Sales Manager (ASM)',
      'mobile': '9934054321',
      'email': 'deepak.jha@durvasa.online',
      'district': 'Bihar State Region',
      'state': 'Bihar',
      'assignedDistricts': 'Patna, Gaya, Muzaffarpur, Bhagalpur',
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRetailers() async {
    setState(() {
      _isLoadingRetailers = true;
      _retailerError = null;
    });

    try {
      final response = await RetailerProfileService.getAllRetailers();
      if (!mounted) return;

      setState(() {
        _allRetailers = response.data;
        _applyFilters();
        _isLoadingRetailers = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _retailerError = e.toString().replaceAll('Exception: ', '');
        _isLoadingRetailers = false;
      });
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
            (item.name?.toLowerCase().contains(query) ?? false) ||
            (item.retailerId?.toLowerCase().contains(query) ?? false) ||
            (item.mobile?.toLowerCase().contains(query) ?? false) ||
            (item.district?.toLowerCase().contains(query) ?? false) ||
            (item.state?.toLowerCase().contains(query) ?? false) ||
            (item.retailerCode?.toLowerCase().contains(query) ?? false);

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
                                item.name ?? 'Retailer Partner',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'ID: ${item.retailerId ?? 'N/A'}',
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
                      _buildModalRow(Icons.phone_rounded, 'Mobile', item.mobile ?? 'N/A',
                          onAction: item.mobile != null ? () => _makePhoneCall(item.mobile) : null),
                      if (item.mobileAlt != null && item.mobileAlt!.isNotEmpty)
                        _buildModalRow(Icons.phone_iphone_rounded, 'Alt Mobile', item.mobileAlt!,
                            onAction: () => _makePhoneCall(item.mobileAlt)),
                      if (item.email != null && item.email!.isNotEmpty)
                        _buildModalRow(Icons.email_outlined, 'Email', item.email!,
                            onAction: () => _sendEmail(item.email)),
                      if (item.billedGroup != null && item.billedGroup!.isNotEmpty)
                        _buildModalRow(Icons.category_outlined, 'Billed Group', item.billedGroup!),
                      _buildModalRow(Icons.location_on_outlined, 'Territory', item.displayLocation),
                      if (item.address != null && item.address!.isNotEmpty)
                        _buildModalRow(Icons.business_outlined, 'Address', item.address!),
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
            onPressed: _loadRetailers,
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
              text: 'ASM List (${_asmList.length})',
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
                            item.name ?? 'Retailer Partner',
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
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${item.retailerId ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.displayLocation.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.displayLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
  // TAB 3: AREA SALES MANAGER (ASM) LIST
  // ============================================================
  Widget _buildAsmTab() {
    final query = _searchController.text.trim().toLowerCase();

    final filtered = _asmList.where((asm) {
      return query.isEmpty ||
          (asm['name']?.toString().toLowerCase().contains(query) ?? false) ||
          (asm['id']?.toString().toLowerCase().contains(query) ?? false) ||
          (asm['district']?.toString().toLowerCase().contains(query) ?? false) ||
          (asm['mobile']?.toString().toLowerCase().contains(query) ?? false);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final asm = filtered[index];
        return _buildTeamCard(
          name: asm['name'],
          role: asm['role'],
          id: asm['id'],
          mobile: asm['mobile'],
          email: asm['email'],
          location: '${asm['district']}, ${asm['state']}',
          badge: asm['assignedDistricts'],
          badgeIcon: Icons.map_rounded,
          icon: Icons.military_tech_rounded,
        );
      },
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
