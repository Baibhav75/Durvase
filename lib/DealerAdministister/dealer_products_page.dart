import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../OrderPage/orderPagefist.dart';
import '../OrderPage/utils/theme_constants.dart';

class DealerProductsPage extends StatefulWidget {
  final String dealerId;

  const DealerProductsPage({
    super.key,
    required this.dealerId,
  });

  @override
  State<DealerProductsPage> createState() => _DealerProductsPageState();
}

class _DealerProductsPageState extends State<DealerProductsPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Syrups', 'Tablets', 'Oils & Pain', 'Churna & Powders', 'Immunity'];

  final List<Map<String, dynamic>> _products = [
    {
      'id': 'PRD-101',
      'name': 'Durvasa AyurLiv Liver Tonic',
      'category': 'Syrups',
      'pack': '200 ml Bottle',
      'mrp': 185.0,
      'dealerPrice': 115.0,
      'stock': 'In Stock (540 Units)',
      'moq': '10 Units',
      'badge': 'Best Seller',
    },
    {
      'id': 'PRD-102',
      'name': 'Durvasa OrthoGold Pain Oil',
      'category': 'Oils & Pain',
      'pack': '100 ml Roll-on',
      'mrp': 240.0,
      'dealerPrice': 150.0,
      'stock': 'In Stock (320 Units)',
      'moq': '12 Units',
      'badge': 'High Demand',
    },
    {
      'id': 'PRD-103',
      'name': 'Durvasa SugarCare Vati',
      'category': 'Tablets',
      'pack': '60 Tablets Container',
      'mrp': 320.0,
      'dealerPrice': 195.0,
      'stock': 'In Stock (210 Units)',
      'moq': '15 Units',
      'badge': 'Featured',
    },
    {
      'id': 'PRD-104',
      'name': 'Durvasa Triphala Digestive Churna',
      'category': 'Churna & Powders',
      'pack': '100 gm Pack',
      'mrp': 120.0,
      'dealerPrice': 72.0,
      'stock': 'In Stock (800 Units)',
      'moq': '20 Units',
      'badge': null,
    },
    {
      'id': 'PRD-105',
      'name': 'Durvasa Pure Chyawanprash Special',
      'category': 'Immunity',
      'pack': '1 kg Glass Jar',
      'mrp': 490.0,
      'dealerPrice': 310.0,
      'stock': 'Limited Stock (45 Units)',
      'moq': '6 Units',
      'badge': 'Seasonal Promo',
    },
    {
      'id': 'PRD-106',
      'name': 'Durvasa Kasamrit Cough Relief Syrup',
      'category': 'Syrups',
      'pack': '100 ml Bottle',
      'mrp': 110.0,
      'dealerPrice': 68.0,
      'stock': 'In Stock (410 Units)',
      'moq': '20 Units',
      'badge': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) {
      final matchesCat = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final matchesSearch = p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: ThemeConstants.creamBackground,
      appBar: AppBar(
        backgroundColor: ThemeConstants.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Catalog & Price List',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ThemeConstants.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout, color: ThemeConstants.white),
            tooltip: 'Place Bulk Order',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderPageFst(userId: widget.dealerId)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Search Bar ----
          Container(
            color: ThemeConstants.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeConstants.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search products by name or code...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: ThemeConstants.primaryGreen),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ---- Category Horizontal Filter ----
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? ThemeConstants.white : ThemeConstants.textDark,
                  ),
                  selected: isSelected,
                  selectedColor: ThemeConstants.primaryGreen,
                  backgroundColor: ThemeConstants.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // ---- Products List ----
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prod = filteredProducts[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ThemeConstants.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ThemeConstants.primaryGold.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: ThemeConstants.primaryGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.medication_liquid_outlined,
                              color: ThemeConstants.primaryGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (prod['badge'] != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ThemeConstants.primaryGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      prod['badge'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeConstants.darkGreen,
                                      ),
                                    ),
                                  ),
                                Text(
                                  prod['name'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: ThemeConstants.textDark,
                                  ),
                                ),
                                Text(
                                  'Pack: ${prod['pack']} • MOQ: ${prod['moq']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: ThemeConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MRP: ₹${prod['mrp']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Dealer: ',
                                    style: GoogleFonts.poppins(fontSize: 12, color: ThemeConstants.textSecondary),
                                  ),
                                  Text(
                                    '₹${prod['dealerPrice']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: ThemeConstants.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrderPageFst(userId: widget.dealerId)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConstants.primaryGreen,
                              foregroundColor: ThemeConstants.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: Text(
                              'Order',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
