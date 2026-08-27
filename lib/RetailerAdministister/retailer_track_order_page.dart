import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerTrackOrderPage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerTrackOrderPage({super.key, required this.retailer});

  @override
  State<RetailerTrackOrderPage> createState() => _RetailerTrackOrderPageState();
}

class _RetailerTrackOrderPageState extends State<RetailerTrackOrderPage> {
  String _selectedOrder = 'ORD-2026-8841';

  final Map<String, dynamic> _trackingData = {
    'ORD-2026-8841': {
      'status': 'In Transit (On the way)',
      'courier': 'BlueDart Surface Express',
      'awb': 'BD884129302IN',
      'estDelivery': '25 Aug 2026, by 5:00 PM',
      'origin': 'Durvasa Central Hub, Haridwar',
      'destination': 'Lucknow Medical Complex, UP',
      'currentStep': 3,
      'steps': [
        {'title': 'Order Placed', 'desc': '24 Aug, 10:15 AM - Order received & verified', 'done': true},
        {'title': 'Order Confirmed', 'desc': '24 Aug, 11:30 AM - Approved by ASM', 'done': true},
        {'title': 'Packed at Warehouse', 'desc': '24 Aug, 03:00 PM - Packed & Barcoded at Haridwar Plant', 'done': true},
        {'title': 'In Transit via BlueDart', 'desc': '24 Aug, 08:30 PM - Arrived at Regional Sorting Hub', 'done': true},
        {'title': 'Out for Delivery', 'desc': 'Expected 25 Aug, Morning', 'done': false},
        {'title': 'Delivered to Store', 'desc': 'Signature OTP verification pending', 'done': false},
      ],
    },
    'ORD-2026-8790': {
      'status': 'Warehouse Packing',
      'courier': 'DTDC Cargo Logistics',
      'awb': 'DT87901248IN',
      'estDelivery': '28 Aug 2026',
      'origin': 'Durvasa Central Hub, Haridwar',
      'destination': 'Lucknow Medical Complex, UP',
      'currentStep': 2,
      'steps': [
        {'title': 'Order Placed', 'desc': '18 Aug, 02:20 PM', 'done': true},
        {'title': 'Order Confirmed', 'desc': '19 Aug, 09:40 AM', 'done': true},
        {'title': 'Packing at Warehouse', 'desc': 'Stock allocated, batch inspection in progress', 'done': true},
        {'title': 'Handover to Courier', 'desc': 'Scheduled pickup', 'done': false},
        {'title': 'In Transit', 'desc': 'Expected dispatch', 'done': false},
        {'title': 'Delivered', 'desc': 'Pending delivery', 'done': false},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final track = _trackingData[_selectedOrder] ?? _trackingData['ORD-2026-8841'];
    final steps = track['steps'] as List<dynamic>;

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
          'Live Shipment Tracking',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Selector Chip Row
            Row(
              children: [
                Text('Select Order:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                ..._trackingData.keys.map((orderId) {
                  final isSelected = orderId == _selectedOrder;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(orderId),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: AppColors.white,
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.textDark,
                      ),
                      onSelected: (_) => setState(() => _selectedOrder = orderId),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // Live Status Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.deepGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          track['status'],
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
                        ),
                      ),
                      const Icon(Icons.local_shipping_rounded, color: AppColors.white, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AWB: ${track['awb']}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  Text(
                    'Partner: ${track['courier']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.cream.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.white.withValues(alpha: 0.2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Est. Delivery:', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.cream)),
                      Text(track['estDelivery'],
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Text(
              'Shipment Journey',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 14),

            // Timeline Steps
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
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
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  final isDone = step['done'] as bool;
                  final isLast = index == steps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
                              border: Border.all(
                                color: isDone ? AppColors.primaryGold : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.circle,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 38,
                              color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDone ? AppColors.textDark : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step['desc'],
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isDone ? AppColors.textSecondary : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
