import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../model/product_model.dart';
import '../service/Auth_servcie.dart';
import '../service/session_manager.dart';
import 'card_screen.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String userId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.userId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();

  late Future<ProductDetailsData?> _productDetailsFuture;
  String _effectiveUserId = '';
  int _currentPage = 0;
  bool _isAddingToCart = false;
  bool _addedToCart = false;
  bool _isBuyingNow = false;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _resolveUserIdAndLoad();
  }

  Future<void> _resolveUserIdAndLoad() async {
    _effectiveUserId = widget.userId.trim();
    if (_effectiveUserId.isEmpty) {
      final savedId = await SessionManager.getUserId();
      if (savedId != null && savedId.isNotEmpty) {
        _effectiveUserId = savedId;
      }
    }
    _fetchProductDetails();
    _fetchCartCount();
  }

  void _fetchProductDetails() {
    setState(() {
      _productDetailsFuture = _authService.getProductDetails(widget.productId);
    });
  }

  Future<void> _fetchCartCount() async {
    if (_effectiveUserId.isEmpty) return;
    try {
      final cartResult = await _authService.getCart(_effectiveUserId);
      if (cartResult['status'] == true && cartResult['data'] is List) {
        final List<dynamic> items = cartResult['data'];
        if (mounted) {
          setState(() {
            _cartCount = items.length;
          });
        }
      }
    } catch (_) {
      // Ignored
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

  Future<void> _handleAddToCart(ProductDetailsData product) async {
    if (_isAddingToCart) return;

    if (_addedToCart) {
      _navigateToCart();
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final result = await _authService.addToCart(
        userId: _effectiveUserId,
        productId: product.productId,
        qty: 1,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        setState(() {
          _addedToCart = true;
          _cartCount += 1;
        });

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
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.secondaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result['message'] ?? 'Failed to add product to cart',
                    style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Future<void> _handleBuyNow(ProductDetailsData product) async {
    if (_isBuyingNow) return;

    setState(() => _isBuyingNow = true);

    try {
      if (!_addedToCart) {
        final result = await _authService.addToCart(
          userId: _effectiveUserId,
          productId: product.productId,
          qty: 1,
        );

        if (result['status'] == true) {
          _addedToCart = true;
          _cartCount += 1;
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(userId: _effectiveUserId),
        ),
      ).then((_) {
        _fetchCartCount();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBuyingNow = false);
      }
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(userId: _effectiveUserId),
      ),
    ).then((_) {
      _fetchCartCount();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          widget.productName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            fontSize: 17,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<ProductDetailsData?>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 54, color: AppColors.error),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Failed to load product details',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchProductDetails,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('Try Again', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

          final product = snapshot.data!;
          final int discount = _calculateDiscount(product.mrp, product.sellingPrice);

          final images = [
            product.image1,
            product.image2,
            product.image3,
            product.image4,
            product.image5,
          ].where((e) => e != null && e.toString().trim().isNotEmpty).cast<String>().toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Header Section
                _buildImageCarousel(images, discount),

                const SizedBox(height: 12),

                // 2. Product Title & Price Card
                _buildProductInfoCard(product, discount),

                const SizedBox(height: 12),

                // 3. Ayurvedic Assurance Badges
                _buildTrustHighlights(),

                const SizedBox(height: 12),

                // 4. Description Section
                if (product.description != null && product.description!.trim().isNotEmpty)
                  _buildDescriptionCard(product.description!),

                const SizedBox(height: 120), // Bottom padding for sticky actions
              ],
            ),
          );
        },
      ),
      bottomSheet: FutureBuilder<ProductDetailsData?>(
        future: _productDetailsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final product = snapshot.data!;
          return _buildStickyBottomBar(product);
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images, int discount) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        color: AppColors.white,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 70, color: Colors.grey),
      );
    }

    return Container(
      color: AppColors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            height: 270,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final rawPath = images[index].startsWith('http')
                        ? images[index]
                        : "https://durvasaayurved.online${images[index]}";

                    return InteractiveViewer(
                      maxScale: 3.0,
                      child: Hero(
                        tag: 'product_image_${widget.productId}_$index',
                        child: CachedNetworkImage(
                          imageUrl: rawPath,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade200,
                              highlightColor: Colors.grey.shade50,
                              child: Container(
                                width: double.infinity,
                                height: 260,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Center(
                            child: Icon(Icons.image_not_supported_outlined, size: 70, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Discount Badge overlay
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFC62828)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: GoogleFonts.poppins(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (images.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: _currentPage == index ? 22 : 7,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primaryGreen : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(ProductDetailsData product, int discount) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag & Unit pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${product.categoryName} > ${product.subCategoryName}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (product.unit.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Unit: ${product.unit}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Product Name
          Text(
            product.productName,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 14),

          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${product.sellingPrice}',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              if (discount > 0) ...[
                Text(
                  '₹${product.mrp}',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.leafGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Save ₹${(double.tryParse(product.mrp) ?? 0) - (double.tryParse(product.sellingPrice) ?? 0)}',
                    style: GoogleFonts.poppins(
                      color: AppColors.secondaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Inclusive of all taxes',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustHighlights() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrustItem(Icons.eco_outlined, '100% Ayurvedic'),
          _buildDivider(),
          _buildTrustItem(Icons.verified_outlined, 'Lab Tested'),
          _buildDivider(),
          _buildTrustItem(Icons.local_shipping_outlined, 'Safe Delivery'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 22),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Product Details & Usage',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppColors.textDark.withOpacity(0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProductDetailsData product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  icon: _addedToCart
                      ? const Icon(Icons.arrow_forward, size: 18, color: AppColors.primaryGreen)
                      : const Icon(Icons.shopping_cart_outlined, size: 18, color: AppColors.primaryGreen),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isAddingToCart ? null : () => _handleAddToCart(product),
                  label: _isAddingToCart
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : Text(
                          _addedToCart ? "GO TO CART" : "ADD TO CART",
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Buy Now Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bolt, size: 20, color: AppColors.white),
                  label: _isBuyingNow
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : Text(
                          "BUY NOW",
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isBuyingNow ? null : () => _handleBuyNow(product),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 280, color: Colors.white),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150, height: 20, color: Colors.white),
                const SizedBox(height: 12),
                Container(width: double.infinity, height: 24, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 200, height: 24, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: 100, height: 30, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
