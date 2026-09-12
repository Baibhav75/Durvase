import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_order_history_model.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../service/api_service.dart';
import '../service/Retailer_service/retailer_session_manager.dart';
import '../service/session_manager.dart';
import 'retailer_place_order_page.dart';

class RetailerOrderHistoryPage extends StatefulWidget {
  final String? visiterId;
  final String? userId;
  final RetailerModel? retailer;

  const RetailerOrderHistoryPage({
    super.key,
    this.visiterId,
    this.userId,
    this.retailer,
  });

  @override
  State<RetailerOrderHistoryPage> createState() => _RetailerOrderHistoryPageState();
}

class _RetailerOrderHistoryPageState extends State<RetailerOrderHistoryPage> {
  static const Color _cardBorder = Color(0xFFE2E8E4);

  String _effectiveVisiterId = '';
  bool _isLoading = true;
  String? _errorMessage;
  List<RetailerOrderItemModel> _allOrders = [];
  List<RetailerOrderItemModel> _filteredOrders = [];

  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'COD', 'Dealer'
  final TextEditingController _searchController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndLoad() async {
    setState(() => _isLoading = true);

    // Dynamic resolution of visiter/retailer ID
    String resolvedId = widget.visiterId?.trim() ?? widget.userId?.trim() ?? '';

    if (resolvedId.isEmpty && widget.retailer != null) {
      resolvedId = widget.retailer!.visiterId.isNotEmpty
          ? widget.retailer!.visiterId
          : widget.retailer!.retailerId;
    }

    if (resolvedId.isEmpty) {
      final sessionVisiterId = await RetailerSessionManager.getVisiterId();
      if (sessionVisiterId != null && sessionVisiterId.trim().isNotEmpty) {
        resolvedId = sessionVisiterId.trim();
      }
    }

    if (resolvedId.isEmpty) {
      final centralUserId = await SessionManager.getEffectiveUserId();
      if (centralUserId.trim().isNotEmpty) {
        resolvedId = centralUserId.trim();
      }
    }

    if (resolvedId.isEmpty) {
      resolvedId = 'VTR807825'; // Safe fallback test ID
    }

    _effectiveVisiterId = resolvedId;
    await _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiService.getRetailerOrderHistory(
        idType: 'RetailerId',
        idValue: _effectiveVisiterId,
      );

      if (mounted) {
        setState(() {
          _allOrders = items;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading retailer order history: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load order history. Please check your connection.';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<RetailerOrderItemModel> list = List.from(_allOrders);

    // Apply Filter Tab
    if (_selectedFilter == 'COD') {
      list = list.where((item) => item.paymentType.toUpperCase().contains('COD')).toList();
    } else if (_selectedFilter == 'Dealer') {
      list = list.where((item) => item.routeType.toLowerCase().contains('dealer')).toList();
    }

    // Apply Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((item) {
        final nameMatch = item.productName.toLowerCase().contains(query);
        final idMatch = item.id.toString().contains(query);
        final pIdMatch = item.productId.toLowerCase().contains(query);
        final orderIdMatch = (item.orderId ?? '').toLowerCase().contains(query);
        final dealerMatch = item.dealerId.toLowerCase().contains(query);
        return nameMatch || idMatch || pIdMatch || orderIdMatch || dealerMatch;
      }).toList();
    }

    _filteredOrders = list;
  }

  double get _totalSpent => _allOrders.fold(0.0, (sum, item) => sum + item.totalAmount);
  double get _totalSavings => _allOrders.fold(0.0, (sum, item) => sum + item.totalSavings);
  int get _totalItemsCount => _allOrders.fold(0, (sum, item) => sum + item.qty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.creamBackground,
        onRefresh: _fetchOrderHistory,
        child: _isLoading
            ? _buildShimmerLoading()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'Order History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          if (_effectiveVisiterId.isNotEmpty)
            Text(
              'ID: $_effectiveVisiterId',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.lightGold,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
          tooltip: 'Refresh Orders',
          onPressed: _fetchOrderHistory,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // Top Header Banner & Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                _buildSummaryHeader(),
                const SizedBox(height: 14),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          ),
        ),

