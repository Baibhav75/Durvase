import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../PaymentPage/payment_screen.dart';
import '../constants/app_colors.dart';
import '../model/checkout_model.dart';
import '../service/Auth_servcie.dart';
import '../service/session_manager.dart';
import '../service/api_serviceProfile.dart';

class CheckoutScreen extends StatefulWidget {
  final String userId;

  const CheckoutScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AuthService _authService = AuthService();
  late Future<CheckoutResponse?> _checkoutFuture;
  String _effectiveUserId = '';

  @override
  void initState() {
    super.initState();
    _resolveUserIdAndLoad();
  }

  Future<void> _resolveUserIdAndLoad() async {
    _checkoutFuture = _loadCheckoutData();
  }

  Future<CheckoutResponse?> _loadCheckoutData() async {
    // 1. Check if passed userId is valid
    _effectiveUserId = widget.userId.trim();

    // 2. Fallback to SessionManager stored userId
    if (_effectiveUserId.isEmpty) {
      final savedId = await SessionManager.getUserId();
      if (savedId != null && savedId.trim().isNotEmpty) {
        _effectiveUserId = savedId.trim();
      }
    }

    // 3. Fallback to SessionManager EmpId
    if (_effectiveUserId.isEmpty) {
      final empId = await SessionManager.getEmpId();
      if (empId != null && empId.trim().isNotEmpty) {
        _effectiveUserId = empId.trim();
      }
    }

    // 4. Fallback to fetching profile from API
    if (_effectiveUserId.isEmpty) {
      final loginData = await SessionManager.getLoginData();
      if (loginData != null && loginData.mobile != null && loginData.mobile!.isNotEmpty) {
        final profile = await ApiService.fetchProfile(loginData.mobile!);
        final employee = profile?.firstEmployee;
        if (employee != null && employee.userId != null && employee.userId!.isNotEmpty) {
          _effectiveUserId = employee.userId!;
        }
      }
    }

    debugPrint("Checkout Resolved Effective UserId: '$_effectiveUserId'");

    if (_effectiveUserId.isEmpty) {
      throw Exception("User session not found. Please log in again.");
    }

    final response = await _authService.getCheckout(_effectiveUserId);
    if (response == null) {
      throw Exception("Failed to load checkout details from server.");
    }
    return response;
  }

  void _retry() {
    setState(() {
      _checkoutFuture = _loadCheckoutData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          "Checkout & Review",
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
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: FutureBuilder<CheckoutResponse?>(
        future: _checkoutFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError || snapshot.data == null) {
            final errorText = snapshot.error?.toString().replaceAll("Exception: ", "") ??
                "Failed to load checkout information.";
            return _buildErrorState(errorText);
          }

          final checkout = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Delivery Details Section
                _buildSectionHeader("Delivery Address", Icons.location_on_outlined),
                const SizedBox(height: 10),
                _buildDeliveryAddressCard(checkout.user),

                const SizedBox(height: 22),

                // 2. Order Items Section
                _buildSectionHeader("Order Items (${checkout.cart.length})", Icons.shopping_bag_outlined),
                const SizedBox(height: 10),
                _buildCartItemsList(checkout.cart),

                const SizedBox(height: 22),

                // 3. Price Summary Section
                _buildSectionHeader("Payment Summary", Icons.receipt_long_outlined),
                const SizedBox(height: 10),
                _buildPriceSummaryCard(checkout.summary, checkout.isEligibleToUsePoint),

                const SizedBox(height: 16),

                // 4. Safe Checkout Assurance Banner
                _buildTrustBanner(),
              ],
            ),
          );
        },
      ),
      bottomSheet: FutureBuilder<CheckoutResponse?>(
        future: _checkoutFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final summary = snapshot.data!.summary;
          return _buildStickyBottomBar(summary.finalAmount);
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard(CheckoutUser user) {
    final hasAddress = user.permanentAddress.trim().isNotEmpty ||
        user.city.trim().isNotEmpty ||
        user.state.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin_circle_outlined, color: AppColors.primaryGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : "Valued Customer",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_iphone_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          user.mobile.isNotEmpty ? user.mobile : "Mobile not provided",
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Home",
                  style: GoogleFonts.poppins(
                    color: AppColors.secondaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            hasAddress
                ? "${user.permanentAddress}${user.permanentAddress.isNotEmpty ? ', ' : ''}${user.city}${user.city.isNotEmpty ? ', ' : ''}${user.state}"
                : "Address will be confirmed upon order dispatch",
            style: GoogleFonts.poppins(
              color: AppColors.textDark.withOpacity(0.85),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          if (user.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  user.email,
                  style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItemsList(List<CartItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            "No items in cart",
            style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final String rawImg = item.image.trim();
        final String imgUrl = rawImg.isNotEmpty
            ? (rawImg.startsWith('http') ? rawImg : 'https://durvasaayurved.online$rawImg')
            : '';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 68,
                  height: 68,
                  color: AppColors.creamBackground,
                  child: imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade200,
                            highlightColor: Colors.grey.shade50,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 32,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.creamBackground,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                          ),
                          child: Text(
                            "Qty: ${item.qty}",
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (item.productPoint.isNotEmpty && item.productPoint != '0') ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "${item.productPoint} Pts",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${item.sellingPrice.toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  if (item.listedPrice > item.sellingPrice) ...[
                    const SizedBox(height: 2),
                    Text(
                      "₹${item.listedPrice.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceSummaryCard(Summary summary, bool isEligiblePoints) {
    final double listedTotal = summary.totalListedPrice;
    final double sellingTotal = summary.totalSellingPrice;
    final double discount = summary.discount > 0
        ? summary.discount
        : ((listedTotal > sellingTotal) ? (listedTotal - sellingTotal) : 0.0);
    final double finalPayable = summary.finalAmount > 0 ? summary.finalAmount : sellingTotal;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _buildSummaryLine("Total MRP", "₹${listedTotal.toStringAsFixed(2)}"),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryLine(
              "Discount Savings",
              "- ₹${discount.toStringAsFixed(2)}",
              valueColor: AppColors.secondaryGreen,
            ),
          ],
          const SizedBox(height: 10),
          _buildSummaryLine("Delivery Charges", "FREE", valueColor: AppColors.secondaryGreen),
          if (isEligiblePoints) ...[
            const SizedBox(height: 10),
            _buildSummaryLine("Reward Points Applicable", "Yes", valueColor: AppColors.deepGold),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Final Payable Amount",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "₹${finalPayable.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Guaranteed Safe & Secure Checkout with Durvasa Ayurved.",
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

  Widget _buildStickyBottomBar(double finalAmount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
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
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                Text(
                  "₹${finalAmount.toStringAsFixed(2)}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(amount: finalAmount),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment, color: AppColors.white, size: 18),
                  label: Text(
                    "PROCEED TO PAY",
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 140, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 24),
            Container(width: 120, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
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
              "Unable to load checkout",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text("Try Again", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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