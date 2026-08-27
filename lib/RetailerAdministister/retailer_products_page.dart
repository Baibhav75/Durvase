import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerProductsPage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerProductsPage({super.key, required this.retailer});

  @override
  State<RetailerProductsPage> createState() => _RetailerProductsPageState();
}

class _RetailerProductsPageState extends State<RetailerProductsPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Digestive Care',
    'Joint & Pain Care',
    'Immunity & Vitality',
    'Hair & Skin',
    'Classical Formulations',
  ];

  final List<Map<String, dynamic>> _products = const [
    {
      'name': 'Durvasa Liv-Care Syrup',
      'category': 'Digestive Care',
      'pack': '200 ml Bottle',
      'mrp': 180.0,
      'ptr': 126.0,
      'margin': '30%',
      'stock': 'In Stock (120 pcs)',
      'ingredients': 'Bhumi Amla, Punarnava, Kutki, Kalmegh',
      'indication': 'Liver protection, loss of appetite, fatty liver',
    },
    {
      'name': 'Ashwagandha Gold Capsules',
      'category': 'Immunity & Vitality',
      'pack': '60 Capsules Bottle',
      'mrp': 350.0,
      'ptr': 245.0,
      'margin': '30%',
      'stock': 'In Stock (85 pcs)',
      'ingredients': 'Pure Shuddha Ashwagandha Root Extract (500mg)',
      'indication': 'Stress relief, vitality, stamina, restorative tonic',
    },
    {
      'name': 'Durvasa Ortho Relief Oil',
      'category': 'Joint & Pain Care',
      'pack': '100 ml Glass Bottle',
      'mrp': 220.0,
      'ptr': 154.0,
      'margin': '30%',
      'stock': 'In Stock (95 pcs)',
      'ingredients': 'Gandhapura, Mahanarayan Taila, Nilgiri, Kapoor',
      'indication': 'Joint pain, arthritis, muscle stiffness, back pain',
    },
    {
      'name': 'Triphala Shuddha Churna',
      'category': 'Digestive Care',
      'pack': '100 gm Pack',
      'mrp': 120.0,
      'ptr': 84.0,
      'margin': '30%',
      'stock': 'In Stock (150 pcs)',
      'ingredients': 'Amla, Haritaki, Bibhitaki in equal ratio',
      'indication': 'Constipation, digestion support, colon cleansing',
    },
    {
      'name': 'Durvasa Maha Bhringraj Taila',
      'category': 'Hair & Skin',
      'pack': '200 ml Bottle',
      'mrp': 290.0,
      'ptr': 203.0,
      'margin': '30%',
      'stock': 'In Stock (60 pcs)',
      'ingredients': 'Bhringraj, Manjistha, Padmaka, Lodhra, Sesame Oil',
      'indication': 'Hair fall control, premature greying, scalp nourishment',
    },
    {
      'name': 'Chyawanprash Special Rasayan',
      'category': 'Immunity & Vitality',
      'pack': '1 Kg Jar',
      'mrp': 450.0,
      'ptr': 315.0,
      'margin': '30%',
      'stock': 'In Stock (40 pcs)',
      'ingredients': 'Fresh Amla, Kesar, Pipali, Cardamom, 42 Herbs',
      'indication': 'All-season immunity, respiratory health, stamina',
    },
    {
      'name': 'Giloy Ghan Vati Tablets',
      'category': 'Classical Formulations',
      'pack': '60 Tablets Container',
      'mrp': 140.0,
      'ptr': 98.0,
      'margin': '30%',
      'stock': 'In Stock (110 pcs)',
      'ingredients': 'Guduchi (Tinospora cordifolia) Ghan Satva',
      'indication': 'Chronic fever, immunity booster, blood purifier',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _products.where((p) {
      final matchesCat = _selectedCategory == 'All' || p['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['ingredients'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  void _showProductDetails(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.spa_rounded, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p['name'],
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pack Size: ${p['pack']}  •  ${p['category']}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 18),
            Text('Key Ingredients:',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(p['ingredients'], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Text('Therapeutic Indications:',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(p['indication'], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Retailer PTR: ₹${p['ptr']}',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                Text('MRP: ₹${p['mrp']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Margin: ${p['margin']}',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.deepGold)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Close', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

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
          'Products & Formulations',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: AppColors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or herb...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: AppColors.creamBackground,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                      final c = _categories[index];
                      final isSelected = c == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = c),
                        child: Container(
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
                              c,
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = list[index];
                return InkWell(
                  onTap: () => _showProductDetails(p),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.35)),
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
                          child: const Icon(Icons.spa_rounded, color: AppColors.primaryGreen, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'],
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              Text(
                                '${p['pack']} • ${p['category']}',
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'PTR: ₹${p['ptr']}',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MRP: ₹${p['mrp']}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${p['margin']} Margin)',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.deepGold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen),
                      ],
                    ),
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
