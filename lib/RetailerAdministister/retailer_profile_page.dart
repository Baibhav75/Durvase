import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../model/Retailer_model/retailer_profile_model.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../service/session_manager.dart';
import 'edit_retailer_profile_sheet.dart';
import 'retailer_id_card_screen.dart';

class RetailerProfilePage extends StatefulWidget {
  final RetailerModel retailer;

  const RetailerProfilePage({
    super.key,
    required this.retailer,
  });

  @override
  State<RetailerProfilePage> createState() => _RetailerProfilePageState();
}

class _RetailerProfilePageState extends State<RetailerProfilePage> {
  late Future<RetailerProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  Future<RetailerProfileData> _fetchProfile() async {
    // 1. Get Visiter / Retailer ID from SessionManager, fallback to widget.retailer
    String? visiterId = await SessionManager.getVisiterId();
    if (visiterId == null || visiterId.isEmpty) {
      visiterId = widget.retailer.visiterId.isNotEmpty
          ? widget.retailer.visiterId
          : widget.retailer.retailerId;
      if (visiterId.isNotEmpty) {
        await SessionManager.saveRetailerId(visiterId);
      }
    }

    if (visiterId.isEmpty) {
      throw Exception('Visiter ID is missing.');
    }

    final response = await RetailerProfileService.getRetailerProfile(visiterId);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    // Fallback: If API returns empty data, construct from widget.retailer
    if (response.data == null) {
      return RetailerProfileData(
        visiterId: visiterId,
        personName: widget.retailer.personName.isNotEmpty
            ? widget.retailer.personName
            : widget.retailer.name,
        businessName: widget.retailer.businessName.isNotEmpty
            ? widget.retailer.businessName
            : 'Durvasa Ayurveda Store',
        email: widget.retailer.email,
        mobile: widget.retailer.phone,
        address: widget.retailer.address.isNotEmpty
            ? widget.retailer.address
            : widget.retailer.businessAddress,
        photo: widget.retailer.fullPhotoUrl.isNotEmpty
            ? widget.retailer.fullPhotoUrl
            : widget.retailer.profile,
        empType: widget.retailer.empType.isNotEmpty
            ? widget.retailer.empType
            : 'Permanent',
        visitFor: widget.retailer.visitFor.isNotEmpty
            ? widget.retailer.visitFor
            : 'Business Development',
        purpose: widget.retailer.purpose.isNotEmpty
            ? widget.retailer.purpose
            : 'Retailer',
        status: widget.retailer.status.isNotEmpty
            ? widget.retailer.status
            : 'Active',
      );
    }

    throw Exception(response.message?.toString() ?? 'Failed to fetch retailer profile.');
  }

  // ============================================================
  // OPEN EDIT PROFILE MODAL
  // ============================================================
  void _openEditProfileModal(RetailerProfileData currentProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditRetailerProfileSheet(
        profile: currentProfile,
        onProfileUpdated: () {
          _loadProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Profile updated successfully!',
                    style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ACTION HELPERS (CALL, EMAIL, COPY, ID CARD, IMAGE PREVIEW)
  // ============================================================
  Future<void> _copyToClipboard(String text, String label) async {
    if (text.trim().isEmpty || text == 'Not available') return;
    await Clipboard.setData(ClipboardData(text: text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 20),
            const SizedBox(width: 10),
            Text(
              '$label copied to clipboard',
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyToClipboard(phoneNumber, 'Phone Number');
      }
    } catch (_) {
      _copyToClipboard(phoneNumber, 'Phone Number');
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final uri = Uri.parse('mailto:${email.trim()}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _copyToClipboard(email, 'Email Address');
      }
    } catch (_) {
      _copyToClipboard(email, 'Email Address');
    }
  }

  void _openIdCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RetailerIdCardScreen(retailer: widget.retailer),
      ),
    );
  }

