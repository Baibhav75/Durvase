import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../OrderPage/utils/theme_constants.dart';

class DealerInvoicesPage extends StatefulWidget {
  final String dealerId;

  const DealerInvoicesPage({
    super.key,
    required this.dealerId,
  });

  @override
  State<DealerInvoicesPage> createState() => _DealerInvoicesPageState();
}

class _DealerInvoicesPageState extends State<DealerInvoicesPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _invoices = [
    {
      'invoiceNo': 'INV-2026-0891',
      'orderId': 'ORD-54219',
      'date': '26 Aug 2026',
      'dueDate': '10 Sep 2026',
      'taxableAmount': 38305.0,
      'gstAmount': 6895.0,
      'totalAmount': 45200.0,
      'status': 'Paid',
    },
    {
      'invoiceNo': 'INV-2026-0842',
      'orderId': 'ORD-53902',
      'date': '19 Aug 2026',
      'dueDate': '03 Sep 2026',
      'taxableAmount': 24152.5,
      'gstAmount': 4347.5,
      'totalAmount': 28500.0,
      'status': 'Paid',
    },
    {
      'invoiceNo': 'INV-2026-0790',
      'orderId': 'ORD-53100',
      'date': '12 Aug 2026',
      'dueDate': '27 Aug 2026',
      'taxableAmount': 52542.3,
      'gstAmount': 9457.7,
      'totalAmount': 62000.0,
      'status': 'Paid',
    },
    {
      'invoiceNo': 'INV-2026-0715',
      'orderId': 'ORD-52110',
      'date': '29 Jul 2026',
      'dueDate': '15 Aug 2026',
      'taxableAmount': 29237.0,
      'gstAmount': 5263.0,
      'totalAmount': 34500.0,
      'status': 'Pending',
    },
    {
      'invoiceNo': 'INV-2026-0688',
      'orderId': 'ORD-51900',
      'date': '15 Jul 2026',
      'dueDate': '30 Jul 2026',
      'taxableAmount': 18644.0,
      'gstAmount': 3356.0,
      'totalAmount': 22000.0,
      'status': 'Overdue',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedFilter == 'All'
        ? _invoices
        : _invoices.where((i) => i['status'] == _selectedFilter).toList();

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
          'Tax Invoices & GST',
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
            // ---- Filter Badges ----
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Paid', 'Pending', 'Overdue'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? ThemeConstants.white : ThemeConstants.textDark,
                      ),
                      selectedColor: ThemeConstants.primaryGreen,
                      backgroundColor: ThemeConstants.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ---- Invoice Cards ----
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final inv = filteredList[index];
                final status = inv['status'];
                final isPaid = status == 'Paid';
                final isOverdue = status == 'Overdue';

                final Color badgeColor = isPaid
                    ? Colors.green
                    : isOverdue
                        ? Colors.red
                        : Colors.orange;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeConstants.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ThemeConstants.primaryGold.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ThemeConstants.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.description_outlined,
                                  color: ThemeConstants.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv['invoiceNo'],
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: ThemeConstants.textDark,
                                    ),
                                  ),
                                  Text(
                                    'Order: ${inv['orderId']}',
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
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade200, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${inv['date']}',
                                  style: GoogleFonts.poppins(fontSize: 11, color: ThemeConstants.textSecondary)),
                              Text('GST (18%): ₹ ${inv['gstAmount'].toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontSize: 11, color: ThemeConstants.textSecondary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Amount',
                                  style: GoogleFonts.poppins(fontSize: 11, color: ThemeConstants.textSecondary)),
                              Text(
                                '₹ ${inv['totalAmount'].toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: ThemeConstants.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _viewInvoiceDetails(inv),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeConstants.primaryGreen,
                                side: const BorderSide(color: ThemeConstants.primaryGreen),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: Text('View', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadInvoice(inv['invoiceNo']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeConstants.primaryGreen,
                                foregroundColor: ThemeConstants.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.download, size: 16),
                              label: Text('PDF', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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

  void _viewInvoiceDetails(Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt, color: ThemeConstants.primaryGreen),
            const SizedBox(width: 8),
            Text(inv['invoiceNo'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rowDetail('Order ID', inv['orderId']),
            _rowDetail('Invoice Date', inv['date']),
            _rowDetail('Due Date', inv['dueDate']),
            _rowDetail('Taxable Value', '₹ ${inv['taxableAmount']}'),
            _rowDetail('CGST + SGST (18%)', '₹ ${inv['gstAmount']}'),
            const Divider(),
            _rowDetail('Grand Total', '₹ ${inv['totalAmount']}', isBold: true),
            _rowDetail('Payment Status', inv['status'], isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: ThemeConstants.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _rowDetail(String title, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: ThemeConstants.textSecondary)),
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isBold ? ThemeConstants.primaryGreen : ThemeConstants.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(String invNo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $invNo PDF...', style: GoogleFonts.poppins(color: ThemeConstants.white)),
        backgroundColor: ThemeConstants.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
