import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../OrderPage/utils/theme_constants.dart';

class DealerSupportPage extends StatefulWidget {
  final String dealerId;
  final String dealerName;
  final String dealerPhone;

  const DealerSupportPage({
    super.key,
    required this.dealerId,
    this.dealerName = 'Dealer',
    this.dealerPhone = '',
  });

  @override
  State<DealerSupportPage> createState() => _DealerSupportPageState();
}

class _DealerSupportPageState extends State<DealerSupportPage> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedCategory = 'Order & Dispatch';

  final List<String> _categories = [
    'Order & Dispatch',
    'Payment & Ledger',
    'Damaged / Missing Goods',
    'Invoice / GST Correction',
    'New Product Inquiry',
    'Other Support',
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
          'Dealer Helpdesk & Support',
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
            // ---- Direct Helpline & Contact Card ----
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    ThemeConstants.darkGreen,
                    ThemeConstants.primaryGreen,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.primaryGreen.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeConstants.primaryGold.withOpacity(0.25),
                        ),
                        child: const Icon(Icons.support_agent, color: ThemeConstants.lightGold, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Durvasa Dealer Desk',
                              style: GoogleFonts.poppins(
                                color: ThemeConstants.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Monday - Saturday • 9:30 AM - 6:30 PM',
                              style: GoogleFonts.poppins(
                                color: ThemeConstants.white.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _callNumber('18001234500'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.primaryGold,
                            foregroundColor: ThemeConstants.darkGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.phone_in_talk, size: 18),
                          label: Text(
                            'Call Desk',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openWhatsApp('919876543210'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeConstants.white,
                            side: const BorderSide(color: ThemeConstants.primaryGold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18, color: ThemeConstants.lightGold),
                          label: Text(
                            'WhatsApp',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ---- Dedicated ASM Info Card ----
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ThemeConstants.primaryGold.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_pin, color: ThemeConstants.primaryGreen, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Dedicated Area Manager (ASM)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: ThemeConstants.textSecondary,
                          ),
                        ),
                        Text(
                          'Rajesh Verma (ASM - Central Region)',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ThemeConstants.textDark,
                          ),
                        ),
                        Text(
                          '+91 98260 11940 • asm.central@durvasaayurved.com',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: ThemeConstants.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: ThemeConstants.primaryGreen),
                    onPressed: () => _callNumber('+919826011940'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ---- Submit Support Ticket / Query ----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ThemeConstants.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
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
                  Text(
                    'Submit a Query or Dispute',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ThemeConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Query Category',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: ThemeConstants.creamBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: GoogleFonts.poppins(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Your Message / Problem Details',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _queryController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter order number, dispatch issue, or details here...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      filled: true,
                      fillColor: ThemeConstants.creamBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.primaryGreen,
                        foregroundColor: ThemeConstants.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Submit Ticket',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ---- Frequently Asked Questions ----
            Text(
              'Frequently Asked Questions (FAQ)',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeConstants.textDark,
              ),
            ),
            const SizedBox(height: 10),
            _faqTile(
              'How long does freight delivery take?',
              'Bulk orders are dispatched within 24 hours from the central factory and usually arrive within 3-5 business days depending on your location.',
            ),
            _faqTile(
              'What is the credit cycle period for registered dealers?',
              'Approved registered dealers enjoy a standard 15-day credit cycle. Timely payments increase your approved credit limit.',
            ),
            _faqTile(
              'How to claim for transit damage or leakage?',
              'Report the damaged items with photo evidence within 48 hours of delivery receipt through this Support tab or contact your ASM.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeConstants.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              answer,
              style: GoogleFonts.poppins(fontSize: 12, color: ThemeConstants.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTicket() {
    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please describe your query before submitting.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final ticketNo = 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _queryController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: ThemeConstants.primaryGreen),
            const SizedBox(width: 8),
            Text('Ticket Raised', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Your support ticket ($ticketNo) for category "$_selectedCategory" has been registered. Our dealer support team will contact you within 4 business hours.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: GoogleFonts.poppins(color: ThemeConstants.primaryGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone?text=Hello%20Durvasa%20Support,%20I%20am%20Dealer%20${widget.dealerId}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
