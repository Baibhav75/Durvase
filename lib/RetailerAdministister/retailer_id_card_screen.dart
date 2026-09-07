import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';

class RetailerIdCardScreen extends StatelessWidget {
  final RetailerModel retailer;

  const RetailerIdCardScreen({super.key, required this.retailer});

  @override
  Widget build(BuildContext context) {
    final personName = retailer.personName.isNotEmpty
        ? retailer.personName
        : (retailer.name.isNotEmpty ? retailer.name : 'Rahul Kumar');
    final businessName = retailer.businessName.isNotEmpty
        ? retailer.businessName
        : 'Durvasa Ayurveda Store';
    final visiterId = retailer.visiterId.isNotEmpty
        ? retailer.visiterId
        : (retailer.retailerId.isNotEmpty ? retailer.retailerId : 'VTR107086');
    final phone = retailer.phone.isNotEmpty ? retailer.phone : '+91 9123456788';
    final address = retailer.address.isNotEmpty
        ? retailer.address
        : (retailer.businessAddress.isNotEmpty ? retailer.businessAddress : 'Main Market, Sector 18');
    final photoUrl = retailer.fullPhotoUrl;
    final empType = retailer.empType.isNotEmpty ? retailer.empType : 'Permanent';
    final purpose = retailer.purpose.isNotEmpty ? retailer.purpose : 'Retailer';

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
          'Retailer Identity Card',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Digital ID Card Container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Card Top Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.deepGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: const Icon(Icons.spa_rounded, color: AppColors.primaryGreen, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DURVASA AYURVED',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'AUTHORIZED $purpose'.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.lightGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'VERIFIED',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card Body
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            height: 78,
                            width: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.creamBackground,
                              border: Border.all(color: AppColors.primaryGold, width: 2),
                            ),
                            child: photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.primaryGreen,
                                        size: 38,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 38),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            personName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (businessName.isNotEmpty && businessName != personName)
                            Text(
                              businessName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Visiter ID: $visiterId',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepGold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 8),

                          _idRow('Contact:', phone),
                          _idRow('Location:', address),
                          _idRow('Role / Purpose:', purpose),
                          _idRow('Type:', empType),
                          if (retailer.visitFor.isNotEmpty)
                            _idRow('Visit For:', retailer.visitFor),
                          _idRow('Status:', 'Active Partner'),


                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.creamBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_2_rounded, size: 32, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Text(
                                  'Scan to Verify Retailer Certificate',
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ID Card saved to gallery!', style: GoogleFonts.poppins(color: AppColors.white)),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text('Download ID Card', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _idRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}