        // Section Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders (${_filteredOrders.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                if (_allOrders.isNotEmpty)
                  Text(
                    '$_totalItemsCount Items Ordered',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Orders List or Empty State
        _filteredOrders.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredOrders[index];
                      return _buildOrderCard(item, index);
                    },
                    childCount: _filteredOrders.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Order History Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold, width: 0.8),
                ),
                child: Text(
                  '${_allOrders.length} Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Spent',
                  value: currencyFormatter.format(_totalSpent),
                  icon: Icons.payments_outlined,
                  valueColor: AppColors.white,
                ),
              ),
              Container(
                width: 1,
                height: 38,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildMetricTile(
                  title: 'Total Savings',
                  value: currencyFormatter.format(_totalSavings),
                  icon: Icons.savings_outlined,
                  valueColor: AppColors.primaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.cream.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _applyFilters();
          });
        },
        style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Search by product, Order ID, Dealer...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'COD', 'Dealer'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : _cardBorder,
                  width: 1,
                ),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedFilter = filter;
                    _applyFilters();
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(RetailerOrderItemModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showOrderDetailsBottomSheet(item),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Header: Order ID & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          item.displayOrderId,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.routeType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.routeType,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _buildStatusBadge(item.displayStatus),
                ],
              ),
              const SizedBox(height: 12),

              // Product Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 76,
                      height: 76,
                      color: AppColors.creamBackground,
                      child: item.formattedImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.formattedImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.medication_outlined,
                                color: AppColors.primaryGreen,
                                size: 34,
                              ),
                            )
                          : const Icon(
                              Icons.medication_outlined,
                              color: AppColors.primaryGreen,
                              size: 34,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'ID: ${item.productId}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (item.dealerId.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• DLR: ${item.dealerId}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Selling Price
                            Text(
                              currencyFormatter.format(item.sellingPrice),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            if (item.listedPrice > item.sellingPrice) ...[
                              const SizedBox(width: 8),
                              Text(
                                currencyFormatter.format(item.listedPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.green.shade200, width: 0.6),
                                ),
                                child: Text(
                                  '${item.discountPercent}% OFF',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
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
              const SizedBox(height: 12),
              const Divider(color: _cardBorder, height: 1),
              const SizedBox(height: 10),

              // Bottom Info: Quantity, Payment Mode, Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.creamBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Qty: ${item.qty}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.paymentType.toUpperCase().contains('COD')
                              ? Colors.amber.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.paymentType.toUpperCase().contains('COD')
                                ? Colors.amber.shade300
                                : Colors.blue.shade300,
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          item.paymentType.isNotEmpty ? item.paymentType : 'COD',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: item.paymentType.toUpperCase().contains('COD')
                                ? Colors.amber.shade900
                                : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(item.totalAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.blue.shade50;
    Color fg = Colors.blue.shade800;
    Color border = Colors.blue.shade200;

    final lower = status.toLowerCase();
    if (lower.contains('deliver') || lower.contains('success') || lower.contains('confirm')) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      border = Colors.green.shade200;
    } else if (lower.contains('pending') || lower.contains('wait')) {
      bg = Colors.amber.shade50;
      fg = Colors.amber.shade800;
      border = Colors.amber.shade200;
    } else if (lower.contains('cancel') || lower.contains('reject')) {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
      border = Colors.red.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsBottomSheet(RetailerOrderItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                _buildStatusBadge(item.displayStatus),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.creamBackground,
                    child: item.formattedImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.formattedImageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.medication_outlined, color: AppColors.primaryGreen),
                          )
                        : const Icon(Icons.medication_outlined, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Product ID: ${item.productId}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _cardBorder),
            const SizedBox(height: 8),

            _buildDetailRow('Order ID', item.displayOrderId),
            _buildDetailRow('Internal ID', '${item.id}'),
            _buildDetailRow('Quantity', '${item.qty} units'),
            _buildDetailRow('Listed Price', currencyFormatter.format(item.listedPrice)),
            _buildDetailRow('Selling Price', currencyFormatter.format(item.sellingPrice)),
            if (item.totalSavings > 0)
              _buildDetailRow('Total Savings', currencyFormatter.format(item.totalSavings),
                  valueColor: Colors.green.shade700),
            _buildDetailRow('Payment Mode', item.paymentType),
            _buildDetailRow('Route Type', item.routeType),
            if (item.dealerId.isNotEmpty)
              _buildDetailRow('Dealer ID', item.dealerId),
            if (item.asmId.isNotEmpty)
              _buildDetailRow('ASM ID', item.asmId),

            const SizedBox(height: 10),
            const Divider(color: _cardBorder),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final Amount',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  currencyFormatter.format(item.totalAmount),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
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
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty ? 'No Matching Orders' : 'No Order History Yet',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try searching with a different product name or order ID'
                  : 'Your placed orders will appear here automatically with full tracking and status updates.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (_searchQuery.isNotEmpty) {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _applyFilters();
                  });
                } else if (widget.retailer != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RetailerPlaceOrderPage(retailer: widget.retailer!),
                    ),
                  );
                } else {
                  _fetchOrderHistory();
                }
              },
              icon: Icon(
                _searchQuery.isNotEmpty ? Icons.clear : Icons.shopping_bag_outlined,
                size: 18,
              ),
              label: Text(
                _searchQuery.isNotEmpty ? 'Clear Search' : 'Place New Order',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Failed to Load Orders',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred while contacting the server.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _fetchOrderHistory,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
