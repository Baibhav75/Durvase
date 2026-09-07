import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../OrderPage/utils/theme_constants.dart';

class DealerTrackOrderPage extends StatefulWidget {
  final String dealerId;

  const DealerTrackOrderPage({
    super.key,
    required this.dealerId,
  });

  @override
  State<DealerTrackOrderPage> createState() => _DealerTrackOrderPageState();
}

class _DealerTrackOrderPageState extends State<DealerTrackOrderPage> {
  final List<Map<String, dynamic>> _activeShipments = [
    {
      'orderId': 'ORD-54219',
      'orderDate': '26 Aug 2026',
      'estDelivery': '01 Sep 2026',
      'status': 'In Transit',
      'currentStep': 3, // 0: Placed, 1: Confirmed, 2: Dispatched, 3: In Transit, 4: Delivered
      'courier': 'VRL Logistics Express',
      'trackingNo': 'VRL-908219401',
      'itemsCount': 8,
      'totalAmount': 45200.0,
      'destination': 'Durvasa Regional Hub, Indore (M.P.)',
      'milestones': [
        {'title': 'Order Placed', 'time': '26 Aug, 10:30 AM', 'done': true},
        {'title': 'Warehouse Packaging Done', 'time': '27 Aug, 02:15 PM', 'done': true},
        {'title': 'Dispatched via VRL Cargo', 'time': '28 Aug, 08:00 PM', 'done': true},
        {'title': 'Arrived at Transit Hub (Bhopal)', 'time': '30 Aug, 06:45 AM', 'done': true},
        {'title': 'Out for Delivery to Dealer Store', 'time': 'Expected 01 Sep', 'done': false},
        {'title': 'Delivered', 'time': 'Expected 01 Sep', 'done': false},
      ],
    },
    {
      'orderId': 'ORD-53902',
      'orderDate': '21 Aug 2026',
      'estDelivery': '25 Aug 2026',
      'status': 'Delivered',
      'currentStep': 5,
      'courier': 'Delhivery Surface Cargo',
      'trackingNo': 'DEL-44910284',
      'itemsCount': 5,
      'totalAmount': 28500.0,
      'destination': 'Durvasa Ayurvedic Agency, Jabalpur',
      'milestones': [
        {'title': 'Order Placed', 'time': '21 Aug, 11:00 AM', 'done': true},
        {'title': 'Dispatched', 'time': '22 Aug, 04:00 PM', 'done': true},
        {'title': 'Delivered Successfully', 'time': '25 Aug, 03:30 PM', 'done': true},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.creamBackground,
      appBar: AppBar(
        backgroundColor: ThemeConstants.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Consignments & Orders',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ThemeConstants.white,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _activeShipments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final shipment = _activeShipments[index];
          final isInTransit = shipment['status'] == 'In Transit';

          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ThemeConstants.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ThemeConstants.primaryGold.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ThemeConstants.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isInTransit ? Icons.local_shipping : Icons.check_circle,
                            color: ThemeConstants.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipment['orderId'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: ThemeConstants.textDark,
                              ),
                            ),
                            Text(
                              'Placed on: ${shipment['orderDate']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: ThemeConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isInTransit ? Colors.blue : Colors.green).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        shipment['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isInTransit ? Colors.blue.shade800 : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),

                // Courier details box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeConstants.creamBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: ThemeConstants.primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carrier: ${shipment['courier']}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            Text(
                              'AWB / Docket: ${shipment['trackingNo']}',
                              style: GoogleFonts.poppins(fontSize: 11, color: ThemeConstants.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Est: ${shipment['estDelivery']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: ThemeConstants.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Milestone Stepper
                Text(
                  'Shipment Timeline',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeConstants.textDark,
                  ),
                ),
                const SizedBox(height: 10),

                ...List.generate(
                  (shipment['milestones'] as List).length,
                  (mIndex) {
                    final m = shipment['milestones'][mIndex];
                    final isDone = m['done'] == true;
                    final isLast = mIndex == (shipment['milestones'] as List).length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 18,
                              width: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone ? ThemeConstants.primaryGreen : Colors.grey.shade300,
                              ),
                              child: Icon(
                                isDone ? Icons.check : Icons.circle,
                                size: 12,
                                color: ThemeConstants.white,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 30,
                                color: isDone ? ThemeConstants.primaryGreen : Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['title'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 13,
                                    color: isDone ? ThemeConstants.textDark : ThemeConstants.textSecondary,
                                  ),
                                ),
                                Text(
                                  m['time'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: ThemeConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
