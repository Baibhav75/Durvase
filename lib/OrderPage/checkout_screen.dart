import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../PaymentPage/payment_screen.dart';
import '../constants/app_colors.dart';
import '../model/checkout_model.dart';
import '../model/Dealer_Model/dealer_profile_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../service/Auth_servcie.dart';
import '../service/Dealer_service/dealer_profile_service.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../service/session_manager.dart';
import '../service/api_serviceProfile.dart';
import '../service/api_service.dart' as order_api;

enum CheckoutPartnerType { direct, retailer, dealer }

class CheckoutScreen extends StatefulWidget {
  final String userId;
  final List<dynamic>? cartItems;
  final double? subtotal;
  final double? totalMrp;

  const CheckoutScreen({
    super.key,
    required this.userId,
    this.cartItems,
    this.subtotal,
    this.totalMrp,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AuthService _authService = AuthService();
  late Future<CheckoutResponse?> _checkoutFuture;
  String _effectiveUserId = '';

  CheckoutPartnerType? _selectedPartnerType;
  RetailerItem? _selectedRetailer;
  DealerProfileModel? _selectedDealer;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _resolveUserIdAndLoad();
  }

  void _resolveUserIdAndLoad() {
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

    // 4. Fetch user profile for delivery address & customer info
    CheckoutUser resolvedUser = CheckoutUser(
      fullName: "Valued Customer",
      mobile: "",
      email: "",
      permanentAddress: "",
      city: "",
      state: "",
    );

    try {
      final loginData = await SessionManager.getLoginData();
      if (loginData != null && loginData.mobile != null && loginData.mobile!.isNotEmpty) {
        final profile = await ApiService.fetchProfile(loginData.mobile!);
        final employee = profile?.firstEmployee;
        if (employee != null) {
          if (_effectiveUserId.isEmpty && employee.userId != null && employee.userId!.isNotEmpty) {
            _effectiveUserId = employee.userId!;
          }
          resolvedUser = CheckoutUser(
            fullName: employee.name ?? "Valued Customer",
            mobile: employee.mobile ?? loginData.mobile ?? "",
            email: employee.email ?? "",
            permanentAddress: employee.address ?? "",
            city: employee.district ?? employee.postOffice ?? "",
            state: employee.state ?? "",
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile for checkout: $e");
    }

    debugPrint("Checkout Resolved Effective UserId: '$_effectiveUserId'");

    // A. Check if cart items were directly passed from CartScreen
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      final items = widget.cartItems!.map((e) {
        if (e is CartItem) return e;
        if (e is Map<String, dynamic>) return CartItem.fromJson(e);
        if (e is Map) return CartItem.fromJson(Map<String, dynamic>.from(e));
        return null;
      }).whereType<CartItem>().toList();

      if (items.isNotEmpty) {
        return CheckoutResponse.fromCartItemsAndUser(
          cartItems: items,
          user: resolvedUser,
          subtotal: widget.subtotal,
          totalMrp: widget.totalMrp,
        );
      }
    }

    // B. If not passed directly, try getCheckout API
    if (_effectiveUserId.isNotEmpty) {
      try {
        final response = await _authService.getCheckout(_effectiveUserId);
        if (response != null && response.cart.isNotEmpty) {
          final finalUser = (response.user.permanentAddress.isEmpty && resolvedUser.permanentAddress.isNotEmpty)
              ? resolvedUser
              : response.user;
          return CheckoutResponse(
            status: response.status,
            message: response.message,
            user: finalUser,
            cart: response.cart,
            summary: response.summary,
            isEligibleToUsePoint: response.isEligibleToUsePoint,
          );
        }
      } catch (e) {
        debugPrint("getCheckout API error: $e");
      }

      // C. Fallback: try getCart API
      try {
        final cartResult = await _authService.getCart(_effectiveUserId);
        if (cartResult['status'] == true && cartResult['data'] is List && (cartResult['data'] as List).isNotEmpty) {
          final items = (cartResult['data'] as List).map((e) {
            if (e is Map<String, dynamic>) return CartItem.fromJson(e);
            if (e is Map) return CartItem.fromJson(Map<String, dynamic>.from(e));
            return null;
          }).whereType<CartItem>().toList();
          // ✅ ADD THESE LINES
          for (final item in items) {
            debugPrint("🆔 CHECKOUT PRODUCT ID: ${item.productID}");
          }

          if (items.isNotEmpty) {
            return CheckoutResponse.fromCartItemsAndUser(
              cartItems: items,
              user: resolvedUser,
              subtotal: widget.subtotal,
              totalMrp: widget.totalMrp,
            );
          }

          if (items.isNotEmpty) {
            return CheckoutResponse.fromCartItemsAndUser(
              cartItems: items,
              user: resolvedUser,
            );
          }
        }
      } catch (e) {
        debugPrint("getCart fallback error: $e");
      }
    }

    if (_effectiveUserId.isEmpty) {
      throw Exception("User session not found. Please log in again.");
    }

    throw Exception("No items found in cart for checkout.");
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
                // 1. Partner Selection Section (Dealer / Retailer Choose Option)
                _buildSectionHeader("Select Partner (Dealer / Retailer)", Icons.handshake_outlined),
                const SizedBox(height: 10),
                _buildPartnerSelectionCard(),

                const SizedBox(height: 22),

                // 2. Delivery Details Section
                _buildSectionHeader("Delivery Address", Icons.location_on_outlined),
                const SizedBox(height: 10),
                _buildDeliveryAddressCard(checkout.user),

                const SizedBox(height: 22),

                // 3. Order Items Section
                _buildSectionHeader("Order Items (${checkout.cart.length})", Icons.shopping_bag_outlined),
                const SizedBox(height: 10),
                _buildCartItemsList(checkout.cart),

                const SizedBox(height: 22),

                // 4. Price Summary Section
                _buildSectionHeader("Payment Summary", Icons.receipt_long_outlined),
                const SizedBox(height: 10),
                _buildPriceSummaryCard(checkout.summary, checkout.isEligibleToUsePoint),

                const SizedBox(height: 16),

                // 5. Safe Checkout Assurance Banner
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
          final checkout = snapshot.data!;
          return _buildStickyBottomBar(checkout);
        },
      ),
    );
  }

