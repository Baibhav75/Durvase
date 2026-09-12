import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../model/product_model.dart';
import '../service/Auth_servcie.dart';
import '../service/session_manager.dart';
import 'product_details_screen.dart';
import 'card_screen.dart';

class ProductScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String userId;

  const ProductScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.userId,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final AuthService _authService = AuthService();
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  String _effectiveUserId = '';
  int _cartCount = 0;
  String? _addingProductId;
  final Set<String> _addedProductIds = {};

  @override
  void initState() {
    super.initState();
    _effectiveUserId = widget.userId.trim();
    _resolveUserAndFetch();
  }

  Future<void> _resolveUserAndFetch() async {
    if (_effectiveUserId.isEmpty) {
      _effectiveUserId = await SessionManager.getEffectiveUserId();
    }
    _fetchProducts();
    _fetchCartCount();
  }

  Future<void> _fetchCartCount() async {
    if (_effectiveUserId.isEmpty) {
      _effectiveUserId = await SessionManager.getEffectiveUserId();
    }
    if (_effectiveUserId.isEmpty) return;
    try {
      final res = await _authService.getCart(_effectiveUserId);
      if (res['status'] == true && res['data'] is List && mounted) {
        final List<dynamic> items = res['data'];
        setState(() {
          _cartCount = items.length;
          // Sync any already added product IDs from cart items
          for (final item in items) {
            if (item is Map && item['ProductID'] != null) {
              _addedProductIds.add(item['ProductID'].toString());
            }
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchProducts() async {
    final future = _authService.getProducts(widget.categoryId);
    setState(() {
      _productsFuture = future;
    });
    try {
      final products = await future;
      if (mounted) {
        setState(() {
          _allProducts = products;
          _applySearchFilter(_searchController.text);
        });
      }
    } catch (_) {}
  }

  void _applySearchFilter(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredProducts = _allProducts;
      });
    } else {
      final lower = query.trim().toLowerCase();
      setState(() {
        _filteredProducts = _allProducts.where((p) {
          final nameMatch = p.productName.toLowerCase().contains(lower);
          final unitMatch = p.unit.toLowerCase().contains(lower);
          final priceMatch = p.sellingPrice.contains(lower);
          return nameMatch || unitMatch || priceMatch;
        }).toList();
      });
    }
  }

  int _calculateDiscount(String mrpStr, String sellingStr) {
    try {
      final double mrp = double.tryParse(mrpStr) ?? 0.0;
      final double selling = double.tryParse(sellingStr) ?? 0.0;
      if (mrp > 0 && mrp > selling) {
        return (((mrp - selling) / mrp) * 100).round();
      }
    } catch (_) {}
    return 0;
  }

  Future<void> _handleAddToCart(Product product) async {
    if (_addingProductId != null) return; // Prevent concurrent requests

    setState(() {
      _addingProductId = product.productId;
    });

    try {
      if (_effectiveUserId.isEmpty) {
        _effectiveUserId = widget.userId.trim();
      }
      if (_effectiveUserId.isEmpty) {
        _effectiveUserId = await SessionManager.getEffectiveUserId();
      }

      final result = await _authService.addToCart(
        userId: _effectiveUserId,
        productId: product.productId,
        qty: 1,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        setState(() {
          _addedProductIds.add(product.productId);
          _cartCount += 1;
        });
        await _fetchCartCount();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result['message'] ?? '${product.productName} added to cart!',
                    style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondaryGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Unable to add to cart',
                    style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 12),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _addingProductId = null;
        });
      }
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          userId: _effectiveUserId.isNotEmpty ? _effectiveUserId : widget.userId,
        ),
      ),
    ).then((_) => _fetchCartCount());
  }

  void _navigateToDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          productId: product.productId,
          productName: product.productName,
          userId: _effectiveUserId.isNotEmpty ? _effectiveUserId : widget.userId,
        ),
      ),
    ).then((_) => _fetchCartCount());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.categoryName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontSize: 17,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '100% Ayurvedic Wellness',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                color: AppColors.lightGold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.white, size: 24),
                tooltip: 'View Cart',
                onPressed: _navigateToCart,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_cartCount',
                      style: GoogleFonts.poppins(
                        color: AppColors.darkGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _applySearchFilter,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.categoryName}...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _applySearchFilter('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        backgroundColor: AppColors.white,
        onRefresh: () async {
          await _fetchProducts();
          await _fetchCartCount();
        },
        child: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerGrid();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (_allProducts.isEmpty) {
              return _buildEmptyState(
                icon: Icons.spa_outlined,
                title: 'No products available',
                subtitle: 'Products under ${widget.categoryName} will appear here.',
              );
            }

            if (_filteredProducts.isEmpty) {
              return _buildEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results found',
                subtitle: 'We couldn\'t find anything matching "${_searchController.text}".',
              );
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Header Count Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        Text(
                          'Showing ${_filteredProducts.length} items',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_outlined, size: 12, color: AppColors.deepGold),
                              const SizedBox(width: 4),
                              Text(
                                'Authentic Herbs',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Products Grid
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.86,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final mrp = double.tryParse(product.mrp) ?? 0.0;
    final selling = double.tryParse(product.sellingPrice) ?? 0.0;
    final discount = _calculateDiscount(product.mrp, product.sellingPrice);
    final isAddingThis = _addingProductId == product.productId;
    final isAdded = _addedProductIds.contains(product.productId);

    final imageUrl = product.image1.startsWith('http')
        ? product.image1
        : "https://durvasaayurved.com${product.image1}";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(product),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // =========================
              // 1. IMAGE SECTION
              // =========================
              SizedBox(
                height: 115,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: product.image1.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          width: 115,
                          height: 105,
                          placeholder: (context, url) =>
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.grey.shade50,
                                child: Container(
                                  color: AppColors.creamBackground,
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                          const Icon(
                            Icons.spa_outlined,
                            color: AppColors.primaryGreen,
                            size: 34,
                          ),
                        )
                            : const Icon(
                          Icons.spa_outlined,
                          color: AppColors.primaryGreen,
                          size: 34,
                        ),
                      ),
                    ),

                    // Discount
                    if (discount > 0)
                      Positioned(
                        top: 7,
                        left: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE53935),
                                Color(0xFFC62828),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                    // Pure Herbal
                    Positioned(
                      bottom: 5,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              size: 10,
                              color: AppColors.secondaryGreen,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Pure Herbal',
                              style: GoogleFonts.poppins(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =========================
              // 2. PRODUCT DETAILS
              // =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  4,
                  8,
                  6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    SizedBox(
                      height: 30,
                      child: Text(
                        product.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.15,
                        ),
                      ),
                    ),

                    // Small gap only
                    const SizedBox(height: 3),

                    // =========================
                    // PRICE + ADD
                    // =========================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (mrp > selling)
                                Text(
                                  '₹${product.mrp}',
                                  style: GoogleFonts.poppins(
                                    decoration:
                                    TextDecoration.lineThrough,
                                    color: AppColors.textSecondary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                              Text(
                                '₹${product.sellingPrice}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ADD BUTTON
                        GestureDetector(
                          onTap: isAddingThis
                              ? null
                              : () => _handleAddToCart(product),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            height: 29,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isAdded
                                  ? AppColors.primaryGreen
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: AppColors.primaryGreen,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: isAddingThis
                                  ? const SizedBox(
                                height: 13,
                                width: 13,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                    AppColors.primaryGreen,
                                  ),
                                ),
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAdded
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 13,
                                    color: isAdded
                                        ? AppColors.white
                                        : AppColors.primaryGreen,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    isAdded
                                        ? 'ADDED'
                                        : 'ADD',
                                    style:
                                    GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w800,
                                      color: isAdded
                                          ? AppColors.white
                                          : AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.76,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 54, color: AppColors.primaryGold),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(

        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 54, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _fetchProducts();
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
