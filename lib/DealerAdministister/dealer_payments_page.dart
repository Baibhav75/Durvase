import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../OrderPage/utils/theme_constants.dart';

class DealerPaymentsPage extends StatefulWidget {
  final String dealerId;

  const DealerPaymentsPage({
    super.key,
    required this.dealerId,
  });

  @override
  State<DealerPaymentsPage> createState() => _DealerPaymentsPageState();
}

class _DealerPaymentsPageState extends State<DealerPaymentsPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN-90821',
      'orderId': 'ORD-54219',
      'date': '28 Aug 2026',
      'amount': 45200.0,
      'mode': 'NEFT / Bank Transfer',
      'status': 'Success',
      'refNo': 'UTR8923019842',
    },
    {
      'id': 'TXN-90410',
      'orderId': 'ORD-53902',
      'date': '21 Aug 2026',
      'amount': 28500.0,
      'mode': 'UPI Payment',
      'status': 'Success',
      'refNo': 'UPI-7749021849',
    },
    {
      'id': 'TXN-89820',
      'orderId': 'ORD-53100',
      'date': '15 Aug 2026',
      'amount': 62000.0,
      'mode': 'Cheque (Clearance)',
      'status': 'Success',
      'refNo': 'CHQ-002910',
    },
    {
      'id': 'TXN-89301',
      'orderId': 'ORD-52840',
      'date': '08 Aug 2026',
      'amount': 15000.0,
      'mode': 'Razorpay Online',
      'status': 'Success',
      'refNo': 'pay_M98kL20491',
    },
    {
      'id': 'TXN-88910',
      'orderId': 'ORD-52110',
      'date': '01 Aug 2026',
      'amount': 34500.0,
      'mode': 'NEFT / RTGS',
      'status': 'Pending',
      'refNo': 'UTR1094850123',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == 'All'
        ? _transactions
        : _transactions.where((t) => t['status'] == _selectedFilter).toList();

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
          'Payments & Ledger',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ThemeConstants.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Outstanding Balance Card ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeConstants.darkGreen,
                    ThemeConstants.primaryGreen,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
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
                        'Total Outstanding Due',
                        style: GoogleFonts.poppins(
                          color: ThemeConstants.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeConstants.primaryGold.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeConstants.primaryGold),
                        ),
                        child: Text(
                          'Credit Limit: ₹2,50,000',
                          style: GoogleFonts.poppins(
                            color: ThemeConstants.lightGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ 34,500.00',
                    style: GoogleFonts.poppins(
                      color: ThemeConstants.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: ThemeConstants.white.withOpacity(0.2), height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paid This Month',
                              style: GoogleFonts.poppins(
                                color: ThemeConstants.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹ 1,35,700',
                              style: GoogleFonts.poppins(
                                color: ThemeConstants.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showPayNowSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryGold,
                          foregroundColor: ThemeConstants.darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.payment, size: 18),
                        label: Text(
                          'Pay Due',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ---- Transaction Filters ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeConstants.textDark,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: ThemeConstants.primaryGreen),
                  items: ['All', 'Success', 'Pending']
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(
                              val,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeConstants.primaryGreen,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFilter = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ---- Transactions List ----
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isSuccess = item['status'] == 'Success';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ThemeConstants.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: (isSuccess ? ThemeConstants.primaryGreen : Colors.orange)
                              .withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_circle_outline : Icons.access_time,
                          color: isSuccess ? ThemeConstants.primaryGreen : Colors.orange.shade800,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['mode'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: ThemeConstants.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ref: ${item['refNo']} • ${item['date']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: ThemeConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹ ${item['amount'].toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isSuccess ? ThemeConstants.primaryGreen : Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isSuccess ? Colors.green : Colors.orange).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['status'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSuccess ? Colors.green.shade800 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPayNowSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pay Outstanding Dues',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ThemeConstants.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select payment method to clear pending dues (₹34,500.00)',
              style: GoogleFonts.poppins(fontSize: 13, color: ThemeConstants.textSecondary),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.qr_code_2, color: ThemeConstants.primaryGreen, size: 30),
              title: Text('UPI / QR Code', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('Instant confirmation', style: GoogleFonts.poppins(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _showSuccessNotice('UPI payment gateway will open.');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_balance, color: ThemeConstants.primaryGreen, size: 30),
              title: Text('Bank Transfer (NEFT / RTGS)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text('A/C: 50200084920194 • HDFC000189', style: GoogleFonts.poppins(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _showSuccessNotice('Bank details copied to clipboard.');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSuccessNotice(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: ThemeConstants.white)),
        backgroundColor: ThemeConstants.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
