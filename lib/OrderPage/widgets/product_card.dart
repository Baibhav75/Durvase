import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../model/latest_product_model.dart';

class ProductCard extends StatefulWidget {
  final LatestProduct product;
  final String userId;
  final VoidCallback onTap;
  final VoidCallback? onAddedToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.userId,
    required this.onTap,
    this.onAddedToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isAdding = false;
  bool _isAdded = false;

  Future<void> _handleAddToCart() async {
    if (_isAdding || widget.userId.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      final url = Uri.parse(
        'https://durvasaayurved.online/api/AddToCart/AddToCart?ProductID=${widget.product.productId}&UserID=${widget.userId}&Qty=1',
      );

      final response = await http.post(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          if (mounted) {
            setState(() {
              _isAdding = false;
              _isAdded = true;
            });
            widget.onAddedToCart?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.product.productName} added to cart',
                        style: GoogleFonts.poppins(color: AppColors.white, fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primaryGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );

            // Reset back to + ADD after 2.5 seconds
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() => _isAdded = false);
              }
            });
          }
          return;
        }
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mrp = double.tryParse(widget.product.mrp) ?? 0;
    final selling = double.tryParse(widget.product.sellingPrice) ?? 0;
    final discount = mrp > selling ? (((mrp - selling) / mrp) * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. DEDICATED UPPER PRODUCT IMAGE CONTAINER
              // ==========================================
              Container(
                height: 125,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.product.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[50]!,
                            child: Container(color: AppColors.creamBackground),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.spa_outlined,
                              color: AppColors.primaryGreen,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Discount Tag (Top Left)
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            '$discount% OFF',
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),

                    // Rating Tag (Bottom Left of Image)
                    Positioned(
                      bottom: 6,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '4.8',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // 2. PRODUCT INFORMATION SECTION (BELOW IMAGE)
              // ==========================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            widget.product.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Unit / Weight Spec
                          Text(
                            '100% Herbal • 500ml',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Price Row + Compact Quick-Commerce ADD Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price & MRP
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (discount > 0)
                                  Text(
                                    '₹${widget.product.mrp}',
                                    style: GoogleFonts.poppins(
                                      decoration: TextDecoration.lineThrough,
                                      color: AppColors.textSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Text(
                                  '₹${widget.product.sellingPrice}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick-Commerce + ADD Pill Button
                          GestureDetector(
                            onTap: _handleAddToCart,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: _isAdded
                                    ? AppColors.primaryGreen
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryGreen,
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isAdding
                                    ? const SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isAdded ? Icons.check_rounded : Icons.add_rounded,
                                            size: 14,
                                            color: _isAdded ? AppColors.white : AppColors.primaryGreen,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            _isAdded ? 'ADDED' : 'ADD',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: _isAdded ? AppColors.white : AppColors.primaryGreen,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