  void _showImagePreviewDialog(String imageUrl, String name) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image_rounded, size: 50, color: AppColors.warning),
                        const SizedBox(height: 10),
                        Text('Unable to load photo', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.poppins(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _val(String? value) {
    if (value == null || value.trim().isEmpty || value.trim().toLowerCase() == 'null') {
      return 'Not available';
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
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
          'Retailer Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined, color: AppColors.lightGold),
            tooltip: 'View ID Card',
            onPressed: _openIdCard,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Refresh',
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: FutureBuilder<RetailerProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildError('No retailer profile data received from server.');
          }

          final profile = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.white,
            onRefresh: () async {
              _loadProfile();
              await _profileFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                children: [
                  // 1. Header Banner with Avatar & Badges
                  _buildProfileHeader(profile),
                  const SizedBox(height: 16),

                  // 2. Personal & Store Information Section
                  _buildSection(
                    title: 'Contact & Business Details',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildInfoRow(
                        Icons.person_rounded,
                        'Person Name',
                        _val(profile.personName ?? profile.name ?? widget.retailer.personName),
                        onCopy: () => _copyToClipboard(_val(profile.personName ?? profile.name ?? widget.retailer.personName), 'Person Name'),
                      ),
                      if (profile.businessName != null && profile.businessName!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.storefront_outlined,
                          'Business / Store Name',
                          _val(profile.businessName ?? widget.retailer.businessName),
                          highlightValue: true,
                          onCopy: () => _copyToClipboard(_val(profile.businessName ?? widget.retailer.businessName), 'Business Name'),
                        ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Mobile Number',
                        _val(profile.mobile ?? widget.retailer.phone),
                        actionIcon: Icons.phone_forwarded_rounded,
                        actionColor: AppColors.leafGreen,
                        onAction: () => _makePhoneCall(profile.mobile ?? widget.retailer.phone),
                        onCopy: () => _copyToClipboard(_val(profile.mobile ?? widget.retailer.phone), 'Mobile Number'),
                      ),
                      if (profile.email != null && profile.email!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email Address',
                          _val(profile.email ?? widget.retailer.email),
                          actionIcon: Icons.mail_outline_rounded,
                          actionColor: AppColors.primaryGreen,
                          onAction: () => _sendEmail(profile.email ?? widget.retailer.email),
                          onCopy: () => _copyToClipboard(_val(profile.email ?? widget.retailer.email), 'Email Address'),
                        ),
                      if (profile.billedGroup != null && profile.billedGroup!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.category_outlined,
                          'Billed Group',
                          _val(profile.billedGroup),
                          onCopy: () => _copyToClipboard(_val(profile.billedGroup), 'Billed Group'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Visit & Assigned MR / Employee Information
                  _buildSection(
                    title: 'Visit & Representative Details',
                    icon: Icons.badge_outlined,
                    children: [
                      _buildInfoRow(
                        Icons.fingerprint_rounded,
                        'Visiter ID',
                        _val(profile.visiterId ?? profile.retailerId ?? widget.retailer.visiterId),
                        highlightValue: true,
                        onCopy: () => _copyToClipboard(_val(profile.visiterId ?? profile.retailerId ?? widget.retailer.visiterId), 'Visiter ID'),
                      ),
                      _buildInfoRow(
                        Icons.category_outlined,
                        'Purpose / Role',
                        _val(profile.purpose ?? widget.retailer.purpose ?? 'Retailer'),
                      ),
                      if (profile.empType != null && profile.empType!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.work_history_outlined,
                          'Employment Type',
                          _val(profile.empType ?? widget.retailer.empType),
                        ),
                      if (profile.visitFor != null && profile.visitFor!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.business_center_outlined,
                          'Visit For',
                          _val(profile.visitFor ?? widget.retailer.visitFor),
                        ),
                      if (profile.visitDate != null && profile.visitDate!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.calendar_today_rounded,
                          'Visit Date',
                          profile.formattedVisitDate,
                        ),
                      if (profile.revisitDate != null && profile.revisitDate!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.event_repeat_rounded,
                          'Revisit Date',
                          profile.formattedRevisitDate,
                        ),
                      if (profile.reVisited != null && profile.reVisited!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.sync_rounded,
                          'Re-Visited Status',
                          _val(profile.reVisited),
                        ),
                      if (profile.empName != null && profile.empName!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.support_agent_rounded,
                          'Assigned MR / Officer',
                          _val(profile.empName),
                          onCopy: () => _copyToClipboard(_val(profile.empName), 'Assigned MR'),
                        ),
                      if (profile.employeeId != null && profile.employeeId!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.badge_rounded,
                          'MR Employee ID',
                          _val(profile.employeeId),
                          onCopy: () => _copyToClipboard(_val(profile.employeeId), 'MR Employee ID'),
                        ),
                      if (profile.empMobile != null && profile.empMobile!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.phone_in_talk_rounded,
                          'MR Contact Number',
                          _val(profile.empMobile),
                          actionIcon: Icons.phone_forwarded_rounded,
                          actionColor: AppColors.leafGreen,
                          onAction: () => _makePhoneCall(profile.empMobile),
                          onCopy: () => _copyToClipboard(_val(profile.empMobile), 'MR Mobile Number'),
                        ),
                      if (profile.remark != null && profile.remark!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.notes_rounded,
                          'Remark / Notes',
                          _val(profile.remark),
                        ),
                      _buildInfoRow(
                        profile.isActive
                            ? Icons.verified_outlined
                            : Icons.cancel_outlined,
                        'Account Status',
                        profile.status ?? (profile.isActive ? 'Active' : 'Inactive'),
                        valueColor: profile.isActive
                            ? AppColors.primaryGreen
                            : AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Territory & Location Section
                  _buildSection(
                    title: 'Work Area & Territory',
                    icon: Icons.map_outlined,
                    children: [
                      _buildInfoRow(
                        Icons.location_city_outlined,
                        'District',
                        _val(profile.district),
                      ),
                      if (profile.block != null && profile.block!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.domain_outlined,
                          'Block',
                          _val(profile.block),
                        ),
                      _buildInfoRow(
                        Icons.public_outlined,
                        'State',
                        _val(profile.state),
                      ),
                      _buildInfoRow(
                        Icons.flag_outlined,
                        'Country',
                        _val(profile.country ?? 'India'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. Business / Store Address Section
                  _buildSection(
                    title: 'Pharmacy / Business Address',
                    icon: Icons.business_outlined,
                    children: [
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'Full Address',
                        _val(profile.address ?? widget.retailer.businessAddress),
                        onCopy: () => _copyToClipboard(_val(profile.address ?? widget.retailer.businessAddress), 'Address'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. Action Buttons (View ID Card & Edit Profile)
                  Row(
                    children: [
                      // View ID Card Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openIdCard,
                          icon: const Icon(Icons.badge_outlined, color: AppColors.primaryGreen, size: 20),
                          label: Text(
                            'Official ID Card',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Edit Profile Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openEditProfileModal(profile),
                          icon: const Icon(Icons.edit_note_rounded, color: AppColors.white, size: 22),
                          label: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  // ============================================================
  // LUXURY PROFILE HEADER BANNER
  // ============================================================
  Widget _buildProfileHeader(RetailerProfileData profile) {
    final imageUrl = profile.resolvedImageUrl;
    final personName = _val(profile.personName ?? profile.name ?? widget.retailer.personName);
    final businessName = profile.businessName ?? widget.retailer.businessName;
    final visiterId = _val(profile.visiterId ?? profile.retailerId ?? widget.retailer.visiterId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.darkGreen,
            AppColors.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with gold border & tap-to-zoom and camera edit badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImagePreviewDialog(imageUrl, personName),
                child: Container(
                  height: 105,
                  width: 105,
                  padding: const EdgeInsets.all(3.5),
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
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.storefront_rounded,
                              size: 55,
                              color: AppColors.primaryGreen,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.storefront_rounded,
                                  size: 55,
                                  color: AppColors.primaryGreen,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
              // Camera edit icon overlay badge
              GestureDetector(
                onTap: () => _openEditProfileModal(profile),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.darkGreen, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Person Name
          Text(
            personName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 0.4,
            ),
          ),
          if (businessName != null && businessName.isNotEmpty && businessName != personName) ...[
            const SizedBox(height: 2),
            Text(
              businessName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.cream,
              ),
            ),
          ],
          const SizedBox(height: 3),

          // Designation
          Text(
            profile.displayDesignation,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 12),

          // Badges Wrap (Visiter ID, Purpose, Location, Status)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildHeaderChip(
                icon: Icons.fingerprint,
                text: 'ID: $visiterId',
                onTap: () => _copyToClipboard(visiterId, 'Visiter ID'),
              ),
              if (profile.purpose != null && profile.purpose!.trim().isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.category_rounded,
                  text: profile.purpose!.trim(),
                ),
              if (profile.district != null || profile.state != null)
                _buildHeaderChip(
                  icon: Icons.location_on_outlined,
                  text: profile.displayLocation,
                ),
              _buildHeaderChip(
                icon: profile.isActive ? Icons.check_circle : Icons.warning_amber_rounded,
                text: profile.status ?? (profile.isActive ? 'Active' : 'Inactive'),
                color: profile.isActive ? AppColors.leafGreen : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Action Icons Row (Call, MR Call, Email, ID Card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  onTap: () => _makePhoneCall(profile.mobile ?? widget.retailer.phone),
                ),
                if (profile.empMobile != null && profile.empMobile!.trim().isNotEmpty)
                  _buildQuickActionButton(
                    icon: Icons.support_agent_rounded,
                    label: 'MR Call',
                    onTap: () => _makePhoneCall(profile.empMobile),
                  ),
                _buildQuickActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  onTap: () => _sendEmail(profile.email ?? widget.retailer.email),
                ),
                _buildQuickActionButton(
                  icon: Icons.badge_rounded,
                  label: 'ID Card',
                  onTap: _openIdCard,
                ),
                if (profile.emergenceNo != null && profile.emergenceNo!.trim().isNotEmpty)
                  _buildQuickActionButton(
                    icon: Icons.emergency_rounded,
                    label: 'Emergency',
                    onTap: () => _makePhoneCall(profile.emergenceNo),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String text,
    Color color = AppColors.cream,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD SECTION BUILDER
  // ============================================================
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool highlightValue = false,
    IconData? actionIcon,
    Color? actionColor,
    VoidCallback? onAction,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: valueColor ?? (highlightValue ? AppColors.primaryGreen : AppColors.textDark),
                  fontWeight: highlightValue ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ),
          if (actionIcon != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (actionColor ?? AppColors.primaryGreen).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  actionIcon,
                  size: 14,
                  color: actionColor ?? AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ERROR & EMPTY STATE
  // ============================================================
  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.warning,
              size: 50,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load profile',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}