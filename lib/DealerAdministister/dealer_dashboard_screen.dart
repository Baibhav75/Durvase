import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../OrderPage/orderPagefist.dart';
import '../OrderPage/utils/theme_constants.dart';
import '../model/Dealer_Model/dealer_login_model.dart';
import '../service/Dealer_service/dealer_login_service.dart';
import 'dealer_drawer.dart';
import 'my_orders_page.dart';
import 'dealer_payments_page.dart';
import 'dealer_invoices_page.dart';
import 'dealer_products_page.dart';
import 'dealer_track_order_page.dart';
import 'dealer_support_page.dart';
import 'dealer_profile_screen.dart';

class DealerDashboardPage extends StatefulWidget {
  const DealerDashboardPage({super.key});

  @override
  State<DealerDashboardPage> createState() => _DealerDashboardPageState();
}

class _DealerDashboardPageState extends State<DealerDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // 👈 add

  DealerModel? _dealer;

  @override
  void initState() {
    super.initState();
    _loadDealer();
  }

  Future<void> _loadDealer() async {
    final dealer = await DealerService.getSavedDealer();
    if (mounted) setState(() => _dealer = dealer);
  }

  @override
  Widget build(BuildContext context) {
    final name = _dealer?.name ?? 'Dealer';
    final dealerId = _dealer?.dealerId ?? '--';
    final phone = _dealer?.phone ?? '--';
    final businessName = _dealer?.businessName ?? '';
    final photoUrl = _dealer?.resolvedImageUrl ?? '';
    final location = [_dealer?.district, _dealer?.state].where((s) => s != null && s.trim().isNotEmpty).join(', ');

    return Scaffold(
      key: _scaffoldKey, // 👈 add
      backgroundColor: ThemeConstants.creamBackground,
      drawer: _dealer != null ? DealerDrawer(dealer: _dealer!) : null, // 👈 add
      appBar: AppBar(
        backgroundColor: ThemeConstants.primaryGreen,
        elevation: 0,
        leading: IconButton( // 👈 changed from Icon to IconButton
          icon: const Icon(Icons.menu, color: ThemeConstants.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Welcome, $name',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ThemeConstants.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- Dealer Info Card ----
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                           begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeConstants.primaryGreen,
                            ThemeConstants.primaryGold,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ThemeConstants.primaryGold, width: 2),
                                  color: ThemeConstants.primaryGreen.withOpacity(0.5),
                                ),
                                child: photoUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          photoUrl,
                                          height: 56,
                                          width: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.storefront, color: ThemeConstants.white, size: 28),
                                        ),
                                      )
                                    : const Icon(Icons.storefront, color: ThemeConstants.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      businessName.isNotEmpty ? businessName : 'Dealer Portal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: businessName.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                                        color: ThemeConstants.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeConstants.white,
                                      ),
                                    ),
                                    Text(
                                      location.isNotEmpty ? location : 'Authorized Dealer',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: ThemeConstants.white.withOpacity(0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: ThemeConstants.white.withOpacity(0.35), height: 1),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _infoPill('ID: $dealerId'),
                              const SizedBox(width: 10),
                              _infoPill('Mobile: $phone'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ---- Feature Grid ----
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.45,
                      children: [
                        _featureCard(
                          Icons.shopping_cart_outlined,
                          'Place Order',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPageFst(userId: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.receipt_long_outlined,
                          'My Orders',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyOrdersPage(idType: 'Dealer', idValue: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.account_balance_wallet_outlined,
                          'Payments',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerPaymentsPage(dealerId: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.description_outlined,
                          'Invoices',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerInvoicesPage(dealerId: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.inventory_2_outlined,
                          'Products',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerProductsPage(dealerId: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.local_shipping_outlined,
                          'Track Order',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerTrackOrderPage(dealerId: dealerId),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.support_agent_outlined,
                          'Support',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DealerSupportPage(
                                  dealerId: dealerId,
                                  dealerName: name,
                                  dealerPhone: phone,
                                ),
                              ),
                            );
                          },
                        ),

                        _featureCard(
                          Icons.person_outline,
                          'Profile',
                          () {
                            if (_dealer != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DealerProfilePage(dealer: _dealer!),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConstants.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, color: ThemeConstants.white),
      ),
    );
  }

  Widget _featureCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeConstants.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConstants.creamBackground,
              ),
              child: Icon(icon, color: ThemeConstants.primaryGreen, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ThemeConstants.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}