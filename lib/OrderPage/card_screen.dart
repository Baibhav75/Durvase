import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../service/Auth_servcie.dart';
import '../service/session_manager.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final String userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final AuthService _authService = AuthService();
  List<dynamic> apiCartItems = [];
  bool isLoading = true;
  String errorMessage = "";
  String _effectiveUserId = "";

  @override
  void initState() {
    super.initState();
    _initAndFetchCart();
  }

  Future<void> _initAndFetchCart() async {
    _effectiveUserId = widget.userId.trim();
    if (_effectiveUserId.isEmpty) {
      final savedId = await SessionManager.getUserId();
      if (savedId != null && savedId.isNotEmpty) {
        _effectiveUserId = savedId;
      }
    }
    await _fetchCartData();
  }

  Future<void> _fetchCartData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      if (_effectiveUserId.isNotEmpty) {
        final result = await _authService.getCart(_effectiveUserId);

        if (!mounted) return;

        if (result['status'] == true && result['data'] is List) {
          setState(() {
            apiCartItems = result['data'];
            errorMessage = "";
          });
        } else {
          setState(() {
            apiCartItems = [];
            errorMessage = result['message'] ?? 'Failed to load cart';
          });
        }
      } else {
        setState(() {
          apiCartItems = [];
          errorMessage = "User session not found. Please log in again.";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiCartItems = [];
          errorMessage = "Error loading cart: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double _parsePrice(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  int _parseQty(dynamic val) {
    if (val == null) return 1;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 1;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in apiCartItems) {
      if (item is Map) {
        final double price = _parsePrice(item["SellingPrice"] ?? item["Price"] ?? 0);
        final int qty = _parseQty(item["QTY"] ?? item["Qty"] ?? item["Quantity"] ?? 1);
        total += (price * qty);
      }
    }
    return total;
  }

  double get totalMrp {
    double total = 0.0;
    for (var item in apiCartItems) {
      if (item is Map) {
        final double mrp = _parsePrice(item["ListedPrice"] ?? item["MRP"] ?? item["SellingPrice"] ?? 0);
        final int qty = _parseQty(item["QTY"] ?? item["Qty"] ?? item["Quantity"] ?? 1);
        total += (mrp * qty);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            tooltip: 'Refresh Cart',
            onPressed: _fetchCartData,
          )
        ],
      ),
      body: isLoading
          ? _buildLoadingShimmer()
          : errorMessage.isNotEmpty && apiCartItems.isEmpty
              ? _buildErrorState()
              : apiCartItems.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchCartData,
                      color: AppColors.primaryGreen,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Cart Items Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Items in Cart (${apiCartItems.length})",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.secondaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    "100% Genuine",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.secondaryGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 2. Cart Items List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: apiCartItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = apiCartItems[index];
                                return _buildCartItemCard(item);
                              },
                            ),

                            const SizedBox(height: 16),

                            // 3. Price Details Breakdown Card
                            _buildPriceBreakdownCard(),

                            const SizedBox(height: 16),

                            // 4. Safe Delivery Assurance Banner
                            _buildAssuranceBanner(),
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: (apiCartItems.isNotEmpty && !isLoading)
          ? _buildStickyCheckoutBar()
          : null,
    );
  }

  Widget _buildCartItemCard(dynamic item) {
    final String productName = (item["ProductName"] ?? 'Product').toString();
    final double sellingPrice = _parsePrice(item["SellingPrice"] ?? item["Price"] ?? 0);
    final double listedPrice = _parsePrice(item["ListedPrice"] ?? item["MRP"] ?? 0);
    final int qty = _parseQty(item["QTY"] ?? item["Qty"] ?? item["Quantity"] ?? 1);
    final String? rawImg = item["Image"]?.toString();

    final String imgUrl = (rawImg != null && rawImg.isNotEmpty)
        ? (rawImg.startsWith('http') ? rawImg : 'https://durvasaayurved.online$rawImg')
        : '';

    final int discount = (listedPrice > sellingPrice && listedPrice > 0)
        ? (((listedPrice - sellingPrice) / listedPrice) * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 88,
              height: 88,
              color: AppColors.creamBackground,
              child: imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 36,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      size: 36,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Pricing row
                Row(
                  children: [
                    Text(
                      "₹${sellingPrice.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (listedPrice > sellingPrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        "₹${listedPrice.toStringAsFixed(0)}",
                        style: GoogleFonts.poppins(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.leafGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "$discount% OFF",
                            style: GoogleFonts.poppins(
                              color: AppColors.secondaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Quantity badge & Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.creamBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Quantity: ",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            "$qty",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Subtotal: ₹${(sellingPrice * qty).toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    final double subtotal = totalPrice;
    final double mrp = totalMrp;
    final double discount = (mrp > subtotal) ? (mrp - subtotal) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
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
            children: [
              const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                "Price Summary",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow("Total MRP", "₹${mrp.toStringAsFixed(2)}"),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              "Discount on MRP",
              "-₹${discount.toStringAsFixed(2)}",
              valueColor: AppColors.secondaryGreen,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow("Delivery Charges", "FREE", valueColor: AppColors.secondaryGreen),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "₹${subtotal.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.leafGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "You are saving ₹${discount.toStringAsFixed(2)} on this order!",
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAssuranceBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Safe & Secure Payments. 100% Authentic Ayurvedic Formulations.",
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCheckoutBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -3),
          ),
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
                  "Payable Total",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  "₹${totalPrice.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          userId: _effectiveUserId,
                        ),
                      ),
                    ).then((_) => _fetchCartData());
                  },
                  icon: const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
                  label: Text(
                    "Proceed to Checkout",
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Your Cart is Empty",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Looks like you haven't added any Ayurvedic medicines or wellness products to your cart yet.",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                "Explore Products",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
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

  Widget _buildErrorState() {
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
              "Unable to load cart",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCartData,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text("Retry", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
