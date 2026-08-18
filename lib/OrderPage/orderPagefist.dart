import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../constants/app_colors.dart';
import '../controller/banner_controller.dart';
import '../controller/latest_product_controller.dart';
import '../model/banner_model.dart';
import '../model/getcategory_model.dart';
import '../model/latest_product_model.dart';
import '../service/Auth_servcie.dart';
import 'card_screen.dart';
import 'product_screen.dart';
import 'widgets/banner_section.dart';
import 'widgets/category_section.dart';
import 'widgets/glassy_top_bar.dart';
import 'widgets/latest_products_section.dart';
import 'widgets/search_bar_section.dart';

class OrderPageFst extends StatefulWidget {
  final String userId;
  const OrderPageFst({super.key, required this.userId});

  @override
  _OrderPageFstState createState() => _OrderPageFstState();
}

class _OrderPageFstState extends State<OrderPageFst> {
  Future<List<Category>>? _categoriesFuture;
  Future<List<BannerItem>>? _bannerFuture;
  Future<List<LatestProduct>>? _latestProductsFuture;

  final BannerController _bannerController = BannerController();
  final LatestProductController _latestProductController = LatestProductController();

  int _cartItemCount = 0;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchCartCount();
  }

  Future<void> _loadData() async {
    setState(() {
      _categoriesFuture = AuthService().getCategories();
      _bannerFuture = _bannerController.fetchBanners();
      _latestProductsFuture = _latestProductController.fetchLatestProducts();
    });
    await _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    if (widget.userId.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('https://durvasaayurved.online/api/GetCart/Cart?UserId=${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> items = jsonResponse['data'];
          if (mounted) {
            setState(() {
              _cartItemCount = items.length;
            });
          }
        }
      }
    } catch (_) {
      // Ignored
    }
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(userId: widget.userId),
      ),
    ).then((_) => _fetchCartCount());
  }

  void _openCategoriesPage() {
    _categoriesFuture?.then((categories) {
      if (categories.isNotEmpty && mounted) {
        final firstCat = categories.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(
              categoryId: firstCat.catId,
              categoryName: firstCat.categoryName,
              userId: widget.userId,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Glassy Location Pill & Glassy Cart Action Bar
            GlassyTopBar(
              userId: widget.userId,
              cartCount: _cartItemCount,
              onCartTap: _openCart,
            ),

            // 2. Scrollable Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primaryGreen,
                backgroundColor: AppColors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // A. Top Hero Banner
                    SliverToBoxAdapter(
                      child: BannerSection(
                        bannerFuture: _bannerFuture,
                        onBannerTap: () {
                          // Banner action
                        },
                      ),
                    ),

                    // B. Search Bar placed just DOWN/BELOW the Banner
                    SliverToBoxAdapter(
                      child: SearchBarSection(
                        onTap: () {
                          // Open search
                        },
                      ),
                    ),

                    // C. Value Propositions / Trust Badges Bar
                    SliverToBoxAdapter(
                      child: _buildTrustBadgesRow(),
                    ),

                    // D. Shop by Category Section
                    SliverToBoxAdapter(
                      child: CategorySection(
                        categoriesFuture: _categoriesFuture,
                        userId: widget.userId,
                        onViewAllTap: _openCategoriesPage,
                      ),
                    ),

                    // E. Popular / Latest Products Grid
                    SliverToBoxAdapter(
                      child: LatestProductsSection(
                        latestProductsFuture: _latestProductsFuture,
                        userId: widget.userId,
                        onCartUpdated: _fetchCartCount,
                      ),
                    ),

                    // Extra spacing at bottom
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 24),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 3. Quick-Commerce Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTrustBadgesRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrustItem(Icons.local_shipping_outlined, 'Express Delivery'),
          _buildTrustDivider(),
          _buildTrustItem(Icons.eco_outlined, '100% Herbal'),
          _buildTrustDivider(),
          _buildTrustItem(Icons.verified_user_outlined, 'Lab Tested'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGreen),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustDivider() {
    return Container(
      height: 14,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined, 'Categories'),
              _buildNavItem(2, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Cart', badgeCount: _cartItemCount),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label, {int badgeCount = 0}) {
    final isActive = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        if (index == 1) {
          _openCategoriesPage();
          return;
        }
        if (index == 2) {
          _openCart();
          return;
        }
        setState(() => _currentNavIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? AppColors.primaryGreen : AppColors.textSecondary,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primaryGreen : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

