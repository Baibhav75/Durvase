import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../model/TodoModel.dart';
import '../model/TodoModel1.dart';
import '../model/asm_profile_model.dart';
import '../service/api_serviceProfile.dart';
import '../service/asm_profile_service.dart';
import '../service/id_card_pdf_service.dart';
import '../widgets/id_card_widget.dart';

class IdCardScreen extends StatefulWidget {
  final TodoModel userData;

  const IdCardScreen({super.key, required this.userData});

  @override
  State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  final GlobalKey _cardBoundaryKey = GlobalKey();
  TodoModel1? _profileData;
  AsmProfileModel? _asmProfile;
  bool _isLoading = false;
  bool _isGeneratingPdf = false;

  bool get _isAsm {
    final type = widget.userData.employeeType?.toLowerCase() ?? '';
    return type.contains('asm') || type.contains('ams') || widget.userData.asmId != null;
  }

  int get _resolvedAsmId {
    final rawId = widget.userData.asmId ?? widget.userData.empId ?? '1';
    return int.tryParse(rawId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. If ASM, fetch ASM Profile
      if (_isAsm) {
        try {
          final asm = await AsmProfileService.getAsmProfile(_resolvedAsmId);
          if (mounted) {
            setState(() {
              _asmProfile = asm;
            });
          }
        } catch (e) {
          debugPrint("Error fetching ASM profile in ID Card: $e");
        }
      }

      // 2. Also fetch regular employee profile if mobile exists
      final mobile = widget.userData.mobile;
      if (mobile != null && mobile.isNotEmpty) {
        if (ApiService.isProfileCached(mobile)) {
          final cached = await ApiService.fetchProfile(mobile);
          if (mounted) {
            setState(() {
              _profileData = cached;
            });
          }
        } else {
          final profile = await ApiService.fetchProfile(mobile);
          if (mounted) {
            setState(() {
              _profileData = profile;
            });
          }
        }
      }
    } catch (e) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Generate, save, and share PDF (via WhatsApp or standard share sheet)
  Future<void> _exportAndSharePdf({bool toWhatsApp = false}) async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      // 1. Capture ID Card widget to image bytes
      final Uint8List? imageBytes = await IdCardPdfService.captureWidgetToImage(_cardBoundaryKey);

      if (imageBytes == null) {
        _showToast("Could not capture ID card. Please try again.");
        return;
      }

      final employeeData = _profileData?.firstEmployee;
      final empName = _asmProfile?.name ?? employeeData?.name ?? widget.userData.name ?? "Employee";
      final empId = _asmProfile?.uniqueId ??
          (_asmProfile?.asmId != null ? "ASM${_asmProfile!.asmId.toString().padLeft(3, '0')}" : null) ??
          employeeData?.employeeCode ??
          employeeData?.empId ??
          widget.userData.empId ??
          "DAPL2025";
      final designation = (_asmProfile != null ? "Area Sales Manager" : null) ??
          employeeData?.employeeType ??
          widget.userData.employeeType ??
          "Staff Member";

      final rawDate = _asmProfile?.joiningDate ?? employeeData?.joinDate ?? employeeData?.createdAt;
      String? formattedJoinDate;
      if (rawDate != null && rawDate.trim().isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawDate.trim());
          const months = [
            'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
            'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
          ];
          formattedJoinDate = '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
        } catch (_) {
          formattedJoinDate = rawDate;
        }
      }
      final bloodGroup = _asmProfile?.bloodGroup ?? _asmProfile?.billedGroup ?? "";

      // 2. Generate PDF document with exact matching card data
      final Uint8List pdfBytes = await IdCardPdfService.generateIdCardPdf(
        cardImageBytes: imageBytes,
        employeeName: empName,
        empId: empId,
        designation: designation,
        joiningDate: formattedJoinDate,
        bloodGroup: bloodGroup,
      );

      // 3. Save to temp file
      final File pdfFile = await IdCardPdfService.savePdfToTempFile(pdfBytes, empId: empId);

      // 4. Share to WhatsApp or general share sheet
      if (toWhatsApp) {
        await IdCardPdfService.shareToWhatsApp(
          pdfFile: pdfFile,
          employeeName: empName,
          empId: empId,
          joiningDate: formattedJoinDate,
          bloodGroup: bloodGroup,
          phoneNumber: _asmProfile?.mobile ?? employeeData?.mobile ?? widget.userData.mobile,
        );
      } else {
        await IdCardPdfService.shareIdCardPdf(
          pdfFile: pdfFile,
          employeeName: empName,
          empId: empId,
          joiningDate: formattedJoinDate,
          bloodGroup: bloodGroup,
        );
      }
    } catch (e) {
      debugPrint("Error in _exportAndSharePdf: $e");
      _showToast("Error generating PDF: $e");
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  // Print or direct preview PDF
  Future<void> _printOrPreviewPdf() async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final Uint8List? imageBytes = await IdCardPdfService.captureWidgetToImage(_cardBoundaryKey);

      if (imageBytes == null) {
        _showToast("Could not capture ID card. Please try again.");
        return;
      }

      final employeeData = _profileData?.firstEmployee;
      final empName = _asmProfile?.name ?? employeeData?.name ?? widget.userData.name ?? "Employee";
      final empId = _asmProfile?.uniqueId ??
          (_asmProfile?.asmId != null ? "ASM${_asmProfile!.asmId.toString().padLeft(3, '0')}" : null) ??
          employeeData?.employeeCode ??
          employeeData?.empId ??
          widget.userData.empId ??
          "DAPL2025";
      final designation = (_asmProfile != null ? "Area Sales Manager" : null) ??
          employeeData?.employeeType ??
          widget.userData.employeeType ??
          "Staff Member";

      final rawDate = _asmProfile?.joiningDate ?? employeeData?.joinDate ?? employeeData?.createdAt;
      String? formattedJoinDate;
      if (rawDate != null && rawDate.trim().isNotEmpty) {
        try {
          final parsed = DateTime.parse(rawDate.trim());
          const months = [
            'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
            'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
          ];
          formattedJoinDate = '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
        } catch (_) {
          formattedJoinDate = rawDate;
        }
      }
      final bloodGroup = _asmProfile?.bloodGroup ?? _asmProfile?.billedGroup ?? "";

      final Uint8List pdfBytes = await IdCardPdfService.generateIdCardPdf(
        cardImageBytes: imageBytes,
        employeeName: empName,
        empId: empId,
        designation: designation,
        joiningDate: formattedJoinDate,
        bloodGroup: bloodGroup,
      );

      await IdCardPdfService.printOrPreviewPdf(pdfBytes, title: "Durvasa_ID_Card_${empId}.pdf");
    } catch (e) {
      debugPrint("Error printing PDF: $e");
      _showToast("Error printing PDF: $e");
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeData = _profileData?.firstEmployee;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive scaling for the ID Card: base width is 380, pad by 32 on screen
    final double targetWidth = (screenWidth - 36).clamp(300.0, 390.0);
    final double clampedScale = (targetWidth / 380.0).clamp(0.78, 1.0);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Digital Identity Card",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: "Refresh Profile",
            onPressed: () {
              if (widget.userData.mobile != null) {
                ApiService.clearProfileCache(widget.userData.mobile!);
              }
              _fetchProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.white),
            tooltip: "Print / Save PDF",
            onPressed: _isGeneratingPdf ? null : _printOrPreviewPdf,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading Official Identity Card...",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Verification Header Ribbon
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGold.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: AppColors.secondaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Official Identity Badge • Durvasa Ayurved",
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // The ID Card Widget wrapped in RepaintBoundary for high-res PDF export
                  Center(
                    child: RepaintBoundary(
                      key: _cardBoundaryKey,
                      child: DurvasaIdCardWidget(
                        userData: widget.userData,
                        employeeData: employeeData,
                        asmProfile: _asmProfile,
                        scale: clampedScale,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading indicator when generating PDF
                  if (_isGeneratingPdf)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Generating High-Resolution PDF...",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Security & Instructions Info Card
                  _buildSecurityInfoCard(),
                ],
              ),
            ),
    );
  }

  // Bottom action bar with WhatsApp Share and PDF Export buttons
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // WhatsApp Share Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : () => _exportAndSharePdf(toWhatsApp: true),
                icon: const Icon(Icons.share, color: AppColors.white, size: 18),
                label: Text(
                  "WhatsApp PDF",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Brand Green
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Standard Share Sheet / Save PDF
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : () => _exportAndSharePdf(toWhatsApp: false),
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.white, size: 18),
                label: Text(
                  "Share / Save PDF",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Security card displayed underneath the preview
  Widget _buildSecurityInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.lightGold.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Digital Verification & Security",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "• This card is an official electronic identity badge issued by Durvasa Ayurved Pvt. Ltd.\n"
            "• Tap 'WhatsApp PDF' to export and share the verified vector-rendered PDF document directly with contacts or management.\n"
            "• For any discrepancies in joining date, designation, or photo, please update via the Profile page or contact HR.",
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
