import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../widgets/gemini_widget.dart';

class RetailerSupportPage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerSupportPage({
    super.key,
    required this.retailer,
  });

  @override
  State<RetailerSupportPage> createState() => _RetailerSupportPageState();
}

class _RetailerSupportPageState extends State<RetailerSupportPage> {
  final _queryController = TextEditingController();

  String _selectedCategory = 'Order & Dispatch Query';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitTicket() {
    if (_queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your query details.',
            style: GoogleFonts.poppins(
              color: AppColors.white,
            ),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final ticketId =
        'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryGreen,
                size: 50,
              ),
              const SizedBox(height: 14),
              Text(
                'Support Ticket Raised!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ticket ID: $ticketId\n'
                    'Our ASM and support team will respond within 4 business hours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);

                  setState(() {
                    _queryController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // AI CHAT BUTTON
  // ==========================================
  void _openAiChat() {
    DurvasaAiAssistantSheet.show(
      context,
      retailer: widget.retailer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Helpdesk & Support',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // ASSIGNED ASM CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.deepGold,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.2,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                          color: AppColors.white.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_pin_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Assigned Territory Manager',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.cream,
                              ),
                            ),
                            Text(
                              'Rajesh Sharma (ASM)',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              'Lucknow Division • Emp ID: ASM-401',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.cream.withValues(
                                  alpha: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ASM (+91 98765 43210)...',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                  ),
                                ),
                                backgroundColor:
                                AppColors.primaryGreen,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.call,
                            size: 16,
                            color: AppColors.white,
                          ),
                          label: Text(
                            'Call ASM',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening WhatsApp chat with ASM...',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                  ),
                                ),
                                backgroundColor:
                                AppColors.primaryGreen,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.chat_rounded,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          label: Text(
                            'WhatsApp',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // RAISE SUPPORT TICKET CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.lightGold.withValues(
                    alpha: 0.35,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.05,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raise a Support Request',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    items: [
                      'Order & Dispatch Query',
                      'Invoice & Billing Issue',
                      'Damaged Bottle / Product Replacement',
                      'Payment & Ledger Reconciliation',
                      'New Product Stock Inquiry',
                    ]
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _selectedCategory = v;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Query Category',
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _queryController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                      'Describe your issue or order inquiry in detail...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryGreen,
                        foregroundColor:
                        AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Submit Support Request',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ==========================================
            // FAQs
            // ==========================================
            Text(
              'Frequently Asked Questions (FAQs)',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 10),

            _faqTile(
              'What is the minimum order quantity (MOQ)?',
              'There is no minimum bottle count for regular orders. '
                  'For free delivery, the order value must be above ₹3,000.',
            ),

            _faqTile(
              'How does the broken / leakage replacement work?',
              'If any bottle is damaged during transit, upload a photo '
                  'in the Support Ticket within 48 hours for immediate '
                  'credit note or replacement.',
            ),

            _faqTile(
              'What is the credit cycle for authorized retailers?',
              'Authorized verified retailers receive a 15-day '
                  'interest-free credit period on approval by the '
                  'territory ASM.',
            ),
          ],
        ),
      ),

      // ==========================================
      // AI CHAT LOTTIE BUTTON
      // ==========================================
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(
                alpha: 0.25,
              ),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openAiChat,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Lottie.asset(
                'assets/Ai chat.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }

  // ==========================================
  // FAQ TILE
  // ==========================================
  Widget _faqTile(
      String question,
      String answer,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGold.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              14,
            ),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}