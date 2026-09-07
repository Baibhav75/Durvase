import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../PaymentPage/payment_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../service/payment_service.dart';
import '../constants/app_colors.dart';
import '../model/checkout_model.dart';
import '../model/Retailer_model/retailer_team_model.dart';
import '../model/Retailer_model/asm_list_model.dart';
import '../service/Auth_servcie.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../service/session_manager.dart';
import '../service/api_serviceProfile.dart';
import '../service/api_service.dart' as order_api;
import '../model/user_address_model.dart';
import 'widgets/payment_widget.dart';

enum CheckoutPartnerType { retailer, asm }

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
  UserAddress? _userAddress;

  CheckoutPartnerType? _selectedPartnerType;
  RetailerItem? _selectedRetailer;
  AsmItem? _selectedAsm;
  bool _isPlacingOrder = false;

  // Payment Selection State
  CheckoutPaymentType _selectedPaymentType = CheckoutPaymentType.cod;
  final TextEditingController _upiIdController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  CheckoutResponse? _pendingCheckoutForOnline;

  @override
  void initState() {
    super.initState();
    _paymentService.initialize(
      onSuccess: _handleRazorpaySuccess,
      onError: _handleRazorpayError,
      onWallet: _handleRazorpayWallet,
    );
    _resolveUserIdAndLoad();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  void _resolveUserIdAndLoad() {
    _checkoutFuture = _loadCheckoutData();
  }

  Future<CheckoutResponse?> _loadCheckoutData() async {
    // 1. Check if passed userId is valid
    _effectiveUserId = widget.userId.trim();

    // 2. Fallback to SessionManager stored VisiterId
    if (_effectiveUserId.isEmpty) {
      final savedVisiterId = await SessionManager.getVisiterId();
      if (savedVisiterId != null && savedVisiterId.trim().isNotEmpty) {
        _effectiveUserId = savedVisiterId.trim();
      }
    }

    // 3. Fallback to SessionManager stored userId
    if (_effectiveUserId.isEmpty) {
      final savedId = await SessionManager.getUserId();
      if (savedId != null && savedId.trim().isNotEmpty) {
        _effectiveUserId = savedId.trim();
      }
    }

    // 4. Fallback to SessionManager EmpId
    if (_effectiveUserId.isEmpty) {
      final empId = await SessionManager.getEmpId();
      if (empId != null && empId.trim().isNotEmpty) {
        _effectiveUserId = empId.trim();
      }
    }

    // 5. Fetch user address using GetByAddressRetailerDealer API
    if (_effectiveUserId.isNotEmpty) {
      try {
        final addressResp = await order_api.ApiService.getAddressByVisiterId(_effectiveUserId);
        if (addressResp != null && addressResp.status && addressResp.data != null) {
          _userAddress = addressResp.data;
          debugPrint("📍 User Address fetched: ${_userAddress?.formattedAddress} (${_userAddress?.purpose})");
        }
      } catch (e) {
        debugPrint("Error fetching user address for checkout: $e");
      }
    }

    // 6. Fetch user profile for delivery address & customer info
    CheckoutUser resolvedUser = CheckoutUser(
      fullName: "Valued Customer",
      mobile: "",
      email: "",
      permanentAddress: _userAddress?.address ?? "",
      city: _userAddress?.district.isNotEmpty == true ? _userAddress!.district : (_userAddress?.block ?? ""),
      state: _userAddress?.state ?? "",
    );

    try {
      final loginData = await SessionManager.getLoginData();
      if (loginData != null && loginData.mobile != null && loginData.mobile!.isNotEmpty) {
        final profile = await ApiService.fetchProfile(loginData.mobile!);
        final employee = profile?.firstEmployee;
        if (employee != null) {
          if (_effectiveUserId.isEmpty && employee.userId != null && employee.userId!.isNotEmpty) {
            _effectiveUserId = employee.userId!;
            // Fetch address if not fetched yet
            if (_userAddress == null) {
              final addressResp = await order_api.ApiService.getAddressByVisiterId(_effectiveUserId);
              if (addressResp != null && addressResp.status && addressResp.data != null) {
                _userAddress = addressResp.data;
              }
            }
          }
          resolvedUser = CheckoutUser(
            fullName: employee.name ?? "Valued Customer",
            mobile: employee.mobile ?? loginData.mobile ?? "",
            email: employee.email ?? "",
            permanentAddress: _userAddress?.address.isNotEmpty == true
                ? _userAddress!.address
                : (employee.address ?? ""),
            city: _userAddress?.district.isNotEmpty == true
                ? _userAddress!.district
                : (employee.district ?? employee.postOffice ?? ""),
            state: _userAddress?.state.isNotEmpty == true
                ? _userAddress!.state
                : (employee.state ?? ""),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile for checkout: $e");
    }

    // Merge UserAddress into resolvedUser if permanentAddress is empty
    if (_userAddress != null && _userAddress!.isNotEmpty) {
      resolvedUser = CheckoutUser(
        fullName: resolvedUser.fullName.isNotEmpty ? resolvedUser.fullName : "Valued Customer",
        mobile: resolvedUser.mobile,
        email: resolvedUser.email,
        permanentAddress: _userAddress!.address.isNotEmpty ? _userAddress!.address : resolvedUser.permanentAddress,
        city: _userAddress!.district.isNotEmpty ? _userAddress!.district : (_userAddress!.block.isNotEmpty ? _userAddress!.block : resolvedUser.city),
        state: _userAddress!.state.isNotEmpty ? _userAddress!.state : resolvedUser.state,
      );
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
                Text(
                  "User ID: $_effectiveUserId",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                // 1. Partner Selection Section (Retailer / ASM Choose Option)
                _buildSectionHeader("Select Partner (Retailer / ASM)", Icons.handshake_outlined),
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

                // 4. Payment Method Section
                _buildSectionHeader("Select Payment Method", Icons.account_balance_wallet_outlined),
                const SizedBox(height: 10),
                PaymentWidget(
                  selectedPaymentType: _selectedPaymentType,
                  onPaymentTypeChanged: (type) {
                    setState(() {
                      _selectedPaymentType = type;
                    });
                  },
                  upiIdController: _upiIdController,
                  onUpiChanged: () {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 22),

                // 5. Price Summary Section
                _buildSectionHeader("Payment Summary", Icons.receipt_long_outlined),
                const SizedBox(height: 10),
                _buildPriceSummaryCard(checkout.summary, checkout.isEligibleToUsePoint),

                const SizedBox(height: 16),

                // 6. Safe Checkout Assurance Banner
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
  // PARTNER SELECTION WIDGETS (RETAILER & ASM CHOOSE OPTION)
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
                  type: CheckoutPartnerType.retailer,
                  title: "Retailer",
                  icon: Icons.storefront_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPartnerTypeChip(
                  type: CheckoutPartnerType.asm,
                  title: "ASM",
                  icon: Icons.military_tech_outlined,
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
                      "Please choose a partner channel above (Retailer or ASM).",
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
          else if (_selectedPartnerType == CheckoutPartnerType.retailer)
            _buildSelectedRetailerSection()
          else if (_selectedPartnerType == CheckoutPartnerType.asm)
            _buildSelectedAsmSection(),
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
          } else if (type == CheckoutPartnerType.asm && _selectedAsm == null) {
            _showAsmSelectionSheet();
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
              size: 15,
              color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
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
    final String retailerCodeOrId = retailer.retailerId ?? retailer.visiterId ?? (retailer.id != null ? retailer.id.toString() : 'N/A');

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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 1),
                ),
                child: retailer.resolvedImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          retailer.resolvedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            size: 20,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retailer.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      "ID: $retailerCodeOrId • ${retailer.mobile ?? 'No contact'}",
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
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Location: ${retailer.displayLocation}",
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark.withOpacity(0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildSelectedAsmSection() {
    if (_selectedAsm == null) {
      return InkWell(
        onTap: _showAsmSelectionSheet,
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
                "Choose ASM Partner",
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

    final asm = _selectedAsm!;
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
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 1.2),
                ),
                child: asm.resolvedImageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          asm.resolvedImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.military_tech_rounded,
                            size: 22,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : const Icon(Icons.military_tech_rounded, size: 22, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            asm.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "ID: ${asm.displayId}",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (asm.mobile != null && asm.mobile!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            asm.mobile!,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showAsmSelectionSheet,
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
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.creamBackground),
          const SizedBox(height: 6),
          // Address, State, Country details
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Country Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public, size: 11, color: Colors.blue.shade700),
                    const SizedBox(width: 3),
                    Text(
                      "Country: ${asm.country?.isNotEmpty == true ? asm.country : 'India'}",
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              // State Badge
              if (asm.state != null && asm.state!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_city_rounded, size: 11, color: AppColors.primaryGreen),
                      const SizedBox(width: 3),
                      Text(
                        "State: ${asm.state}",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              // District Badge
              if (asm.district != null && asm.district!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place_outlined, size: 11, color: AppColors.deepGold),
                      const SizedBox(width: 3),
                      Text(
                        "District: ${asm.district}",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (asm.address != null && asm.address!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Address: ${asm.address}",
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
    final String userState = (_userAddress != null && _userAddress!.state.trim().isNotEmpty)
        ? _userAddress!.state.trim()
        : '';
    final String userBlock = (_userAddress != null && _userAddress!.block.trim().isNotEmpty)
        ? _userAddress!.block.trim()
        : '';
    final String userDistrict = (_userAddress != null && _userAddress!.district.trim().isNotEmpty)
        ? _userAddress!.district.trim()
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return _RetailerSelectionModalBody(
              selectedRetailerId: _selectedRetailer?.visiterId ?? _selectedRetailer?.retailerId ?? (_selectedRetailer?.id != null ? _selectedRetailer!.id.toString() : null),
              userState: userState,
              userBlock: userBlock,
              userDistrict: userDistrict,
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
  // ASM LIST MODAL SELECTION SHEET
  // ============================================================
  void _showAsmSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return _AsmSelectionModalBody(
              selectedAsmId: _selectedAsm?.empId ?? _selectedAsm?.employeeCode,
              onSelected: (asm) {
                setState(() {
                  _selectedAsm = asm;
                  _selectedPartnerType = CheckoutPartnerType.asm;
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
    final String purposeTag = (_userAddress?.purpose.isNotEmpty == true)
        ? _userAddress!.purpose
        : "Delivery Address";

    final bool hasDetailedAddress = _userAddress != null && _userAddress!.isNotEmpty;
    final bool hasUserAddress = user.permanentAddress.trim().isNotEmpty ||
        user.city.trim().isNotEmpty ||
        user.state.trim().isNotEmpty;

    final String displayBlock = (_userAddress != null && _userAddress!.block.trim().isNotEmpty)
        ? _userAddress!.block.trim()
        : '';
    final String displayDistrict = (_userAddress != null && _userAddress!.district.trim().isNotEmpty)
        ? _userAddress!.district.trim()
        : user.city.trim();
    final String displayState = (_userAddress != null && _userAddress!.state.trim().isNotEmpty)
        ? _userAddress!.state.trim()
        : user.state.trim();

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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  purposeTag,
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
          if (hasDetailedAddress) ...[
            if (_userAddress!.address.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home_outlined, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _userAddress!.address,
                      style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            if (displayBlock.isNotEmpty || displayDistrict.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_city_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        if (displayBlock.isNotEmpty) "Block: $displayBlock",
                        if (displayDistrict.isNotEmpty) "District: $displayDistrict",
                      ].join(', '),
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (displayState.isNotEmpty || (_userAddress?.country.isNotEmpty ?? false)) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.public_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        if (displayState.isNotEmpty) "State: $displayState",
                        if (_userAddress?.country.isNotEmpty ?? false) _userAddress!.country,
                      ].join(', '),
                      style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Text(
              hasUserAddress
                  ? "${user.permanentAddress}${user.permanentAddress.isNotEmpty ? ', ' : ''}${user.city}${user.city.isNotEmpty ? ', ' : ''}${user.state}"
                  : "Address will be confirmed upon order dispatch",
              style: GoogleFonts.poppins(
                color: AppColors.textDark.withOpacity(0.85),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],

          // State and Block highlight tags
          if (displayBlock.isNotEmpty || displayState.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (displayBlock.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_city_rounded, size: 13, color: AppColors.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          "Block: $displayBlock",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (displayDistrict.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.creamBackground,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.lightGold.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.domain_outlined, size: 13, color: AppColors.textDark),
                        const SizedBox(width: 4),
                        Text(
                          "District: $displayDistrict",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (displayState.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_outlined, size: 13, color: AppColors.deepGold),
                        const SizedBox(width: 4),
                        Text(
                          "State: $displayState",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepGold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

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
            ? (rawImg.startsWith('http') ? rawImg : 'https://durvasaayurved.com$rawImg')
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
    final double finalAmount = checkout.summary.finalAmount > 0
        ? checkout.summary.finalAmount
        : checkout.summary.totalSellingPrice;

    String buttonLabel;
    IconData buttonIcon;
    if (_isPlacingOrder) {
      buttonLabel = "PROCESSING ORDER...";
      buttonIcon = Icons.hourglass_top_rounded;
    } else {
      switch (_selectedPaymentType) {
        case CheckoutPaymentType.cod:
          buttonLabel = "PLACE ORDER (COD)";
          buttonIcon = Icons.local_shipping_outlined;
          break;
        case CheckoutPaymentType.upi:
          buttonLabel = "PLACE ORDER (UPI)";
          buttonIcon = Icons.qr_code_scanner_rounded;
          break;
        case CheckoutPaymentType.online:
          buttonLabel = "PROCEED TO PAY (ONLINE)";
          buttonIcon = Icons.credit_card_rounded;
          break;
      }
    }

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
                      : Icon(buttonIcon, color: AppColors.white, size: 18),
                  label: Text(
                    buttonLabel,
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
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
                  "Please choose a partner channel (Retailer or ASM) to continue.",
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

    if (_selectedPartnerType == CheckoutPartnerType.asm && _selectedAsm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an ASM Partner first."),
          backgroundColor: Colors.orange,
        ),
      );
      _showAsmSelectionSheet();
      return;
    }

    // Validate UPI ID if UPI option is selected
    if (_selectedPaymentType == CheckoutPaymentType.upi) {
      final upiId = _upiIdController.text.trim();
      if (upiId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Please enter your UPI ID to proceed.",
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
      if (!upiId.contains('@') || upiId.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Please enter a valid UPI ID (e.g. user@oksbi, 9876543210@paytm).",
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    // Online Payment via Razorpay
    if (_selectedPaymentType == CheckoutPaymentType.online) {
      _pendingCheckoutForOnline = checkout;
      final double finalAmount = checkout.summary.finalAmount > 0
          ? checkout.summary.finalAmount
          : checkout.summary.totalSellingPrice;
      await _paymentService.openCheckout(
        amount: finalAmount,
        name: "Durvasa Ayurved",
        description: "Order Payment",
        contact: checkout.user.mobile.isNotEmpty ? checkout.user.mobile : "9999999999",
        email: checkout.user.email.isNotEmpty ? checkout.user.email : "customer@durvasaayurved.com",
      );
      return;
    }

    // Cash on Delivery or UPI ID
    final String paymentMode = _selectedPaymentType == CheckoutPaymentType.upi
        ? "UPI (${_upiIdController.text.trim()})"
        : "COD";

    await _executePlaceOrderApi(checkout, paymentMode: paymentMode);
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    if (_pendingCheckoutForOnline != null) {
      final checkout = _pendingCheckoutForOnline!;
      _pendingCheckoutForOnline = null;
      await _executePlaceOrderApi(
        checkout,
        paymentMode: "Razorpay (ID: ${response.paymentId ?? 'Success'})",
      );
    }
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    _pendingCheckoutForOnline = null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.message ?? "Online Payment Failed. Please try again.",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleRazorpayWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "External wallet selected: ${response.walletName}",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _executePlaceOrderApi(CheckoutResponse checkout, {required String paymentMode}) async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final String retailerId = (_selectedPartnerType == CheckoutPartnerType.retailer)
          ? (_selectedRetailer?.retailerId ?? _selectedRetailer?.visiterId ?? (_selectedRetailer?.id != null ? _selectedRetailer!.id.toString() : ""))
          : "";

      final String dealerId = "";

      final String asmId = (_selectedPartnerType == CheckoutPartnerType.asm)
          ? (_selectedAsm?.empId ?? _selectedAsm?.employeeCode ?? "")
          : "";

      final List<String> addressParts = [
        checkout.user.permanentAddress,
        checkout.user.city,
        checkout.user.state,
      ].where((s) => s.trim().isNotEmpty).toList();

      final String shippingAddress = (_userAddress != null && _userAddress!.formattedAddress.isNotEmpty)
          ? _userAddress!.formattedAddress
          : (addressParts.isNotEmpty ? addressParts.join(", ") : "Delivery Address");

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
        debugPrint("AsmId: $asmId");
        debugPrint("UserId: $_effectiveUserId");
        debugPrint("ShippingAddress: $shippingAddress");
        debugPrint("PaymentMode: $paymentMode");
        debugPrint("========================================");

        final response = await order_api.ApiService.placeOrder(
          productId: pid,
          retailerId: retailerId,
          dealerId: dealerId,
          asmId: asmId,
          userId: _effectiveUserId,
          shippingAddress: shippingAddress,
          paymentMode: paymentMode,
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
  final String userState;
  final String userBlock;
  final String userDistrict;
  final ValueChanged<RetailerItem> onSelected;

  const _RetailerSelectionModalBody({
    required this.selectedRetailerId,
    this.userState = '',
    this.userBlock = '',
    this.userDistrict = '',
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
  String _statusFilter = 'ALL'; // ALL, Active, Inactive

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

  bool _matchesNormalized(String? a, String? b) {
    if (a == null || b == null) return false;
    final cleanA = a.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final cleanB = b.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleanA.isEmpty || cleanB.isEmpty) return false;
    if (cleanA == cleanB) return true;
    if (cleanA.contains(cleanB) || cleanB.contains(cleanA)) return true;
    return false;
  }

  bool _isBlockMatch(RetailerItem item) {
    final effectiveBlock = widget.userBlock.trim().isNotEmpty
        ? widget.userBlock.trim()
        : widget.userDistrict.trim();

    // If no block/district is present in address, allow state matching or all
    if (effectiveBlock.isEmpty) {
      if (widget.userState.trim().isNotEmpty) {
        return _matchesNormalized(item.state, widget.userState);
      }
      return true;
    }

    final blockMatches = _matchesNormalized(item.block, effectiveBlock) ||
        _matchesNormalized(item.district, effectiveBlock) ||
        _matchesNormalized(item.address, effectiveBlock);

    final stateMatches = widget.userState.trim().isEmpty ||
        _matchesNormalized(item.state, widget.userState);

    return blockMatches && stateMatches;
  }

  Future<void> _loadRetailers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await order_api.ApiService.getAllRetailers();
      if (!mounted) return;
      _allRetailers = response.data;
      setState(() {
        _isLoading = false;
      });
      _filterRetailers();
    } catch (e) {
      try {
        final fallback = await RetailerProfileService.getAllRetailers();
        if (!mounted) return;
        _allRetailers = fallback.data;
        setState(() {
          _isLoading = false;
        });
        _filterRetailers();
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e2.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterRetailers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredRetailers = _allRetailers.where((item) {
        // 1. Strict Block Matching (Only show retailers from user's Block)
        if (!_isBlockMatch(item)) return false;

        // 2. Status Filter
        final matchesStatus = _statusFilter == 'ALL' ||
            (_statusFilter == 'Active' && item.isActive) ||
            (_statusFilter == 'Inactive' && !item.isActive);
        if (!matchesStatus) return false;

        // 3. Search Query
        final matchesQuery = query.isEmpty ||
            (item.name?.toLowerCase().contains(query) ?? false) ||
            (item.displayName.toLowerCase().contains(query)) ||
            (item.businessName?.toLowerCase().contains(query) ?? false) ||
            (item.personName?.toLowerCase().contains(query) ?? false) ||
            (item.visiterId?.toLowerCase().contains(query) ?? false) ||
            (item.retailerId?.toLowerCase().contains(query) ?? false) ||
            (item.id?.toString().contains(query) ?? false) ||
            (item.mobile?.toLowerCase().contains(query) ?? false) ||
            (item.district?.toLowerCase().contains(query) ?? false) ||
            (item.block?.toLowerCase().contains(query) ?? false) ||
            (item.state?.toLowerCase().contains(query) ?? false) ||
            (item.address?.toLowerCase().contains(query) ?? false);

        return matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.82;
    final String activeBlockName = widget.userBlock.isNotEmpty ? widget.userBlock : widget.userDistrict;
    final String activeStateName = widget.userState;

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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Icon(Icons.storefront_rounded, color: AppColors.primaryGold, size: 22),
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
                if (activeBlockName.isNotEmpty || activeStateName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGold.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primaryGold, size: 13),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "My Block: ${activeBlockName.isNotEmpty ? activeBlockName : 'N/A'}${activeStateName.isNotEmpty ? ' ($activeStateName)' : ''}",
                            style: GoogleFonts.poppins(
                              color: AppColors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search Bar & Filter
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
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
                      hintText: "Search in your block by name, ID, phone...",
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

                // Status Filter
                Row(
                  children: [
                    Text("Status: ", style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                    _statusChip("ALL", "All"),
                    const SizedBox(width: 6),
                    _statusChip("Active", "Active"),
                    const SizedBox(width: 6),
                    _statusChip("Inactive", "Inactive"),
                  ],
                ),
              ],
            ),
          ),

          // Location Summary Banner
          if (!_isLoading && _errorMessage == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: AppColors.primaryGreen.withOpacity(0.08),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _filteredRetailers.isNotEmpty
                          ? "Showing ${_filteredRetailers.length} retailer(s) in Block '$activeBlockName'"
                          : "No retailers found in Block '$activeBlockName'",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
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
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.store_mall_directory_outlined, size: 48, color: AppColors.lightGold),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No retailers in your block",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activeBlockName.isNotEmpty
                                        ? "There are no registered retailer partners in Block '$activeBlockName'${activeStateName.isNotEmpty ? ', $activeStateName' : ''}."
                                        : "No retailers found matching your criteria.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
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
                                    (widget.selectedRetailerId == item.retailerId ||
                                     widget.selectedRetailerId == item.visiterId ||
                                     (item.id != null && widget.selectedRetailerId == item.id.toString()));

                                final String retailerCodeOrId = item.retailerId ?? item.visiterId ?? (item.id != null ? item.id.toString() : 'N/A');

                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.35),
                                      width: isSelected ? 2.0 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppColors.primaryGreen.withOpacity(0.12)
                                            : Colors.black.withOpacity(0.03),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
                                                ),
                                                child: const Icon(
                                                  Icons.store_rounded,
                                                  color: AppColors.primaryGreen,
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.displayName,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textDark,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    if (item.businessName != null && item.businessName!.isNotEmpty)
                                                      Text(
                                                        item.businessName!,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: AppColors.primaryGold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    Text(
                                                      "ID: $retailerCodeOrId",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Radio Selection / Check icon
                                              Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected ? AppColors.primaryGreen : AppColors.lightGold,
                                                    width: 1.8,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                                                    : null,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Divider(height: 1, color: AppColors.creamBackground),
                                          const SizedBox(height: 8),
                                          // Details row (Phone, Block, State, Status)
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 6,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              if (item.mobile != null && item.mobile!.isNotEmpty)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      item.mobile!,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              // Status badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: item.isActive
                                                      ? AppColors.primaryGreen.withOpacity(0.12)
                                                      : Colors.red.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.isActive ? "Active" : "Inactive",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: item.isActive ? AppColors.primaryGreen : AppColors.error,
                                                  ),
                                                ),
                                              ),

                                              // Block badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.check_circle, size: 11, color: AppColors.primaryGreen),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      "Block: ${item.block?.isNotEmpty == true ? item.block : (item.district ?? 'N/A')}",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.primaryGreen,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              if (item.displayLocation.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 2),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        item.displayLocation,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
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

  Widget _statusChip(String key, String label) {
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
// ASM SELECTION MODAL BODY
// ============================================================
class _AsmSelectionModalBody extends StatefulWidget {
  final String? selectedAsmId;
  final ValueChanged<AsmItem> onSelected;

  const _AsmSelectionModalBody({
    required this.selectedAsmId,
    required this.onSelected,
  });

  @override
  State<_AsmSelectionModalBody> createState() => _AsmSelectionModalBodyState();
}

class _AsmSelectionModalBodyState extends State<_AsmSelectionModalBody> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<AsmItem> _allAsm = [];
  List<AsmItem> _filteredAsm = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterAsm);
    _loadAsm();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAsm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await order_api.ApiService.getASMList();
      if (!mounted) return;
      setState(() {
        _allAsm = response.data;
        _isLoading = false;
      });
      _filterAsm();
    } catch (e) {
      try {
        final fallback = await RetailerProfileService.getAsmList();
        if (!mounted) return;
        setState(() {
          _allAsm = fallback.data;
          _isLoading = false;
        });
        _filterAsm();
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e2.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _filterAsm() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredAsm = _allAsm.where((asm) {
        return query.isEmpty ||
            (asm.name?.toLowerCase().contains(query) ?? false) ||
            (asm.empId?.toLowerCase().contains(query) ?? false) ||
            (asm.employeeCode?.toLowerCase().contains(query) ?? false) ||
            (asm.mrId?.toLowerCase().contains(query) ?? false) ||
            (asm.mobile?.toLowerCase().contains(query) ?? false) ||
            (asm.email?.toLowerCase().contains(query) ?? false) ||
            (asm.district?.toLowerCase().contains(query) ?? false) ||
            (asm.state?.toLowerCase().contains(query) ?? false) ||
            (asm.block?.toLowerCase().contains(query) ?? false);
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
                        const Icon(Icons.military_tech_rounded, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Select ASM Partner",
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
                  hintText: "Search ASM by name, Emp ID, mobile, district...",
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
                                onPressed: _loadAsm,
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                child: Text("Retry", style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredAsm.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppColors.lightGold),
                                const SizedBox(height: 8),
                                Text(
                                  "No matching ASM executives found",
                                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAsm,
                            color: AppColors.primaryGreen,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: _filteredAsm.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final asm = _filteredAsm[index];
                                final isSelected = widget.selectedAsmId != null &&
                                    (widget.selectedAsmId == asm.empId || widget.selectedAsmId == asm.employeeCode);

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
                                        color: isSelected
                                            ? AppColors.primaryGreen.withOpacity(0.12)
                                            : Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => widget.onSelected(asm),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 44,
                                                width: 44,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryGreen.withOpacity(0.08),
                                                  border: Border.all(color: AppColors.primaryGold),
                                                ),
                                                child: asm.resolvedImageUrl.isNotEmpty
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          asm.resolvedImageUrl,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => const Icon(
                                                            Icons.military_tech_rounded,
                                                            color: AppColors.primaryGreen,
                                                            size: 22,
                                                          ),
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.military_tech_rounded,
                                                        color: AppColors.primaryGreen,
                                                        size: 22,
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            asm.displayName,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColors.textDark,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                          decoration: BoxDecoration(
                                                            color: AppColors.primaryGreen,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Text(
                                                            "ID: ${asm.displayId}",
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppColors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (asm.mobile != null && asm.mobile!.isNotEmpty) ...[
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                                                          const SizedBox(width: 3),
                                                          Text(
                                                            asm.mobile!,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 11.5,
                                                              color: AppColors.textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Radio<bool>(
                                                value: true,
                                                groupValue: isSelected ? true : null,
                                                onChanged: (_) => widget.onSelected(asm),
                                                activeColor: AppColors.primaryGreen,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          const Divider(height: 1, color: AppColors.creamBackground),
                                          const SizedBox(height: 6),
                                          // Address, State, Country details
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              // Country Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.blue.shade200),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.public, size: 11, color: Colors.blue.shade700),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      "Country: ${asm.country?.isNotEmpty == true ? asm.country : 'India'}",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.blue.shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // State Badge
                                              if (asm.state != null && asm.state!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryGreen.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.location_city_rounded, size: 11, color: AppColors.primaryGreen),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        "State: ${asm.state}",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppColors.primaryGreen,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // District Badge
                                              if (asm.district != null && asm.district!.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.creamBackground,
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.place_outlined, size: 11, color: AppColors.deepGold),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        "District: ${asm.district}",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.w500,
                                                          color: AppColors.textDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (asm.address != null && asm.address!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.home_outlined, size: 12, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    "Address: ${asm.address}",
                                                    style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textSecondary),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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