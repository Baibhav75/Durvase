import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel.dart';
import '../model/TodoModel1.dart';
import '../model/asm_profile_model.dart';

/// DurvasaIdCardWidget renders the official Durvasa Ayurved Employee ID Card
/// matching the exact physical ID card design with botanical watermarks,
/// metallic gold ribbons, official badges, QR verification code, and luxury seal.
class DurvasaIdCardWidget extends StatelessWidget {
  final TodoModel? userData;
  final Data1? employeeData;
  final AsmProfileModel? asmProfile;
  final String? customName;
  final String? customDesignation;
  final String? customEmpId;
  final String? customJoiningDate;
  final String? customPhone;
  final String? customEmail;
  final String? customOffice;
  final String? customPhotoUrl;
  final double scale;

  const DurvasaIdCardWidget({
    super.key,
    this.userData,
    this.employeeData,
    this.asmProfile,
    this.customName,
    this.customDesignation,
    this.customEmpId,
    this.customJoiningDate,
    this.customPhone,
    this.customEmail,
    this.customOffice,
    this.customPhotoUrl,
    this.scale = 1.0,
  });

  static String? _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    const baseUrl = 'https://durvasaayurved.online';
    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }

  // Resolved dynamic values with live profile binding & fallbacks
  String get name =>
      customName ??
      asmProfile?.name ??
      employeeData?.name ??
      userData?.name ??
      "RAHUL KUMAR";

  String get designation =>
      customDesignation ??
      (asmProfile != null ? 'AREA SALES MANAGER' : null) ??
      employeeData?.employeeType ??
      userData?.employeeType ??
      "HR EXECUTIVE";

  String get empId =>
      customEmpId ??
      asmProfile?.uniqueId ??
      (asmProfile?.asmId != null ? 'ASM${asmProfile!.asmId.toString().padLeft(3, '0')}' : null) ??
      employeeData?.employeeCode ??
      employeeData?.empId ??
      userData?.empId ??
      "DAPL/HR/2025/017";

  String get joiningDate {
    final raw = customJoiningDate ??
        asmProfile?.joiningDate ??
        employeeData?.joinDate ??
        employeeData?.createdAt;

    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final parsed = DateTime.parse(raw.trim());
        const months = [
          'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
          'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
        ];
        return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
      } catch (_) {
        return raw;
      }
    }
    return "15 MAY 2025";
  }

  String get phone =>
      customPhone ??
      asmProfile?.mobile ??
      employeeData?.mobile ??
      userData?.mobile ??
      "+91 98765 43210";

  String get email =>
      customEmail ??
      asmProfile?.email ??
      employeeData?.email ??
      userData?.email ??
      "rahul.kumar@durvasaayurved.com";

  String get office =>
      customOffice ??
      "A 61, Noida Sector 16, Gautam Buddha Nagar, U.P. 201301";

  String get bloodGroup =>
      asmProfile?.bloodGroup ??
      asmProfile?.billedGroup ??
      "";

  String get emergencyNo =>
      asmProfile?.emergenceNo ??
      asmProfile?.emergencyNo ??
      "";

  String? get photoUrl => _resolveImageUrl(
        customPhotoUrl ??
            asmProfile?.profileImage ??
            employeeData?.image,
      );

  @override
  Widget build(BuildContext context) {
    // Base card dimensions (Width: 380, Height: 600 -> standard ID Card ratio ~1:1.58)
    const double cardWidth = 380;
    const double cardHeight = 590;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 25,
              spreadRadius: 3,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Subtle Botanical Leaf Watermark Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _BotanicalWatermarkPainter(),
                ),
              ),

              // 2. Main Card Content Stack
              Column(
                children: [
                  // --- TOP SECTION (Lanyard Slot + Header + Brand Banner) ---
                  _buildHeaderSection(),

                  // --- MIDDLE SECTION (Waves + Avatar + Badges + QR) ---
                  _buildMidAvatarSection(),

                  // --- DETAILS SECTION (Name + Role + Info Table) ---
                  Expanded(
                    child: _buildEmployeeInfoSection(),
                  ),

                  // --- BOTTOM SECTION (Waves + Signature + Seal + Footer) ---
                  _buildBottomSection(),
                ],
              ),

              // 3. Top Right "TRUSTED AYURVEDA SINCE 2021" Ribbon
              Positioned(
                top: 0,
                right: 22,
                child: _buildTrustedRibbon(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP HEADER SECTION
  // ==========================================
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 6, bottom: 4),
      child: Column(
        children: [
          // Lanyard punch hole slot
          Center(
            child: Container(
              width: 54,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Brand Logo + Titles
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Icon
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/appiconwithoutbackground.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/playstore.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/durvasa_logo.png');
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Brand Title & Slogan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DURVASA",
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      letterSpacing: 2.0,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "AYURVED PVT. LTD.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      letterSpacing: 0.8,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        "HEALTHY TODAY",
                        style: GoogleFonts.poppins(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryGreen,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      Text(
                        "NATURAL TOMORROW",
                        style: GoogleFonts.poppins(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryGreen,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP RIGHT TRUSTED RIBBON
  // ==========================================
  Widget _buildTrustedRibbon() {
    return Container(
      width: 62,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: const Border(
          left: BorderSide(color: AppColors.primaryGold, width: 1.5),
          right: BorderSide(color: AppColors.primaryGold, width: 1.5),
          bottom: BorderSide(color: AppColors.primaryGold, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(
            "TRUSTED",
            style: GoogleFonts.poppins(
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              color: AppColors.lightGold,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            "AYURVEDA",
            style: GoogleFonts.poppins(
              fontSize: 6.5,
              fontWeight: FontWeight.w700,
              color: AppColors.lightGold,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            "SINCE",
            style: GoogleFonts.poppins(
              fontSize: 6.0,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            "2019",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          const Icon(
            Icons.eco,
            color: AppColors.primaryGold,
            size: 11,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MID AVATAR & METALLIC WAVE SECTION
  // ==========================================
  Widget _buildMidAvatarSection() {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Deep Green Wave with Gold Trim
          Positioned.fill(
            child: CustomPaint(
              painter: _MidWavePainter(),
            ),
          ),

          // Left "AYURVEDA FOR ALL" Badge
          Positioned(
            left: 20,
            top: 42,
            child: _buildAyurvedaBadge(),
          ),

          // Right QR Code Card


          // Center Avatar with Luxury Gold Frame
          Positioned(
            top: 20,
            child: Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightGold,
                    AppColors.primaryGold,
                    AppColors.deepGold,
                    AppColors.primaryGold,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3.5), // Outer gold ring
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                padding: const EdgeInsets.all(2.5), // White divider ring
                child: ClipOval(
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFEAEFF0),
      child: const Icon(
        Icons.person,
        size: 70,
        color: AppColors.primaryGreen,
      ),
    );
  }

  // Left Ayurveda For All Badge
  Widget _buildAyurvedaBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkGreen,
        border: Border.all(
          color: AppColors.primaryGold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dotted outer circular track
          CustomPaint(
            size: const Size(40, 40),
            painter: _DottedCirclePainter(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "AYURVEDA",
                style: GoogleFonts.poppins(
                  fontSize: 5.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 1),
              const Icon(
                Icons.eco,
                color: AppColors.white,
                size: 13,
              ),
              const SizedBox(height: 1),
              Text(
                "FOR ALL",
                style: GoogleFonts.poppins(
                  fontSize: 5.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Right QR Code Card Widget


  // ==========================================
  // EMPLOYEE INFO SECTION
  // ==========================================
  Widget _buildEmployeeInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Column(
        children: [
          const SizedBox(height: 2),

          // Employee Full Name
          Text(
            name.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Designation
          Text(
            designation.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.deepGold,
              letterSpacing: 2.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Info Table
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: "EMPLOYEE ID",
            value: empId,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            label: "DATE OF JOINING",
            value: joiningDate,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.phone,
            label: "PHONE",
            value: phone,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: "EMAIL",
            value: email,
          ),
          _buildDivider(),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: "OFFICE",
            value: office,
            maxLines: 2,
          ),
          if (bloodGroup.isNotEmpty && bloodGroup != 'Not available') ...[
            _buildDivider(),
            _buildInfoRow(
              icon: Icons.bloodtype_outlined,
              label: "BLOOD GROUP",
              value: bloodGroup,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Icon(
              icon,
              size: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),

          // Label
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Colon
          Text(
            ":  ",
            style: GoogleFonts.poppins(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),

          // Value
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.15,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left:1),
      height: 0,
      color: const Color(0xFFE2E8E4),
    );
  }

  // ==========================================
  // BOTTOM SIGNATURE & SEAL SECTION + FOOTER
  // ==========================================
  Widget _buildBottomSection() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          // Bottom Green Wave Arc with Gold Border
          Positioned.fill(
            child: CustomPaint(
              painter: _BottomWavePainter(),
            ),
          ),

          // Authorised Signatory (Center Left)
          Positioned(
            left: 0,
            right: 0,
            top: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Anand sir",
                  style: GoogleFonts.sacramento(
                    fontSize: 26,
                    color: AppColors.cream,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "AUTHORISED SIGNATORY",
                  style: GoogleFonts.poppins(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Luxury Gold Medal Seal (Bottom Right)
          Positioned(
            right: 22,
            top: 8,
            child: _buildLuxurySeal(),
          ),

          // Bottom Obsidian Green Footer Strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 26,
              color: const Color(0xFF03190C),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: AppColors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "www.durvasaayurved.com",
                    style: GoogleFonts.poppins(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 10,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                  const Icon(Icons.phone, color: AppColors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "6299812692",
                    style: GoogleFonts.poppins(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Luxury Gold Seal Widget
  Widget _buildLuxurySeal() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            AppColors.lightGold,
            AppColors.primaryGold,
            AppColors.deepGold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkGreen,
          border: Border.all(
            color: AppColors.lightGold,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3 Gold Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, color: AppColors.primaryGold, size: 5),
                Icon(Icons.star, color: AppColors.primaryGold, size: 6.5),
                Icon(Icons.star, color: AppColors.primaryGold, size: 5),
              ],
            ),
            const SizedBox(height: 1),
            Text(
              "WE CARE",
              style: GoogleFonts.poppins(
                fontSize: 4.8,
                fontWeight: FontWeight.w800,
                color: AppColors.cream,
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
            Text(
              "FOR YOUR",
              style: GoogleFonts.poppins(
                fontSize: 4.5,
                fontWeight: FontWeight.w700,
                color: AppColors.cream,
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
            Text(
              "WELLNESS",
              style: GoogleFonts.poppins(
                fontSize: 4.8,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGold,
                letterSpacing: 0.3,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 1),
            const Icon(
              Icons.eco,
              color: AppColors.primaryGold,
              size: 8,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTERS FOR EXACT VISUAL MATCH
// ==========================================

/// Paints subtle Ayurvedic leaf watermark silhouettes on the background
class _BotanicalWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8F1EC).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Top-left leaf watermark cluster
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.12, size.height * 0.18),
      width: 45,
      height: 75,
    ));
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.22, size.height * 0.15),
      width: 35,
      height: 60,
    ));

    // Top-right leaf watermark cluster
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.88, size.height * 0.18),
      width: 45,
      height: 75,
    ));
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.78, size.height * 0.15),
      width: 35,
      height: 60,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the dynamic deep green & gold waves in the middle section
class _MidWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    final goldRibbonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.lightGold,
          AppColors.primaryGold,
          AppColors.deepGold,
          AppColors.lightGold,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Deep Green Wave Fill
    final fillPath = Path();
    fillPath.moveTo(0, size.height * 0.25);
    fillPath.cubicTo(
      size.width * 0.28, size.height * 0.22,
      size.width * 0.38, size.height * 0.95,
      size.width * 0.5, size.height * 0.95,
    );
    fillPath.cubicTo(
      size.width * 0.62, size.height * 0.95,
      size.width * 0.72, size.height * 0.22,
      size.width, size.height * 0.25,
    );
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, wavePaint);

    // Golden Ribbon Trim along the upper edge
    final goldPath = Path();
    goldPath.moveTo(0, size.height * 0.25);
    goldPath.cubicTo(
      size.width * 0.28, size.height * 0.22,
      size.width * 0.38, size.height * 0.95,
      size.width * 0.5, size.height * 0.95,
    );
    goldPath.cubicTo(
      size.width * 0.62, size.height * 0.95,
      size.width * 0.72, size.height * 0.22,
      size.width, size.height * 0.25,
    );

    canvas.drawPath(goldPath, goldRibbonPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the bottom deep green wave with golden metallic border
class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wavePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    final goldTrimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.lightGold,
          AppColors.primaryGold,
          AppColors.deepGold,
          AppColors.lightGold,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final fillPath = Path();
    fillPath.moveTo(0, size.height * 0.65);
    fillPath.cubicTo(
      size.width * 0.35, size.height * 0.15,
      size.width * 0.65, size.height * 0.15,
      size.width, size.height * 0.65,
    );
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, wavePaint);

    final trimPath = Path();
    trimPath.moveTo(0, size.height * 0.65);
    trimPath.cubicTo(
      size.width * 0.35, size.height * 0.15,
      size.width * 0.65, size.height * 0.15,
      size.width, size.height * 0.65,
    );

    canvas.drawPath(trimPath, goldTrimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints a dotted circle track for the circular badge
class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final double radius = size.width / 2;
    const int dotCount = 20;

    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 2 * math.pi) / dotCount;
      final double x = radius + radius * 0.88 * math.cos(angle);
      final double y = radius + radius * 0.88 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
