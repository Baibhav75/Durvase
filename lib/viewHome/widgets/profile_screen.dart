import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../HomeDrawerpage/id_card_screen.dart';
import '../../constants/app_colors.dart';
import '../../model/TodoModel.dart';
import '../../model/TodoModel1.dart';
import '../../service/api_serviceProfile.dart';
import 'MrprofileEdit.dart';

class ProfileScreen extends StatefulWidget {
  final TodoModel userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TodoModel1? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    if (widget.userData.mobile == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Mobile number not available';
        });
      }
      return;
    }

    final mobile = widget.userData.mobile!;
    final isCached = ApiService.isProfileCached(mobile);

    if (!isCached) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    }

    try {
      final profileData = await ApiService.fetchProfile(mobile);
      if (mounted) {
        setState(() {
          _profileData = profileData;
        });
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Request timeout. Please check your internet connection and try again.';
        });
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Network error. Please check your internet connection and try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Failed to load profile')
              ? e.toString()
              : 'Failed to load profile. Please try again.';
        });
      }
    } finally {
      if (!isCached && mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        builder: (_) => IdCardScreen(userData: widget.userData),
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

  void _openEditProfileModal(Data1 employeeData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MrProfileEditSheet(
        employeeData: employeeData,
        onProfileUpdated: () {
          ApiService.clearProfileCache(widget.userData.mobile);
          _fetchProfileData();
        },
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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
          'MR Profile',
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
            onPressed: () {
              ApiService.clearProfileCache(widget.userData.mobile);
              _fetchProfileData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            )
          : _errorMessage != null
              ? _buildError(_errorMessage!)
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null || _profileData!.data1 == null || _profileData!.data1!.isEmpty) {
      return _buildError('No profile data received from server.');
    }

    final employeeData = _profileData!.data1!.first;
    final isCached = ApiService.isProfileCached(widget.userData.mobile!);
    DateTime? lastUpdated;
    if (isCached) {
      lastUpdated = ApiService.getCacheTimestamp(widget.userData.mobile!);
    }

    final isActive = (employeeData.status ?? '').trim().toLowerCase() == 'active' ||
        (employeeData.status ?? '').trim().toLowerCase() == '1';

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      backgroundColor: AppColors.white,
      onRefresh: () async {
        ApiService.clearProfileCache(widget.userData.mobile);
        await _fetchProfileData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          children: [
            // Cache indicator
            if (isCached && lastUpdated != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cached_rounded, size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Loaded from cache • Last updated: ${_formatDateTime(lastUpdated)}",
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 1. Header Banner with Avatar & Badges
            _buildProfileHeader(employeeData, isActive),
            const SizedBox(height: 16),

            // 2. Personal Information Section
            _buildSection(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              children: [
                _buildInfoRow(
                  Icons.person_rounded,
                  'Full Name',
                  _val(employeeData.name),
                  onCopy: () => _copyToClipboard(_val(employeeData.name), 'Name'),
                ),
                _buildInfoRow(
                  Icons.family_restroom_outlined,
                  'Father\'s Name',
                  _val(employeeData.fatherName),
                ),
                _buildInfoRow(
                  Icons.wc_outlined,
                  'Gender',
                  _val(employeeData.gender),
                ),
                if (employeeData.billedGroup != null && employeeData.billedGroup!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.bloodtype_outlined,
                    'Blood Group',
                    _val(employeeData.billedGroup),
                    valueColor: const Color(0xFFD32F2F),
                    onCopy: () => _copyToClipboard(_val(employeeData.billedGroup), 'Blood Group'),
                  ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Primary Mobile',
                  _val(employeeData.mobile),
                  actionIcon: Icons.phone_forwarded_rounded,
                  actionColor: AppColors.leafGreen,
                  onAction: () => _makePhoneCall(employeeData.mobile),
                  onCopy: () => _copyToClipboard(_val(employeeData.mobile), 'Primary Mobile'),
                ),
                if (employeeData.mobileAlt != null && employeeData.mobileAlt!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.phone_iphone_outlined,
                    'Alternate Mobile',
                    _val(employeeData.mobileAlt),
                    actionIcon: Icons.phone_forwarded_rounded,
                    actionColor: AppColors.primaryGold,
                    onAction: () => _makePhoneCall(employeeData.mobileAlt),
                    onCopy: () => _copyToClipboard(_val(employeeData.mobileAlt), 'Alternate Mobile'),
                  ),
                if (employeeData.emergenceNo != null && employeeData.emergenceNo!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.emergency_outlined,
                    'Emergency Contact',
                    _val(employeeData.emergenceNo),
                    actionIcon: Icons.phone_forwarded_rounded,
                    actionColor: const Color(0xFFD32F2F),
                    highlightValue: true,
                    onAction: () => _makePhoneCall(employeeData.emergenceNo),
                    onCopy: () => _copyToClipboard(_val(employeeData.emergenceNo), 'Emergency Contact'),
                  ),
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email Address',
                  _val(employeeData.email),
                  actionIcon: Icons.mail_outline_rounded,
                  actionColor: AppColors.primaryGreen,
                  onAction: () => _sendEmail(employeeData.email),
                  onCopy: () => _copyToClipboard(_val(employeeData.email), 'Email Address'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Employment & Official Details Section
            _buildSection(
              title: 'Employment & Official Details',
              icon: Icons.badge_outlined,
              children: [
                _buildInfoRow(
                  Icons.fingerprint_rounded,
                  'Employee ID',
                  _val(employeeData.empId ?? employeeData.employeeId),
                  highlightValue: true,
                  onCopy: () => _copyToClipboard(_val(employeeData.empId ?? employeeData.employeeId), 'Employee ID'),
                ),
                if (employeeData.employeeCode != null && employeeData.employeeCode!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.qr_code_2_rounded,
                    'Employee Code',
                    _val(employeeData.employeeCode),
                    onCopy: () => _copyToClipboard(_val(employeeData.employeeCode), 'Employee Code'),
                  ),
                _buildInfoRow(
                  Icons.military_tech_outlined,
                  'Designation',
                  _val(employeeData.employeeType ?? 'Medical Representative (MR)'),
                ),
                _buildInfoRow(
                  Icons.calendar_month_outlined,
                  'Joining Date',
                  _val(employeeData.joinDate),
                ),
                _buildInfoRow(
                  isActive ? Icons.verified_outlined : Icons.cancel_outlined,
                  'Account Status',
                  _val(employeeData.status ?? (isActive ? 'Active' : 'Inactive')),
                  valueColor: isActive ? AppColors.primaryGreen : AppColors.error,
                ),
                if (employeeData.userId != null && employeeData.userId!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.account_box_outlined,
                    'User ID',
                    _val(employeeData.userId),
                    onCopy: () => _copyToClipboard(_val(employeeData.userId), 'User ID'),
                  ),
                if (employeeData.id != null)
                  _buildInfoRow(
                    Icons.tag_rounded,
                    'Record ID',
                    employeeData.id.toString(),
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
                  _val(employeeData.district),
                ),
                if (employeeData.block != null && employeeData.block!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.domain_outlined,
                    'Block',
                    _val(employeeData.block),
                  ),
                _buildInfoRow(
                  Icons.public_outlined,
                  'State',
                  _val(employeeData.state),
                ),
                _buildInfoRow(
                  Icons.flag_outlined,
                  'Country',
                  _val(employeeData.country ?? 'India'),
                ),
                if (employeeData.postOffice != null && employeeData.postOffice!.trim().isNotEmpty)
                  _buildInfoRow(
                    Icons.local_post_office_outlined,
                    'Post Office',
                    _val(employeeData.postOffice),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Residential Address Section
            _buildSection(
              title: 'Residential Address',
              icon: Icons.home_outlined,
              children: [
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Full Address',
                  _val(employeeData.address),
                  onCopy: () => _copyToClipboard(_val(employeeData.address), 'Address'),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 6. System Information Section
            if ((employeeData.createdAt != null && employeeData.createdAt!.trim().isNotEmpty) ||
                (employeeData.updatedAt != null && employeeData.updatedAt!.trim().isNotEmpty))
              _buildSection(
                title: 'System Information',
                icon: Icons.info_outline_rounded,
                children: [
                  if (employeeData.createdAt != null && employeeData.createdAt!.trim().isNotEmpty)
                    _buildInfoRow(
                      Icons.access_time_rounded,
                      'Created At',
                      _val(employeeData.createdAt),
                    ),
                  if (employeeData.updatedAt != null && employeeData.updatedAt!.trim().isNotEmpty)
                    _buildInfoRow(
                      Icons.update_rounded,
                      'Updated At',
                      _val(employeeData.updatedAt),
                    ),
                ],
              ),
            const SizedBox(height: 24),

            // 7. Action Buttons (View ID Card & Edit Profile)
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
                    onPressed: () => _openEditProfileModal(employeeData),
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
  }

  // ============================================================
  // LUXURY PROFILE HEADER BANNER
  // ============================================================
  Widget _buildProfileHeader(Data1 employeeData, bool isActive) {
    final imageUrl = employeeData.resolvedImageUrl;
    final empId = employeeData.empId ?? employeeData.employeeId;
    final district = employeeData.district;
    final state = employeeData.state;
    String locationText = '';
    if (district != null && district.trim().isNotEmpty && state != null && state.trim().isNotEmpty) {
      locationText = '${district.trim()}, ${state.trim()}';
    } else if (district != null && district.trim().isNotEmpty) {
      locationText = district.trim();
    } else if (state != null && state.trim().isNotEmpty) {
      locationText = state.trim();
    }

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
          // Circular Avatar with gold border, tap-to-zoom & edit badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () => _showImagePreviewDialog(imageUrl, employeeData.name ?? 'MR Profile'),
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
                              Icons.person_rounded,
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
                                  Icons.person_rounded,
                                  size: 55,
                                  color: AppColors.primaryGreen,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
              // Tap to edit camera badge
              GestureDetector(
                onTap: () => _openEditProfileModal(employeeData),
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

          // Name
          Text(
            _val(employeeData.name),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),

          // Designation
          Text(
            employeeData.employeeType ?? 'Medical Representative (MR)',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 12),

          // Badges Wrap (Emp ID, Location, Blood Group, Active Status)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (empId != null && empId.trim().isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.fingerprint,
                  text: 'ID: $empId',
                  onTap: () => _copyToClipboard(empId, 'Employee ID'),
                ),
              if (locationText.isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.location_on_outlined,
                  text: locationText,
                ),
              if (employeeData.billedGroup != null && employeeData.billedGroup!.trim().isNotEmpty)
                _buildHeaderChip(
                  icon: Icons.bloodtype,
                  text: 'Blood: ${employeeData.billedGroup}',
                  color: const Color(0xFFFF8A80),
                  onTap: () => _copyToClipboard(employeeData.billedGroup!, 'Blood Group'),
                ),
              _buildHeaderChip(
                icon: isActive ? Icons.check_circle : Icons.warning_amber_rounded,
                text: employeeData.status ?? (isActive ? 'Active' : 'Inactive'),
                color: isActive ? AppColors.leafGreen : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Action Icons Row (Call, Alternate Call, Email, ID Card, Edit)
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
                  onTap: () => _makePhoneCall(employeeData.mobile),
                ),
                if (employeeData.mobileAlt != null && employeeData.mobileAlt!.trim().isNotEmpty)
                  _buildQuickActionButton(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Alt Call',
                    onTap: () => _makePhoneCall(employeeData.mobileAlt),
                  ),
                _buildQuickActionButton(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  onTap: () => _sendEmail(employeeData.email),
                ),
                _buildQuickActionButton(
                  icon: Icons.badge_rounded,
                  label: 'ID Card',
                  onTap: _openIdCard,
                ),
                _buildQuickActionButton(
                  icon: Icons.edit_note_rounded,
                  label: 'Edit',
                  onTap: () => _openEditProfileModal(employeeData),
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
            width: 120,
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
              onPressed: () {
                ApiService.clearProfileCache(widget.userData.mobile);
                _fetchProfileData();
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
              label: Text('Retry', style: GoogleFonts.poppins(color: AppColors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
