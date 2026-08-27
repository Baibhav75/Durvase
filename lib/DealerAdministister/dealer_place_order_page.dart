import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../model/Dealer_Model/dealer_login_model.dart';
import '../model/checkout_model.dart';
import '../service/api_service.dart';
import '../service/session_manager.dart';
import '../service/Dealer_service/dealer_login_service.dart';

class DealerPlaceOrderPage extends StatefulWidget {
  final DealerModel? dealer;
  final String? dealerId;
  final String? userId;

  const DealerPlaceOrderPage({
    super.key,
    this.dealer,
    this.dealerId,
    this.userId,
  });

  @override
  State<DealerPlaceOrderPage> createState() => _DealerPlaceOrderPageState();
}

class _DealerPlaceOrderPageState extends State<DealerPlaceOrderPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSubmitting = false;

  DealerModel? _effectiveDealer;
  String _effectiveDealerId = '';
  String _effectiveUserId = '';

  final List<String> _categories = [
    'All',
    'Syrup & Tonics',
    'Tablets & Vati',
    'Churna & Powders',
    'Ayurvedic Oils',
    'Immunity & Rasayan',
  ];

  final List<Map<String, dynamic>> _catalogProducts = [
    {
      'id': 'PRD-101',
      'name': 'Durvasa Liv-Care Syrup',
      'category': 'Syrup & Tonics',
      'size': '200 ml',
      'mrp': 180.0,
      'ptr': 126.0,
      'stock': 120,
      'badge': 'Bestseller',
      'points': '15',
      'image': 'https://durvasaayurved.online/assets/images/livcare.png',
      'qty': 0,
    },
    {
      'id': 'PRD-102',
      'name': 'Ashwagandha Gold Capsules',
      'category': 'Tablets & Vati',
      'size': '60 Caps',
      'mrp': 350.0,
      'ptr': 245.0,
      'stock': 85,
      'badge': 'High Demand',
      'points': '25',
      'image': 'https://durvasaayurved.online/assets/images/ashwagandha.png',
      'qty': 0,
    },
    {
      'id': 'PRD-103',
      'name': 'Durvasa Ortho Relief Oil',
      'category': 'Ayurvedic Oils',
      'size': '100 ml',
      'mrp': 220.0,
      'ptr': 154.0,
      'stock': 95,
      'badge': 'Fast Moving',
      'points': '20',
      'image': 'https://durvasaayurved.online/assets/images/ortho_oil.png',
      'qty': 0,
    },
    {
      'id': 'PRD-104',
      'name': 'Triphala Shuddha Churna',
      'category': 'Churna & Powders',
      'size': '100 gm',
      'mrp': 120.0,
      'ptr': 84.0,
      'stock': 150,
      'badge': 'Essential',
      'points': '10',
      'image': 'https://durvasaayurved.online/assets/images/triphala.png',
      'qty': 0,
    },
    {
      'id': 'PRD-105',
      'name': 'Durvasa Maha Bhringraj Taila',
      'category': 'Ayurvedic Oils',
      'size': '200 ml',
      'mrp': 290.0,
      'ptr': 203.0,
      'stock': 60,
      'badge': 'Premium',
      'points': '22',
      'image': 'https://durvasaayurved.online/assets/images/bhringraj.png',
      'qty': 0,
    },
    {
      'id': 'PRD-106',
      'name': 'Chyawanprash Special Rasayan',
      'category': 'Immunity & Rasayan',
      'size': '1 Kg',
      'mrp': 450.0,
      'ptr': 315.0,
      'stock': 40,
      'badge': 'Seasonal',
      'points': '35',
      'image': 'https://durvasaayurved.online/assets/images/chyawanprash.png',
      'qty': 0,
    },
    {
      'id': 'PRD-107',
      'name': 'Kuka Cough & Cold Syrup',
      'category': 'Syrup & Tonics',
      'size': '100 ml',
      'mrp': 110.0,
      'ptr': 77.0,
      'stock': 200,
      'badge': 'Fast Moving',
      'points': '8',
      'image': 'https://durvasaayurved.online/assets/images/cough_syrup.png',
      'qty': 0,
    },
    {
      'id': 'PRD-108',
      'name': 'Giloy Ghan Vati Tablets',
      'category': 'Tablets & Vati',
      'size': '60 Tabs',
      'mrp': 140.0,
      'ptr': 98.0,
      'stock': 110,
      'badge': 'Immunity',
      'points': '12',
      'image': 'https://durvasaayurved.online/assets/images/giloy.png',
      'qty': 0,
    },
  ];

  late List<Map<String, dynamic>> _products;

  @override
  void initState() {
    super.initState();
    _products = List<Map<String, dynamic>>.from(_catalogProducts);
    _resolveDealerSession();
  }

  Future<void> _resolveDealerSession() async {
    _effectiveDealer = widget.dealer;
    if (_effectiveDealer == null) {
      _effectiveDealer = await DealerService.getSavedDealer();
    }

    _effectiveDealerId = widget.dealerId ?? _effectiveDealer?.dealerId ?? '';
    if (_effectiveDealerId.isEmpty) {
      final savedId = await SessionManager.getUserId();
      _effectiveDealerId = savedId ?? '';
    }

    _effectiveUserId = widget.userId ?? _effectiveDealer?.dealerId ?? _effectiveDealerId;

    if (mounted) setState(() {});
  }

  int get _totalItems => _products.fold<int>(0, (sum, item) => sum + (item['qty'] as int));

  double get _totalAmount => _products.fold<double>(
        0.0,
        (sum, item) => sum + ((item['qty'] as int) * (item['ptr'] as double)),
      );

  double get _totalMrp => _products.fold<double>(
        0.0,
        (sum, item) => sum + ((item['qty'] as int) * (item['mrp'] as double)),
      );

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((item) {
      final matchesCat = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  void _updateQty(String id, int delta) {
    setState(() {
      final index = _products.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        final current = _products[index]['qty'] as int;
        final updated = (current + delta).clamp(0, _products[index]['stock'] as int);
        _products[index]['qty'] = updated;
      }
    });
  }

  void _clearCart() {
    setState(() {
      for (var p in _products) {
        p['qty'] = 0;
      }
    });
  }

  void _showOrderConfirmationSheet() {
    final selectedItems = _products.where((p) => (p['qty'] as int) > 0).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least 1 product to place order."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final addressController = TextEditingController(
      text: (_effectiveDealer?.businessAddress != null && _effectiveDealer!.businessAddress.isNotEmpty)
          ? _effectiveDealer!.businessAddress
          : "Direct Dealer Location",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
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

                    // Header
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Confirm Dealer Order",
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Partner Mapping Tag
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: AppColors.primaryGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Dealer: ${_effectiveDealer?.name ?? 'Authorized Dealer'} (${_effectiveDealerId.isNotEmpty ? _effectiveDealerId : 'Direct'})",
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
                    const SizedBox(height: 14),

                    // Selected Items List
                    Text(
                      "Order Items (${selectedItems.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: selectedItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 8),
                        itemBuilder: (_, i) {
                          final item = selectedItems[i];
                          final qty = item['qty'] as int;
                          final ptr = item['ptr'] as double;
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      "${item['id']} • Qty: $qty x ₹${ptr.toStringAsFixed(0)}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${(ptr * qty).toStringAsFixed(0)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Shipping Address Field
                    Text(
                      "Delivery Address",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addressController,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "Enter delivery address...",
                        filled: true,
                        fillColor: AppColors.creamBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryGold.withOpacity(0.4)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.creamBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total MRP", style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary)),
                              Text("₹${_totalMrp.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Dealer Net Amount", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              Text("₹${_totalAmount.toStringAsFixed(0)}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Confirm Place Order Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                await _executePlaceOrder(selectedItems, addressController.text.trim());
                              },
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        label: Text(
                          "CONFIRM & PLACE ORDER",
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _executePlaceOrder(List<Map<String, dynamic>> items, String shippingAddress) async {
    setState(() => _isSubmitting = true);

    try {
      int successCount = 0;
      String lastMessage = "";

      for (final item in items) {
        final String pid = item['id'].toString();
        final response = await ApiService.placeOrder(
          productId: pid,
          dealerId: _effectiveDealerId,
          userId: _effectiveUserId,
          shippingAddress: shippingAddress.isNotEmpty ? shippingAddress : "Dealer Location",
          paymentMode: "COD",
        );

        final bool isSuccess = response['Status'] == true || response['status'] == true || response['success'] == true;
        if (isSuccess) successCount++;
        lastMessage = response['Message']?.toString() ?? response['message']?.toString() ?? "";
      }

      if (!mounted) return;

      if (successCount > 0) {
        _clearCart();
        _showOrderSuccessDialog(lastMessage.isNotEmpty ? lastMessage : "Dealer order placed successfully!");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lastMessage.isNotEmpty ? lastMessage : "Failed to place order."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error placing order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showOrderSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 28),
            const SizedBox(width: 10),
            Text(
              "Order Successful",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            ),
          ],
        ),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text("OK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Place Order',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
        actions: [
          if (_totalItems > 0)
            TextButton(
              onPressed: _clearCart,
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(color: AppColors.primaryGold, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: "Search ayurvedic medicines, oils...",
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primaryGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // 2. Category Chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.white,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. Products List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      "No products found",
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      return _buildProductRow(item);
                    },
                  ),
          ),
        ],
      ),

      // 4. Sticky Bottom Bar
      bottomSheet: _totalItems > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$_totalItems Items Selected",
                          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        Text(
                          "₹${_totalAmount.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onPressed: _isSubmitting ? null : _showOrderConfirmationSheet,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        label: Text(
                          "Review & Place Order",
                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProductRow(Map<String, dynamic> item) {
    final qty = item['qty'] as int;
    final mrp = item['mrp'] as double;
    final ptr = item['ptr'] as double;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: qty > 0 ? AppColors.primaryGreen.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 65,
              height: 65,
              color: AppColors.creamBackground,
              child: const Icon(Icons.medication_outlined, size: 30, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${item['id']} • ${item['size']}",
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "₹${ptr.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "₹${mrp.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${item['points']} Pts",
                        style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantity Controls
          if (qty == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _updateQty(item['id'], 1),
              child: Text("ADD", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _updateQty(item['id'], -1),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.remove, size: 16, color: AppColors.primaryGreen),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      "$qty",
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
                  InkWell(
                    onTap: () => _updateQty(item['id'], 1),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