  // ============================================================
  // PARTNER SELECTION WIDGETS (DEALER & RETAILER CHOOSE OPTION)
  // ============================================================
  Widget _buildPartnerSelectionCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Map this order to a partner channel:",
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Option Selector Chips
          Row(
            children: [
              Expanded(
                child: _buildPartnerTypeChip(
                  type: CheckoutPartnerType.direct,
                  title: "Direct",
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPartnerTypeChip(
                  type: CheckoutPartnerType.retailer,
                  title: "Retailer",
                  icon: Icons.storefront_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPartnerTypeChip(
                  type: CheckoutPartnerType.dealer,
                  title: "Dealer",
                  icon: Icons.business_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Partner Card based on selection
          if (_selectedPartnerType == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 18, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Please choose a partner channel above (Direct, Retailer, or Dealer).",
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedPartnerType == CheckoutPartnerType.direct)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Direct order. No dealer or retailer partner mapped.",
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textDark.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_selectedPartnerType == CheckoutPartnerType.retailer)
            _buildSelectedRetailerSection()
          else if (_selectedPartnerType == CheckoutPartnerType.dealer)
            _buildSelectedDealerSection(),
        ],
      ),
    );
  }

  Widget _buildPartnerTypeChip({
    required CheckoutPartnerType type,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPartnerType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPartnerType = type;
          if (type == CheckoutPartnerType.retailer && _selectedRetailer == null) {
            _showRetailerSelectionSheet();
          } else if (type == CheckoutPartnerType.dealer && _selectedDealer == null) {
            _showDealerSelectionSheet();
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.6),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRetailerSection() {
    if (_selectedRetailer == null) {
      return InkWell(
        onTap: _showRetailerSelectionSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold,
              style: BorderStyle.solid,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                "Choose Retailer Partner",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final retailer = _selectedRetailer!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retailer.name ?? "Retailer Partner",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      "ID: ${retailer.retailerId ?? 'N/A'} • ${retailer.mobile ?? ''}",
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showRetailerSelectionSheet,
                icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primaryGreen),
                label: Text(
                  "Change",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (retailer.displayLocation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Territory: ${retailer.displayLocation}",
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDealerSection() {
    if (_selectedDealer == null) {
      return InkWell(
        onTap: _showDealerSelectionSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold,
              style: BorderStyle.solid,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                "Choose Dealer Partner",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dealer = _selectedDealer!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, size: 18, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dealer.name ?? "Authorized Dealer",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      "ID: ${dealer.dealerId ?? 'N/A'} • ${dealer.phone ?? ''}",
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showDealerSelectionSheet,
                icon: const Icon(Icons.swap_horiz, size: 16, color: AppColors.primaryGreen),
                label: Text(
                  "Change",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (dealer.businessAddress != null && dealer.businessAddress!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              "Address: ${dealer.businessAddress}",
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // RETAILER LIST MODAL SELECTION SHEET
  // ============================================================
  void _showRetailerSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return _RetailerSelectionModalBody(
              selectedRetailerId: _selectedRetailer?.retailerId,
              onSelected: (retailer) {
                setState(() {
                  _selectedRetailer = retailer;
                  _selectedPartnerType = CheckoutPartnerType.retailer;
                });
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DEALER LIST MODAL SELECTION SHEET
  // ============================================================
  void _showDealerSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return _DealerSelectionModalBody(
              selectedDealerId: _selectedDealer?.dealerId,
              onSelected: (dealer) {
                setState(() {
                  _selectedDealer = dealer;
                  _selectedPartnerType = CheckoutPartnerType.dealer;
                });
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
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
                    if (item.productID.isNotEmpty || item.id > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        "Product ID: ${item.productID.isNotEmpty ? item.productID : item.id}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                    "₹${(item.sellingPrice * (item.qty > 0 ? item.qty : 1)).toStringAsFixed(0)}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  if (item.listedPrice > item.sellingPrice) ...[
                    const SizedBox(height: 2),
                    Text(
                      "₹${(item.listedPrice * (item.qty > 0 ? item.qty : 1)).toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (item.qty > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      "₹${item.sellingPrice.toStringAsFixed(0)} / item",
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
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

  Widget _buildStickyBottomBar(CheckoutResponse checkout) {
    final double finalAmount = checkout.summary.finalAmount;
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
                  onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(checkout),
                  icon: _isPlacingOrder
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, color: AppColors.white, size: 18),
                  label: Text(
                    _isPlacingOrder ? "PLACING ORDER..." : "PLACE ORDER",
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

  Future<void> _handlePlaceOrder(CheckoutResponse checkout) async {
    if (_isPlacingOrder) return;

    if (checkout.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No items in cart to place order."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPartnerType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Please choose a partner channel (Direct, Retailer, or Dealer) to continue.",
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_selectedPartnerType == CheckoutPartnerType.retailer && _selectedRetailer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Retailer Partner first."),
          backgroundColor: Colors.orange,
        ),
      );
      _showRetailerSelectionSheet();
      return;
    }

    if (_selectedPartnerType == CheckoutPartnerType.dealer && _selectedDealer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a Dealer Partner first."),
          backgroundColor: Colors.orange,
        ),
      );
      _showDealerSelectionSheet();
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final String retailerId = (_selectedPartnerType == CheckoutPartnerType.retailer)
          ? (_selectedRetailer?.retailerId ?? "")
          : "";

      final String dealerId = (_selectedPartnerType == CheckoutPartnerType.dealer)
          ? (_selectedDealer?.dealerId ?? "")
          : "";

      final List<String> addressParts = [
        checkout.user.permanentAddress,
        checkout.user.city,
        checkout.user.state,
      ].where((s) => s.trim().isNotEmpty).toList();

      final String shippingAddress = addressParts.isNotEmpty
          ? addressParts.join(", ")
          : "Delivery Address";

      int successCount = 0;
      String lastMessage = "";

      for (final item in checkout.cart) {
        final String pid = item.productID.isNotEmpty
            ? item.productID
            : (item.uniqueID.isNotEmpty ? item.uniqueID : item.id.toString());

        debugPrint("========================================");
        debugPrint("📦 PLACING ORDER FOR ITEM");
        debugPrint("ProductID: $pid");
        debugPrint("RetailerId: $retailerId");
        debugPrint("DealerId: $dealerId");
        debugPrint("UserId: $_effectiveUserId");
        debugPrint("ShippingAddress: $shippingAddress");
        debugPrint("========================================");

        final response = await order_api.ApiService.placeOrder(
          productId: pid,
          retailerId: retailerId,
          dealerId: dealerId,
          userId: _effectiveUserId,
          shippingAddress: shippingAddress,
          paymentMode: "COD",
        );

        final bool isSuccess = response['Status'] == true ||
            response['status'] == true ||
            response['success'] == true;

        if (isSuccess) {
          successCount++;
        }

        lastMessage = response['Message']?.toString() ??
            response['message']?.toString() ??
            "";
      }

      if (!mounted) return;

      if (successCount > 0) {
        _showOrderSuccessDialog(
          lastMessage.isNotEmpty ? lastMessage : "Your order has been placed successfully!",
        );
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
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        ),
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
            child: Text(
              "OK",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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

// ============================================================
// RETAILER SELECTION MODAL BODY
// ============================================================
class _RetailerSelectionModalBody extends StatefulWidget {
  final String? selectedRetailerId;
  final ValueChanged<RetailerItem> onSelected;

  const _RetailerSelectionModalBody({
    required this.selectedRetailerId,
    required this.onSelected,
  });

  @override
  State<_RetailerSelectionModalBody> createState() => _RetailerSelectionModalBodyState();
}

class _RetailerSelectionModalBodyState extends State<_RetailerSelectionModalBody> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<RetailerItem> _allRetailers = [];
  List<RetailerItem> _filteredRetailers = [];
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRetailers);
    _loadRetailers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRetailers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await RetailerProfileService.getAllRetailers();
      if (!mounted) return;
      setState(() {
        _allRetailers = res.data;
        _isLoading = false;
      });
      _filterRetailers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _filterRetailers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredRetailers = _allRetailers.where((item) {
        final matchesStatus = _statusFilter == 'ALL' ||
            (_statusFilter == 'Active' && item.isActive) ||
            (_statusFilter == 'Inactive' && !item.isActive);

        final matchesQuery = query.isEmpty ||
            (item.name?.toLowerCase().contains(query) ?? false) ||
            (item.retailerId?.toLowerCase().contains(query) ?? false) ||
            (item.mobile?.toLowerCase().contains(query) ?? false) ||
            (item.district?.toLowerCase().contains(query) ?? false) ||
            (item.state?.toLowerCase().contains(query) ?? false);

        return matchesStatus && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.78;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Modal Drag Handle & Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Select Retailer Partner",
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar & Filter
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: "Search retailer by name, ID, phone, city...",
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("Filter: ", style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                    _chip("ALL", "All"),
                    const SizedBox(width: 6),
                    _chip("Active", "Active"),
                    const SizedBox(width: 6),
                    _chip("Inactive", "Inactive"),
                  ],
                ),
              ],
            ),
          ),

          // List Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 40, color: AppColors.error),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadRetailers,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                child: Text("Retry", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredRetailers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppColors.lightGold),
                                const SizedBox(height: 8),
                                Text(
                                  "No matching retailers found",
                                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRetailers,
                            color: AppColors.primaryGreen,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: _filteredRetailers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _filteredRetailers[index];
                                final isSelected = widget.selectedRetailerId != null &&
                                    widget.selectedRetailerId == item.retailerId;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.4),
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => widget.onSelected(item),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 44,
                                            width: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryGreen.withOpacity(0.08),
                                              border: Border.all(color: AppColors.primaryGold),
                                            ),
                                            child: const Icon(
                                              Icons.storefront_rounded,
                                              color: AppColors.primaryGreen,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name ?? "Retailer Partner",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                Text(
                                                  "ID: ${item.retailerId ?? 'N/A'} • ${item.mobile ?? ''}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11.5,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                if (item.displayLocation.isNotEmpty)
                                                  Text(
                                                    item.displayLocation,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: AppColors.primaryGreen,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Radio<bool>(
                                            value: true,
                                            groupValue: isSelected ? true : null,
                                            onChanged: (_) => widget.onSelected(item),
                                            activeColor: AppColors.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String key, String label) {
    final sel = _statusFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = key;
          _filterRetailers();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryGreen : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.6)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
            color: sel ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DEALER SELECTION MODAL BODY
// ============================================================
class _DealerSelectionModalBody extends StatefulWidget {
  final String? selectedDealerId;
  final ValueChanged<DealerProfileModel> onSelected;

  const _DealerSelectionModalBody({
    required this.selectedDealerId,
    required this.onSelected,
  });

  @override
  State<_DealerSelectionModalBody> createState() => _DealerSelectionModalBodyState();
}

class _DealerSelectionModalBodyState extends State<_DealerSelectionModalBody> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<DealerProfileModel> _allDealers = [];
  List<DealerProfileModel> _filteredDealers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDealers);
    _loadDealers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDealers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await DealerProfileService.getAllDealers();
      if (!mounted) return;
      setState(() {
        _allDealers = list;
        _isLoading = false;
      });
      _filterDealers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  void _filterDealers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredDealers = _allDealers.where((d) {
        return query.isEmpty ||
            (d.name?.toLowerCase().contains(query) ?? false) ||
            (d.dealerId?.toLowerCase().contains(query) ?? false) ||
            (d.phone?.toLowerCase().contains(query) ?? false) ||
            (d.businessAddress?.toLowerCase().contains(query) ?? false) ||
            (d.gstNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.78;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Select Dealer Partner",
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: "Search dealer by name, ID, phone, address...",
                  hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // List Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 40, color: AppColors.error),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadDealers,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                child: Text("Retry", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredDealers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppColors.lightGold),
                                const SizedBox(height: 8),
                                Text(
                                  "No matching dealers found",
                                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDealers,
                            color: AppColors.primaryGreen,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: _filteredDealers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final dealer = _filteredDealers[index];
                                final isSelected = widget.selectedDealerId != null &&
                                    widget.selectedDealerId == dealer.dealerId;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.4),
                                      width: isSelected ? 1.8 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => widget.onSelected(dealer),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 44,
                                            width: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryGreen.withOpacity(0.08),
                                              border: Border.all(color: AppColors.primaryGold),
                                            ),
                                            child: const Icon(
                                              Icons.business_rounded,
                                              color: AppColors.primaryGreen,
                                              size: 22,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dealer.name ?? "Authorized Dealer",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                                Text(
                                                  "ID: ${dealer.dealerId ?? 'N/A'} • ${dealer.phone ?? ''}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11.5,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                if (dealer.businessAddress != null && dealer.businessAddress!.isNotEmpty)
                                                  Text(
                                                    dealer.businessAddress!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: AppColors.primaryGreen,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Radio<bool>(
                                            value: true,
                                            groupValue: isSelected ? true : null,
                                            onChanged: (_) => widget.onSelected(dealer),
                                            activeColor: AppColors.primaryGreen,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}