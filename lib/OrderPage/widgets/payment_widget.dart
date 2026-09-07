import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';

enum CheckoutPaymentType { cod, upi, online }

class PaymentWidget extends StatelessWidget {
  final CheckoutPaymentType selectedPaymentType;
  final ValueChanged<CheckoutPaymentType> onPaymentTypeChanged;
  final TextEditingController upiIdController;
  final VoidCallback? onUpiChanged;

  const PaymentWidget({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
    required this.upiIdController,
    this.onUpiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose your preferred payment method:",
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Cash on Delivery (COD) Option
          _buildPaymentOptionTile(
            type: CheckoutPaymentType.cod,
            icon: Icons.local_shipping_outlined,
            title: "Cash on Delivery (COD)",
            subtitle: "Pay cash at the time of delivery to your doorstep",
            badgeText: "Popular",
            badgeColor: AppColors.primaryGreen,
          ),

          const SizedBox(height: 10),

          // 2. UPI ID / VPA Option
          _buildPaymentOptionTile(
            type: CheckoutPaymentType.upi,
            icon: Icons.qr_code_scanner_rounded,
            title: "UPI ID / VPA",
            subtitle: "Pay via Google Pay, PhonePe, Paytm, BHIM UPI",
            badgeText: "Instant UPI",
            badgeColor: AppColors.deepGold,
          ),

          // UPI ID Input Box (expanded when UPI is selected)
          if (selectedPaymentType == CheckoutPaymentType.upi) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 6),
                      Text(
                        "Enter UPI ID / VPA Handle",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                    ),
                    child: TextField(
                      controller: upiIdController,
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: "e.g. 9876543210@paytm or name@oksbi",
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.alternate_email, size: 18, color: AppColors.primaryGreen),
                        suffixIcon: upiIdController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                                onPressed: () {
                                  upiIdController.clear();
                                  onUpiChanged?.call();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      onChanged: (_) => onUpiChanged?.call(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quick UPI Handle Suffix Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildUpiSuffixChip("@oksbi"),
                      _buildUpiSuffixChip("@paytm"),
                      _buildUpiSuffixChip("@ybl"),
                      _buildUpiSuffixChip("@okaxis"),
                      _buildUpiSuffixChip("@okicici"),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // 3. Online Payment (Razorpay) Option
          _buildPaymentOptionTile(
            type: CheckoutPaymentType.online,
            icon: Icons.credit_card_rounded,
            title: "Online Payment (Razorpay)",
            subtitle: "Credit/Debit Cards, NetBanking, UPI Gateway",
            badgeText: "100% Secure",
            badgeColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required CheckoutPaymentType type,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = selectedPaymentType == type;

    return InkWell(
      onTap: () => onPaymentTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.06) : AppColors.creamBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.5),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGold,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.primaryGreen).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: badgeColor ?? AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGold,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiSuffixChip(String suffix) {
    return GestureDetector(
      onTap: () {
        final current = upiIdController.text.trim();
        final atIndex = current.indexOf('@');
        final base = atIndex >= 0 ? current.substring(0, atIndex) : current;
        upiIdController.text = (base.isNotEmpty ? base : "user") + suffix;
        upiIdController.selection = TextSelection.fromPosition(
          TextPosition(offset: upiIdController.text.length),
        );
        onUpiChanged?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.35)),
        ),
        child: Text(
          suffix,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }
}
