import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerPlaceOrderPage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerPlaceOrderPage({super.key, required this.retailer});

  @override
  State<RetailerPlaceOrderPage> createState() => _RetailerPlaceOrderPageState();
}

class _RetailerPlaceOrderPageState extends State<RetailerPlaceOrderPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

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
      'qty': 0,
    },
  ];

  late List<Map<String, dynamic>> _products;

  @override
  void initState() {
    super.initState();
    _products = List<Map<String, dynamic>>.from(_catalogProducts);
  }

  int get _totalItems => _products.fold<int>(0, (sum, item) => sum + (item['qty'] as int));

  double get _totalAmount => _products.fold<double>(
        0.0,
        (sum, item) => sum + ((item['qty'] as int) * (item['ptr'] as double)),
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

  void _showOrderSuccessDialog() {
    final orderId = 'ORD-2026-${(1000 + DateTime.now().millisecond)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 52),
              ),
              const SizedBox(height: 16),
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: $orderId',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepGold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Total Amount: ₹${_totalAmount.toStringAsFixed(2)} ($_totalItems items)\nYour ASM has been notified for dispatch.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      for (var item in _products) {
                        item['qty'] = 0;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Place Wholesale Order',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search Ayurvedic medicine, syrup, oil...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 22),
                    filled: true,
                    fillColor: AppColors.creamBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGold : AppColors.lightGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppColors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No products found matching "$_searchQuery"',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final qty = item['qty'] as int;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: qty > 0 ? AppColors.primaryGold : AppColors.lightGold.withValues(alpha: 0.3),
                            width: qty > 0 ? 1.4 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.medication_rounded, color: AppColors.primaryGreen, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item['badge'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.deepGold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pack: ${item['size']}  •  Stock: ${item['stock']} pcs',
                                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'PTR: ₹${item['ptr']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'MRP: ₹${item['mrp']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          decoration: TextDecoration.lineThrough,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Qty Selector
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.creamBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16, color: AppColors.textDark),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    onPressed: qty > 0 ? () => setState(() => item['qty'] = qty - 1) : null,
                                  ),
                                  Text(
                                    '$qty',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: qty > 0 ? AppColors.primaryGreen : AppColors.textDark,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryGreen),
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => setState(() => item['qty'] = qty + 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Order Bar
          if (_totalItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_totalItems Items Selected',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          '₹${_totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _showOrderSuccessDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_bag_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Place Order',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
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
    );
  }
}
