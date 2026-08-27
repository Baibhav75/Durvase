import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../homepage.dart';
import '../../model/Dealer_Model/dealer_login_model.dart';
import '../service/Dealer_service/dealer_session_manager.dart';
import 'dealer_profile_screen.dart';
import 'dealer_place_order_page.dart';
import 'my_orders_page.dart';

class DealerDrawer extends StatefulWidget {
  final DealerModel dealer;

  const DealerDrawer({
    super.key,
    required this.dealer,
  });

  @override
  State<DealerDrawer> createState() => _DealerDrawerState();
}

class _DealerDrawerState extends State<DealerDrawer> {
  // ============================================================
  // NAVIGATION
  // ============================================================

// ============================================================
// NAVIGATION
// ============================================================

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  void _closeDrawer() {
    Navigator.pop(context);
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String feature) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature - Coming Soon!',
          style: GoogleFonts.poppins(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await DealerSessionManager.logout();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
            (_) => false,
      );
    } catch (e) {
      debugPrint('Dealer logout error: $e');
    }
  }

  void _showLogoutDialog() {
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
            'Are you sure you want to logout?',
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
                _logout();
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

  // ============================================================
  // DRAWER ITEM
  // ============================================================

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: const Icon(
        Icons.circle,
        color: Colors.transparent,
        size: 0,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minLeadingWidth: 24,
      horizontalTitleGap: 8,
      title: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryGold,
            size: 24,
          ),
          const SizedBox(width: 16),
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

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _profileHeader() {
    final name = widget.dealer.name.isNotEmpty ? widget.dealer.name : 'Dealer';
    final email = widget.dealer.email.isNotEmpty ? widget.dealer.email : 'dealer@durvasaayurved.com';
    final dealerId = widget.dealer.dealerId.isNotEmpty ? widget.dealer.dealerId : '--';

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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.cream.withOpacity(.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dealer ID: $dealerId',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGold,
          width: 2,
        ),
      ),
      child: const CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.white,
        child: Icon(
          Icons.storefront,
          color: AppColors.primaryGreen,
          size: 28,
        ),
      ),
    );
  }

  Widget _idCardHeaderButton() {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        _showComingSoon('Dealer ID Card');
        // _goTo(DealerIdCardScreen(dealer: widget.dealer));
      },
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
    onPressed: () {
      _goTo(DealerProfilePage(dealer: widget.dealer));
    },
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

  // ============================================================
  // BUILD
  // ============================================================

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

            // Dealer Identity Card
            _drawerItem(
              icon: Icons.badge_outlined,
              title: 'Dealer Identity Card',
              onTap: () => _showComingSoon('Dealer Identity Card'),
              // onTap: () => _goTo(DealerIdCardScreen(dealer: widget.dealer)),
            ),

            // Place Order
            _drawerItem(
              icon: Icons.shopping_cart_outlined,
              title: 'Place Order',
              onTap: () => _goTo(DealerPlaceOrderPage(dealer: widget.dealer)),
            ),

            // My Orders
            _drawerItem(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              onTap: () => _goTo(MyOrdersPage(idType: 'Dealer', idValue: widget.dealer.dealerId ?? '')),
            ),

            // Track Order
            _drawerItem(
              icon: Icons.local_shipping_outlined,
              title: 'Track Order',
              onTap: () => _showComingSoon('Track Order'),
              // onTap: () => _goTo(DealerTrackOrderPage(dealer: widget.dealer)),
            ),

            // Payments
            _drawerItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payments',
              onTap: () => _showComingSoon('Payments'),
              // onTap: () => _goTo(DealerPaymentsPage(dealer: widget.dealer)),
            ),

            // Invoices
            _drawerItem(
              icon: Icons.description_outlined,
              title: 'Invoices',
              onTap: () => _showComingSoon('Invoices'),
              // onTap: () => _goTo(DealerInvoicesPage(dealer: widget.dealer)),
            ),

            // Products
            _drawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              onTap: () => _showComingSoon('Products'),
              // onTap: () => _goTo(DealerProductsPage(dealer: widget.dealer)),
            ),

            // Support
            _drawerItem(
              icon: Icons.support_agent_outlined,
              title: 'Support',
              onTap: () => _showComingSoon('Support'),
              // onTap: () => _goTo(DealerSupportPage(dealer: widget.dealer)),
            ),

            Divider(
              color: AppColors.white.withOpacity(.2),
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