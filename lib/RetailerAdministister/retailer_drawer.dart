import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../homepage.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../service/Retailer_service/retailer_session_manager.dart';
import 'retailer_id_card_screen.dart';
import 'retailer_invoices_page.dart';
import 'retailer_orders_page.dart';
import 'retailer_order_history_page.dart';
import 'retailer_payments_page.dart';
import 'retailer_place_order_page.dart';
import 'retailer_products_page.dart';
import 'retailer_profile_page.dart';
import 'retailer_support_page.dart';
import 'retailer_team_screen.dart';
import 'retailer_track_order_page.dart';
import '../widgets/gemini_widget.dart';

class RetailerDrawer extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerDrawer({
    super.key,
    required this.retailer,
  });

  @override
  State<RetailerDrawer> createState() => _RetailerDrawerState();
}

class _RetailerDrawerState extends State<RetailerDrawer> {
  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _closeDrawer() {
    Navigator.pop(context);
  }

  void _showComingSoon(String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Coming Soon!',
          style: GoogleFonts.poppins(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout(BuildContext navContext) async {
    try {
      await RetailerSessionManager.logout();

      Navigator.of(navContext, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (_) => false,
      );
    } catch (e) {
      debugPrint('Retailer logout error: $e');
      Navigator.of(navContext, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
        (_) => false,
      );
    }
  }

  void _showLogoutDialog() {
    final navContext = Navigator.of(context, rootNavigator: true).context;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to logout from Retailer portal?',
            style: GoogleFonts.poppins(
              color: AppColors.textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout(navContext);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      horizontalTitleGap: 8,
      title: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGold,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _profileHeader() {
    final personName = widget.retailer.personName.isNotEmpty
        ? widget.retailer.personName
        : (widget.retailer.name.isNotEmpty ? widget.retailer.name : 'Rahul Kumar');
    final businessName = widget.retailer.businessName.isNotEmpty
        ? widget.retailer.businessName
        : 'Durvasa Ayurveda Store';
    final visiterId = widget.retailer.visiterId.isNotEmpty
        ? widget.retailer.visiterId
        : (widget.retailer.retailerId.isNotEmpty ? widget.retailer.retailerId : 'VTR107086');

    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGreen,
            AppColors.primaryGreen,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              _profileImage(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    if (businessName.isNotEmpty && businessName != personName)
                      Text(
                        businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: AppColors.cream.withValues(alpha: 0.9),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      'Visiter ID: $visiterId',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _idCardHeaderButton(),
              const SizedBox(width: 8),
              _profileButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileImage() {
    final imageUrl = widget.retailer.fullPhotoUrl;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGold,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        child: imageUrl.isEmpty
            ? const Icon(
                Icons.storefront_rounded,
                color: AppColors.primaryGreen,
                size: 28,
              )
            : null,
      ),
    );
  }

  Widget _idCardHeaderButton() {
    return OutlinedButton.icon(
      onPressed: () => _goTo(RetailerIdCardScreen(retailer: widget.retailer)),
      icon: const Icon(
        Icons.badge_outlined,
        color: AppColors.lightGold,
        size: 14,
      ),
      label: Text(
        'ID Card',
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.lightGold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _profileButton() {
    return ElevatedButton(
      onPressed: () => _goTo(RetailerProfilePage(retailer: widget.retailer)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryGreen,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.primaryGold,
          ),
        ),
      ),
      child: Text(
        'View Profile',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.primaryGreen,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _profileHeader(),

            const SizedBox(height: 10),

            // Dashboard
            _drawerItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              onTap: _closeDrawer,
            ),

            // Retailer Identity Card
            _drawerItem(
              icon: Icons.badge_outlined,
              title: 'Retailer Identity Card',
              onTap: () => _goTo(RetailerIdCardScreen(retailer: widget.retailer)),
            ),

            // Place Order
            _drawerItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Place Order',
              onTap: () => _goTo(RetailerPlaceOrderPage(retailer: widget.retailer)),
            ),

            // My Orders
            _drawerItem(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              onTap: () => _goTo(RetailerOrderHistoryPage(retailer: widget.retailer)),
            ),

            // Track Order
            _drawerItem(
              icon: Icons.local_shipping_outlined,
              title: 'Track Order',
              onTap: () => _goTo(RetailerTrackOrderPage(retailer: widget.retailer)),
            ),

            // Payments
            _drawerItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payments',
              onTap: () => _goTo(RetailerPaymentsPage(retailer: widget.retailer)),
            ),

            // Invoices
            _drawerItem(
              icon: Icons.description_outlined,
              title: 'Invoices',
              onTap: () => _goTo(RetailerInvoicesPage(retailer: widget.retailer)),
            ),

            // Products
            _drawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              onTap: () => _goTo(RetailerProductsPage(retailer: widget.retailer)),
            ),

            // Our Team
            // Our Team
            _drawerItem(
              icon: Icons.groups_rounded,
              title: 'Our Team',
              onTap: () => _goTo(
                RetailerTeamScreen(
                  employeeId: widget.retailer.visiterId,
                  employeeType: 'Retailer',
                ),
              ),
            ),

            // Support
            _drawerItem(
              icon: Icons.support_agent_outlined,
              title: 'Support',
              onTap: () => _goTo(RetailerSupportPage(retailer: widget.retailer)),
            ),

            // AI Assistant
            _drawerItem(
              icon: Icons.auto_awesome_rounded,
              title: 'Durvasa AI Assistant',
              onTap: () {
                Navigator.pop(context);
                DurvasaAiAssistantSheet.show(context, retailer: widget.retailer);
              },
            ),

            Divider(
              color: AppColors.white.withValues(alpha: 0.2),
            ),

            // Settings
            _drawerItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () => _showComingSoon('Settings'),
            ),

            // Logout
            _drawerItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }
}