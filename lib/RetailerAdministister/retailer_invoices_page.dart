import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerInvoicesPage extends StatelessWidget {
  final RetailerModel retailer;

  const RetailerInvoicesPage({super.key, required this.retailer});

  final List<Map<String, dynamic>> _invoices = const [
    {
      'invNo': 'INV-DA-2026-1049',
      'date': '22 Aug 2026',
      'orderId': 'ORD-2026-8841',
      'taxable': 16473.21,
      'gst': 1976.79,
      'total': 18450.0,
      'status': 'Paid',
    },
    {
      'invNo': 'INV-DA-2026-0982',
      'date': '21 Aug 2026',
      'orderId': 'ORD-2026-8812',
      'taxable': 10982.14,
      'gst': 1317.86,
      'total': 12300.0,
      'status': 'Paid',
    },
    {
      'invNo': 'INV-DA-2026-0931',
      'date': '18 Aug 2026',
      'orderId': 'ORD-2026-8790',
      'taxable': 7812.50,
      'gst': 937.50,
      'total': 8750.0,
      'status': 'Payment Due',
    },
    {
      'invNo': 'INV-DA-2026-0880',
      'date': '12 Aug 2026',
      'orderId': 'ORD-2026-8755',
      'taxable': 21964.28,
      'gst': 2635.72,
      'total': 24600.0,
      'status': 'Paid',
    },
  ];

  void _showInvoiceModal(BuildContext context, Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'GST Tax Invoice',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice No: ${inv['invNo']}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Text('Order Ref: ${inv['orderId']} • Date: ${inv['date']}',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
            const Divider(height: 20),
            _row('Taxable Amount:', '₹${inv['taxable'].toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            _row('GST (12% Ayurvedic):', '₹${inv['gst'].toStringAsFixed(2)}'),
            const Divider(height: 20),
            _row('Grand Total:', '₹${inv['total'].toStringAsFixed(2)}', isBold: true),
            const SizedBox(height: 10),
            Text('GSTIN: 09AABCD1234E1Z5\nDurvasa Ayurved Pharmaceuticals Pvt. Ltd.',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Downloading ${inv['invNo']}.pdf...', style: GoogleFonts.poppins(color: AppColors.white)),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: Text('Download PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, color: isBold ? AppColors.textDark : AppColors.textSecondary, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: isBold ? 14 : 12,
                color: isBold ? AppColors.primaryGreen : AppColors.textDark,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Tax Invoices & Bills',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: _invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final inv = _invoices[index];
          final isPaid = inv['status'] == 'Paid';

          return Container(
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
                      inv['invNo'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isPaid ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        inv['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Date: ${inv['date']}  •  Order ID: ${inv['orderId']}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice Total (Incl. GST)', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                        Text(
                          '₹${(inv['total'] as double).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showInvoiceModal(context, inv),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: Text('View Bill', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
