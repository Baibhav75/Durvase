import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerOrdersPage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerOrdersPage({super.key, required this.retailer});

  @override
  State<RetailerOrdersPage> createState() => _RetailerOrdersPageState();
}

class _RetailerOrdersPageState extends State<RetailerOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-2026-8841',
      'date': '24 Aug 2026',
      'itemsCount': 8,
      'amount': 18450.0,
      'status': 'Dispatched',
      'payment': 'Paid (UPI)',
      'courier': 'BlueDart Express (AWB: BD884129)',
      'items': [
        {'name': 'Durvasa Liv-Care Syrup (200ml)', 'qty': 20, 'price': 2520.0},
        {'name': 'Ashwagandha Gold Capsules (60s)', 'qty': 30, 'price': 7350.0},
        {'name': 'Durvasa Ortho Relief Oil (100ml)', 'qty': 25, 'price': 3850.0},
        {'name': 'Triphala Shuddha Churna (100gm)', 'qty': 50, 'price': 4200.0},
      ],
    },
    {
      'id': 'ORD-2026-8812',
      'date': '21 Aug 2026',
      'itemsCount': 5,
      'amount': 12300.0,
      'status': 'Delivered',
      'payment': 'Paid (NEFT)',
      'courier': 'DTDC Cargo (Delivered on 23 Aug)',
      'items': [
        {'name': 'Chyawanprash Special (1Kg)', 'qty': 20, 'price': 6300.0},
        {'name': 'Durvasa Maha Bhringraj (200ml)', 'qty': 25, 'price': 5075.0},
        {'name': 'Kuka Cough Syrup (100ml)', 'qty': 12, 'price': 924.0},
      ],
    },
    {
      'id': 'ORD-2026-8790',
      'date': '18 Aug 2026',
      'itemsCount': 3,
      'amount': 8750.0,
      'status': 'Confirmed',
      'payment': 'Pending (Credit 15 Days)',
      'courier': 'Warehouse Packing in Progress',
      'items': [
        {'name': 'Giloy Ghan Vati (60s)', 'qty': 50, 'price': 4900.0},
        {'name': 'Durvasa Liv-Care Syrup (200ml)', 'qty': 30, 'price': 3780.0},
      ],
    },
    {
      'id': 'ORD-2026-8755',
      'date': '12 Aug 2026',
      'itemsCount': 10,
      'amount': 24600.0,
      'status': 'Delivered',
      'payment': 'Paid (Cheque)',
      'courier': 'BlueDart Express (Delivered on 14 Aug)',
      'items': [
        {'name': 'Ashwagandha Gold Capsules', 'qty': 60, 'price': 14700.0},
        {'name': 'Triphala Shuddha Churna', 'qty': 80, 'price': 6720.0},
        {'name': 'Ortho Relief Oil', 'qty': 20, 'price': 3080.0},
      ],
    },
    {
      'id': 'ORD-2026-8720',
      'date': '05 Aug 2026',
      'itemsCount': 2,
      'amount': 4200.0,
      'status': 'Pending',
      'payment': 'Pending Verification',
      'courier': 'Awaiting ASM approval',
      'items': [
        {'name': 'Durvasa Maha Bhringraj Oil', 'qty': 20, 'price': 4060.0},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'dispatched':
        return Colors.blue;
      case 'confirmed':
        return AppColors.deepGold;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order['status']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Placed on ${order['date']}  •  ${order['payment']}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.creamBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Courier: ${order['courier']}',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Order Summary',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              ...((order['items'] as List<dynamic>).map((prod) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod['name'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                              Text('Qty: ${prod['qty']} units',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Text(
                          '₹${(prod['price'] as double).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ))),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                    '₹${(order['amount'] as double).toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterOrders(String tab) {
    if (tab == 'All') return _orders;
    return _orders.where((o) => o['status'].toString().toLowerCase() == tab.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['All', 'Pending', 'Confirmed', 'Dispatched', 'Delivered'];

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wholesale Orders',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryGold,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          final list = _filterOrders(tab);
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No orders found in "$tab"',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = list[index];
              return InkWell(
                onTap: () => _showOrderDetails(o),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            o['id'],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusColor(o['status']).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              o['status'],
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(o['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Date: ${o['date']}  •  ${o['itemsCount']} Products',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Amount', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                              Text(
                                '₹${(o['amount'] as double).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGreen, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
