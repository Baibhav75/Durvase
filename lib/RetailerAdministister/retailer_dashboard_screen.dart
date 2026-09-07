import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../model/Retailer_model/retailer_profile_model.dart';
import '../DealerAdministister/my_orders_page.dart';
import '../OrderPage/orderPagefist.dart';
import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../service/Retailer_service/retailer_login_service.dart';
import '../widgets/gemini_widget.dart';
import 'retailer_drawer.dart';
import 'retailer_id_card_screen.dart';
import 'retailer_invoices_page.dart';
import 'retailer_orders_page.dart';
import 'retailer_payments_page.dart';
import 'retailer_place_order_page.dart';
import 'retailer_products_page.dart';
import 'retailer_profile_page.dart';
import 'retailer_support_page.dart';
import 'retailer_team_screen.dart';
import 'retailer_track_order_page.dart';

class RetailerDashboardPage extends StatefulWidget {
  const RetailerDashboardPage({super.key});

  @override
  State<RetailerDashboardPage> createState() => _RetailerDashboardPageState();
}

class _RetailerDashboardPageState extends State<RetailerDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  RetailerModel? _retailer;
  RetailerProfileData? _profile;
  bool _isLoading = true;

  RetailerModel get _activeRetailer =>
      _retailer ??
      RetailerModel(
        visiterId: 'VTR107086',
        personName: 'Rahul Kumar',
        businessName: 'Durvasa Ayurveda Store',
        phone: '+91 9123456788',
        address: 'Main Market, Sector 18',
        photo: '',
        empType: 'Permanent',
        visitFor: 'Business Development',
        purpose: 'Retailer',
      );

  @override
  void initState() {
    super.initState();
    _loadRetailer();
  }

  Future<void> _loadRetailer() async {
    setState(() => _isLoading = true);

    try {
      final retailer = await RetailerService.getSavedRetailer();

      RetailerProfileData? profile;

      final currentId = retailer?.visiterId ?? retailer?.retailerId;
      if (currentId != null && currentId.isNotEmpty) {
        final response =
        await RetailerProfileService.getRetailerProfile(
          currentId,
        );

        if (response.data != null) {
          profile = response.data;
        }
      }

      if (mounted) {
        setState(() {
          _retailer = retailer;
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateTo(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    // Refresh retailer data in case profile was updated
    if (mounted) {
      _loadRetailer();
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryGold),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: AppColors.cream,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRetailer = _activeRetailer;
    final personName = currentRetailer.personName.isNotEmpty
        ? currentRetailer.personName
        : (currentRetailer.name.isNotEmpty ? currentRetailer.name : 'Rahul Kumar');
    final businessName = currentRetailer.businessName.isNotEmpty
        ? currentRetailer.businessName
        : 'Durvasa Ayurveda Store';
    final visiterId = currentRetailer.visiterId.isNotEmpty
        ? currentRetailer.visiterId
        : (currentRetailer.retailerId.isNotEmpty ? currentRetailer.retailerId : 'VTR107086');
    final phone = currentRetailer.phone.isNotEmpty
        ? currentRetailer.phone
        : '+91 9123456788';
    final purpose = currentRetailer.purpose.isNotEmpty ? currentRetailer.purpose : 'Retailer';
    final photoUrl = currentRetailer.fullPhotoUrl;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.white),
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Retailer Portal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined, color: AppColors.primaryGold),
            tooltip: 'View ID Card',
            onPressed: () => _navigateTo(RetailerIdCardScreen(retailer: currentRetailer)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            tooltip: 'Refresh',
            onPressed: _loadRetailer,
          ),
        ],
      ),
      drawer: RetailerDrawer(retailer: currentRetailer),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            )
          : RefreshIndicator(
              color: AppColors.primaryGreen,
              backgroundColor: AppColors.creamBackground,
              onRefresh: _loadRetailer,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Retailer Hero Info Card ----
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.deepGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.primaryGold.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.35),
                            spreadRadius: 1,
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: AppColors.primaryGold,
                                    width: 2,
                                  ),
                                ),
                                child: photoUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          photoUrl,
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.storefront_rounded,
                                            color: AppColors.white,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.white,
                                        size: 28,
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'AUTHORIZED ${purpose.toUpperCase()}',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primaryGold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      personName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (businessName.isNotEmpty && businessName != personName)
                                      Text(
                                        businessName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.cream.withValues(alpha: 0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    Text(
                                      'Durvasa Ayurved Partner',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.cream.withValues(alpha: 0.75),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppColors.white.withValues(alpha: 0.2)),

// Work Area & Territory
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primaryGold.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.map_outlined,
                                      size: 16,
                                      color: AppColors.primaryGold,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      'Visiter Details & Territory',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.primaryGold,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 9),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildInfoChip(
                                      Icons.tag_rounded,
                                      'Visiter ID: $visiterId',
                                    ),
                                    _buildInfoChip(
                                      Icons.phone_rounded,
                                      phone,
                                    ),
                                    if (currentRetailer.empType.isNotEmpty)
                                      _buildInfoChip(
                                        Icons.badge_outlined,
                                        'Type: ${currentRetailer.empType}',
                                      ),
                                    if (currentRetailer.purpose.isNotEmpty)
                                      _buildInfoChip(
                                        Icons.category_outlined,
                                        currentRetailer.purpose,
                                      ),
                                    if (currentRetailer.visitFor.isNotEmpty)
                                      _buildInfoChip(
                                        Icons.work_outline_rounded,
                                        currentRetailer.visitFor,
                                      ),

                                    if (_profile?.district?.isNotEmpty == true)
                                      _buildInfoChip(
                                        Icons.location_city_outlined,
                                        _profile!.district!,
                                      ),

                                    if (_profile?.block?.isNotEmpty == true)
                                      _buildInfoChip(
                                        Icons.domain_outlined,
                                        _profile!.block!,
                                      ),

                                    if (_profile?.state?.isNotEmpty == true)
                                      _buildInfoChip(
                                        Icons.map_outlined,
                                        _profile!.state!,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---- Durvasa AI Assistant Banner Card ----
                    InkWell(
                      onTap: () => DurvasaAiAssistantSheet.show(context, retailer: currentRetailer),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                border: Border.all(color: AppColors.primaryGold, width: 1.5),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Lottie.asset(
                                'assets/Ai chat.json',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Durvasa AI Assistant',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.leafGreen.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'ONLINE',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Instant Ayurvedic wellness tips, dosage & retailer help',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_rounded,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quick Services',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '10 Services Available',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---- Feature Grid (All working screens connected) ----
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _AnimatedDashboardCard(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Place Order',
                          subtitle: 'New Wholesale Order',
                          onTap: () => _navigateTo(RetailerPlaceOrderPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'Orders History',
                          subtitle: 'Order History & Status',
                          onTap: () =>
                              _navigateTo(MyOrdersPage(idType: 'Retailer', idValue: visiterId)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'My Order',
                          subtitle: 'Order History & Status',
                          onTap: () => _navigateTo(OrderPageFst(userId: visiterId)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Payments',
                          subtitle: 'Ledger & Dues',
                          onTap: () => _navigateTo(RetailerPaymentsPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.description_outlined,
                          title: 'Invoices',
                          subtitle: 'Tax & GST Bills',
                          onTap: () => _navigateTo(RetailerInvoicesPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.auto_awesome_rounded,
                          title: 'AI Assistant',
                          subtitle: 'Ayurvedic AI Helper',
                          onTap: () => DurvasaAiAssistantSheet.show(context, retailer: currentRetailer),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.groups_rounded,
                          title: 'Our Team',
                          subtitle: 'Retailers, MRs & ASMs',
                          onTap: () => _navigateTo(RetailerTeamScreen(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Products',
                          subtitle: 'Price List & Stock',
                          onTap: () => _navigateTo(RetailerProductsPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Track Order',
                          subtitle: 'Live Shipment Status',
                          onTap: () => _navigateTo(RetailerTrackOrderPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.support_agent_outlined,
                          title: 'Support',
                          subtitle: 'Help & Inquiries',
                          onTap: () => _navigateTo(RetailerSupportPage(retailer: currentRetailer)),
                        ),
                        _AnimatedDashboardCard(
                          icon: Icons.person_outline_rounded,
                          title: 'Profile',
                          subtitle: 'Account & Pharmacy',
                          onTap: () => _navigateTo(RetailerProfilePage(retailer: currentRetailer)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

      // ==========================================
      // AI CHAT FLOATING ACTION BUTTON
      // ==========================================
      floatingActionButton: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(
                alpha: 0.25,
              ),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => DurvasaAiAssistantSheet.show(context, retailer: currentRetailer),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Lottie.asset(
                'assets/Ai chat.json',
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryGreen,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _AnimatedDashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AnimatedDashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<_AnimatedDashboardCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            gradient: _isPressed
                ? LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withValues(alpha: 0.08),
                      AppColors.primaryGold.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primaryGold
                  : AppColors.lightGold.withValues(alpha: 0.45),
              width: _isPressed ? 1.6 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primaryGreen.withValues(alpha: 0.2)
                    : AppColors.primaryGreen.withValues(alpha: 0.06),
                blurRadius: _isPressed ? 14 : 10,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  boxShadow: _isPressed
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: _isPressed ? AppColors.primaryGold : AppColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isPressed ? AppColors.primaryGreen : AppColors.textDark,
                ),
              ),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}