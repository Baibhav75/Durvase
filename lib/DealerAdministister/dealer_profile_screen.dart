import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../model/Dealer_Model/dealer_login_model.dart';
import '../model/Dealer_Model/dealer_profile_model.dart';
import '../service/Dealer_service/dealer_profile_service.dart';
import 'dealer_edit_profile_screen.dart';

class DealerProfilePage extends StatefulWidget {
  final DealerModel dealer;

  const DealerProfilePage({
    super.key,
    required this.dealer,
  });

  @override
  State<DealerProfilePage> createState() => _DealerProfilePageState();
}

class _DealerProfilePageState extends State<DealerProfilePage> {
  late Future<DealerProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      final dealerId = widget.dealer.dealerId.isNotEmpty
          ? widget.dealer.dealerId
          : widget.dealer.visiterId;
      _profileFuture = DealerProfileService.getDealerProfile(dealerId);
    });
  }

  // ============================================================
  // ACTION HELPERS (CALL, EMAIL, COPY, IMAGE PREVIEW)
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

  void _openEditProfileModal(DealerProfileModel currentProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditDealerProfileSheet(
        profile: currentProfile,
        dealerId: widget.dealer.dealerId.isNotEmpty ? widget.dealer.dealerId : widget.dealer.visiterId,
        onProfileUpdated: () {
          _loadProfile();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.white),
                  const SizedBox(width: 10),
                  Text('Profile updated successfully!', style: GoogleFonts.poppins(color: AppColors.white)),
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

  void _showImagePreviewDialog(String imageUrl, String name) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
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
          'Dealer Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Refresh',
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: FutureBuilder<DealerProfileModel>(
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
            return _buildError('No dealer profile data received from server.');
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
                  // 1. Header Banner with Avatar, Name, Business & Badges
                  _buildProfileHeader(profile),
                  const SizedBox(height: 16),

                  // 2. Business & Store Information Section
                  _buildSection(
                    title: 'Business & Store Details',
                    icon: Icons.storefront_rounded,
                    children: [
                      if (profile.businessName != null && profile.businessName!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.store_rounded,
                          'Firm / Store Name',
                          _val(profile.businessName),
                          highlightValue: true,
                          onCopy: () => _copyToClipboard(_val(profile.businessName), 'Firm Name'),
                        ),
                      _buildInfoRow(
                        Icons.fingerprint_rounded,
                        'Dealer / Visit ID',
                        _val(profile.dealerId),
                        highlightValue: true,
                        onCopy: () => _copyToClipboard(_val(profile.dealerId), 'Dealer ID'),
                      ),
                      if (profile.purpose != null && profile.purpose!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.assignment_ind_outlined,
                          'Purpose / Role',
                          _val(profile.purpose),
                        ),
                      if (profile.visitFor != null && profile.visitFor!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.local_hospital_outlined,
                          'Visit For',
                          _val(profile.visitFor),
                        ),
                      if (profile.gstNumber != null && profile.gstNumber!.trim().isNotEmpty && profile.gstNumber!.trim().toLowerCase() != 'null')
                        _buildInfoRow(
                          Icons.receipt_long_outlined,
                          'GST Number',
                          _val(profile.gstNumber),
                          onCopy: () => _copyToClipboard(_val(profile.gstNumber), 'GST Number'),
                        ),
                      _buildInfoRow(
                        profile.isActive ? Icons.verified_outlined : Icons.cancel_outlined,
                        'Account Status',
                        profile.isActive ? 'Active' : 'Inactive',
                        valueColor: profile.isActive ? AppColors.leafGreen : AppColors.error,
                      ),
                      _buildInfoRow(
                        Icons.access_time_rounded,
                        'Registered Date',
                        profile.formattedCreatedAt,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Contact Information Section
                  _buildSection(
                    title: 'Contact Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildInfoRow(
                        Icons.person_rounded,
                        'Contact Person',
                        _val(profile.name),
                        onCopy: () => _copyToClipboard(_val(profile.name), 'Name'),
                      ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Mobile Number',
                        _val(profile.phone),
                        actionIcon: Icons.phone_forwarded_rounded,
                        actionColor: AppColors.leafGreen,
                        onAction: () => _makePhoneCall(profile.phone),
                        onCopy: () => _copyToClipboard(_val(profile.phone), 'Mobile Number'),
                      ),
                      if (profile.email != null && profile.email!.trim().isNotEmpty && profile.email!.trim().toLowerCase() != 'null')
                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email Address',
                          _val(profile.email),
                          actionIcon: Icons.mail_outline_rounded,
                          actionColor: AppColors.primaryGreen,
                          onAction: () => _sendEmail(profile.email),
                          onCopy: () => _copyToClipboard(_val(profile.email), 'Email Address'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Business Location & Address Section
                  _buildSection(
                    title: 'Business Location',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildInfoRow(
                        Icons.home_work_outlined,
                        'Full Address',
                        _val(profile.businessAddress),
                        onCopy: () => _copyToClipboard(_val(profile.businessAddress), 'Address'),
                      ),
                      if (profile.block != null && profile.block!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.holiday_village_outlined,
                          'Block / Area',
                          _val(profile.block),
                        ),
                      if (profile.district != null && profile.district!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.location_city_rounded,
                          'District / City',
                          _val(profile.district),
                        ),
                      if (profile.state != null && profile.state!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.map_outlined,
                          'State',
                          _val(profile.state),
                        ),
                      if (profile.country != null && profile.country!.trim().isNotEmpty)
                        _buildInfoRow(
                          Icons.public_rounded,
                          'Country',
                          _val(profile.country),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5. Assigned Representative / Executive Details (if present)
                  if ((profile.empName != null && profile.empName!.trim().isNotEmpty) ||
                      (profile.employeeId != null && profile.employeeId!.trim().isNotEmpty))
                    _buildSection(
                      title: 'Field Representative / Officer',
                      icon: Icons.badge_outlined,
                      children: [
                        if (profile.empName != null && profile.empName!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.support_agent_rounded,
                            'Executive Name',
                            _val(profile.empName),
                          ),
                        if (profile.employeeId != null && profile.employeeId!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.perm_identity_rounded,
                            'Employee ID',
                            _val(profile.employeeId),
                          ),
                        if (profile.empType != null && profile.empType!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.work_outline_rounded,
                            'Designation / Type',
                            _val(profile.empType),
                          ),
                        if (profile.empMobile != null && profile.empMobile!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.phone_android_rounded,
                            'Officer Mobile',
                            _val(profile.empMobile),
                            actionIcon: Icons.phone_forwarded_rounded,
                            actionColor: AppColors.leafGreen,
                            onAction: () => _makePhoneCall(profile.empMobile),
                            onCopy: () => _copyToClipboard(_val(profile.empMobile), 'Officer Mobile'),
                          ),
                      ],
                    ),
                  if ((profile.empName != null && profile.empName!.trim().isNotEmpty) ||
                      (profile.employeeId != null && profile.employeeId!.trim().isNotEmpty))
                    const SizedBox(height: 14),

                  // 6. Visit Tracking & Field Notes (if present)
                  if ((profile.remark != null && profile.remark!.trim().isNotEmpty) ||
                      (profile.revisitDate != null && profile.revisitDate!.trim().isNotEmpty) ||
                      (profile.reVisited != null && profile.reVisited!.trim().isNotEmpty))
                    _buildSection(
                      title: 'Visit Tracking & Notes',
                      icon: Icons.event_note_rounded,
                      children: [
                        if (profile.reVisited != null && profile.reVisited!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.repeat_rounded,
                            'Re-Visited Status',
                            _val(profile.reVisited),
                          ),
                        if (profile.revisitDate != null && profile.revisitDate!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.calendar_today_rounded,
                            'Next Revisit Date',
                            profile.formattedRevisitDate,
                            valueColor: AppColors.primaryGreen,
                          ),
                        if (profile.remark != null && profile.remark!.trim().isNotEmpty)
                          _buildInfoRow(
                            Icons.notes_rounded,
                            'Meeting Notes',
                            _val(profile.remark),
                          ),
                      ],
                    ),
                  if ((profile.remark != null && profile.remark!.trim().isNotEmpty) ||
                      (profile.revisitDate != null && profile.revisitDate!.trim().isNotEmpty) ||
                      (profile.reVisited != null && profile.reVisited!.trim().isNotEmpty))
                    const SizedBox(height: 14),

                  const SizedBox(height: 10),

                  // Edit Profile Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openEditProfileModal(profile),
                          icon: const Icon(Icons.edit_note_rounded, color: AppColors.white, size: 22),
                          label: Text(
                            'Edit Profile Details',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
  Widget _buildProfileHeader(DealerProfileModel profile) {
    final imageUrl = profile.resolvedImageUrl;
    final primaryName = (profile.businessName != null && profile.businessName!.trim().isNotEmpty)
        ? profile.businessName!
        : (profile.name ?? 'Authorized Dealer');

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
          color: AppColors.primaryGold.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with gold border, tap-to-zoom
          GestureDetector(
            onTap: () => _showImagePreviewDialog(imageUrl, primaryName),
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
                    color: Colors.black.withOpacity(0.35),
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
          const SizedBox(height: 14),

          // Business / Dealer Name
          Text(
            _val(primaryName),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 0.4,
            ),
          ),
          if (profile.businessName != null && profile.businessName!.trim().isNotEmpty && profile.name != null) ...[
            const SizedBox(height: 2),
            Text(
              'Prop: ${_val(profile.name)}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.cream,
              ),
            ),
          ],
          const SizedBox(height: 3),

          // Role label
          Text(
            profile.purpose != null && profile.purpose!.trim().isNotEmpty
                ? 'Authorized ${profile.purpose!.trim()}'
                : 'Authorized Dealer',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 12),

          // Badges Wrap
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (profile.dealerId != null && profile.dealerId!.trim().isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.fingerprint,
                  text: 'ID: ${profile.dealerId}',
                  onTap: () => _copyToClipboard(profile.dealerId!, 'Dealer ID'),
                ),
              if (profile.gstNumber != null && profile.gstNumber!.trim().isNotEmpty && profile.gstNumber!.trim().toLowerCase() != 'null')
                _buildHeaderChip(
                  icon: Icons.receipt_long_outlined,
                  text: 'GST: ${profile.gstNumber}',
                  onTap: () => _copyToClipboard(profile.gstNumber!, 'GST Number'),
                ),
              _buildHeaderChip(
                icon: profile.isActive ? Icons.check_circle : Icons.warning_amber_rounded,
                text: profile.isActive ? 'Active' : 'Inactive',
                color: profile.isActive ? AppColors.leafGreen : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Action Icons Row (Call, Email)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  onTap: () => _makePhoneCall(profile.phone),
                ),
                _buildQuickActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  onTap: () => _sendEmail(profile.email),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          color: AppColors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), width: 1),
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
        border: Border.all(color: AppColors.lightGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.05),
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
                  color: AppColors.primaryGreen.withOpacity(0.08),
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
                  color: (actionColor ?? AppColors.primaryGreen).withOpacity(0.1),
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
              size: 54,
              color: AppColors.warning,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to Load Dealer Profile',
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
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}