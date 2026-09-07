import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../model/Retailer_model/edit_retailer_model.dart';
import '../model/Retailer_model/retailer_login_model.dart';
import '../model/Retailer_model/retailer_profile_model.dart';
import '../service/Retailer_service/retailer_profile_service.dart';
import '../service/Retailer_service/retailer_session_manager.dart';
import '../service/session_manager.dart';

class EditRetailerProfileSheet extends StatefulWidget {
  final RetailerProfileData profile;
  final VoidCallback onProfileUpdated;

  const EditRetailerProfileSheet({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  @override
  State<EditRetailerProfileSheet> createState() => _EditRetailerProfileSheetState();
}

class _EditRetailerProfileSheetState extends State<EditRetailerProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _businessNameController;
  late TextEditingController _mobileController;
  late TextEditingController _mobileAltController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _addressController;
  late TextEditingController _postOfficeController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  late TextEditingController _blockController;
  late TextEditingController _billedGroupController;

  // Visiter / MR specific controllers
  late TextEditingController _empNameController;
  late TextEditingController _empMobileController;
  late TextEditingController _employeeIdController;
  late TextEditingController _empTypeController;
  late TextEditingController _visitForController;
  late TextEditingController _purposeController;
  late TextEditingController _remarkController;
  late TextEditingController _fatherNameController;
  late TextEditingController _emergenceNoController;

  String _selectedGender = 'Male';
  String _selectedRevisited = 'No';
  File? _newProfileImage;
  String? _base64Image;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _resolvedRetailerId;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadRetailerId();
  }

  void _initControllers() {
    final p = widget.profile;
    _nameController = TextEditingController(text: p.personName ?? p.name ?? '');
    _businessNameController = TextEditingController(text: p.businessName ?? '');
    _mobileController = TextEditingController(text: p.mobile ?? '');
    _mobileAltController = TextEditingController(text: p.mobileAlt ?? '');
    _emergenceNoController = TextEditingController(text: p.emergenceNo ?? '');
    _emailController = TextEditingController(text: p.email ?? '');
    _passwordController = TextEditingController();
    _addressController = TextEditingController(text: p.address ?? '');
    _postOfficeController = TextEditingController(text: p.postOffice ?? '');
    _countryController = TextEditingController(text: p.country ?? 'India');
    _stateController = TextEditingController(text: p.state ?? '');
    _districtController = TextEditingController(text: p.district ?? '');
    _blockController = TextEditingController(text: p.block ?? '');
    _billedGroupController = TextEditingController(text: p.billedGroup ?? '');

    _empNameController = TextEditingController(text: p.empName ?? '');
    _empMobileController = TextEditingController(text: p.empMobile ?? '');
    _employeeIdController = TextEditingController(text: p.employeeId ?? '');
    _empTypeController = TextEditingController(text: p.empType ?? 'Permanent');
    _visitForController = TextEditingController(text: p.visitFor ?? 'Business Development');
    _purposeController = TextEditingController(text: p.purpose ?? 'Retailer');
    _remarkController = TextEditingController(text: p.remark ?? '');
    _fatherNameController = TextEditingController(text: p.fatherName ?? '');

    if (p.reVisited != null && p.reVisited!.trim().isNotEmpty) {
      final r = p.reVisited!.trim();
      if (['Yes', 'No'].contains(r)) {
        _selectedRevisited = r;
      }
    }

    if (p.gender != null && p.gender!.trim().isNotEmpty) {
      final g = p.gender!.trim();
      if (['Male', 'Female', 'Other'].contains(g)) {
        _selectedGender = g;
      }
    }
  }

  Future<void> _loadRetailerId() async {
    // 1. First priority: SessionManager
    String? id = await SessionManager.getVisiterId();
    if (id == null || id.isEmpty) {
      id = await SessionManager.getRetailerId();
    }

    // 2. Second priority: RetailerSessionManager
    if (id == null || id.isEmpty) {
      id = await RetailerSessionManager.getRetailerId();
    }

    // 3. Fallback: profile model
    if (id == null || id.isEmpty) {
      id = widget.profile.visiterId ?? widget.profile.retailerId;
    }

    if (mounted) {
      setState(() {
        _resolvedRetailerId = id;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _mobileController.dispose();
    _mobileAltController.dispose();
    _emergenceNoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _postOfficeController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _blockController.dispose();
    _billedGroupController.dispose();
    _empNameController.dispose();
    _empMobileController.dispose();
    _employeeIdController.dispose();
    _empTypeController.dispose();
    _visitForController.dispose();
    _purposeController.dispose();
    _remarkController.dispose();
    _fatherNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (picked != null) {
        final file = File(picked.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _newProfileImage = file;
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen),
                title: Text('Take Photo from Camera', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGreen),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final retailerId = _resolvedRetailerId ?? widget.profile.visiterId ?? widget.profile.retailerId ?? '';
    if (retailerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Visiter ID is missing from session.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final model = EditRetailerModel(
        id: widget.profile.id,
        visiterId: retailerId,
        personName: _nameController.text.trim(),
        businessName: _businessNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        country: _countryController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        block: _blockController.text.trim(),
        purpose: _purposeController.text.trim().isNotEmpty ? _purposeController.text.trim() : 'Retailer',
        empType: _empTypeController.text.trim().isNotEmpty ? _empTypeController.text.trim() : 'Permanent',
        visitFor: _visitForController.text.trim().isNotEmpty ? _visitForController.text.trim() : 'Business Development',
        empName: _empNameController.text.trim(),
        empMobile: _empMobileController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        reVisited: _selectedRevisited,
        visitDate: widget.profile.visitDate,
        revisitDate: widget.profile.revisitDate,
        remark: _remarkController.text.trim(),
        password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
        photo: _base64Image ?? widget.profile.photo,
        // Legacy fields
        email: _emailController.text.trim(),
        postOffice: _postOfficeController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        mobileAlt: _mobileAltController.text.trim(),
        emergenceNo: _emergenceNoController.text.trim(),
        billedGroup: _billedGroupController.text.trim(),
        status: widget.profile.status ?? 'Active',
      );

      final response = await RetailerProfileService.editRetailerProfile(model);

      debugPrint('Edit Retailer Profile Response: ${response.message}');

      // Sync Session Manager & RetailerSessionManager
      await SessionManager.saveVisiterId(retailerId);
      await SessionManager.saveRetailerId(retailerId);

      final savedRetailer = await RetailerSessionManager.getLoginData();
      if (savedRetailer != null) {
        final updatedRetailer = RetailerModel(
          visiterId: retailerId,
          personName: _nameController.text.trim(),
          businessName: _businessNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _mobileController.text.trim(),
          address: _addressController.text.trim(),
          purpose: _purposeController.text.trim(),
          empType: _empTypeController.text.trim(),
          visitFor: _visitForController.text.trim(),
          photo: _newProfileImage != null
              ? _newProfileImage!.path
              : (widget.profile.photo ?? savedRetailer.photo),
        );
        await RetailerSessionManager.saveLoginData(updatedRetailer);
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Failed',
            style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w700),
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Top Sheet Drag Handle & Title Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: AppColors.primaryGold, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Retailer Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + keyboardHeight),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Photo Avatar with Edit Badge
                    _buildAvatarSection(),
                    const SizedBox(height: 18),

                    // Visiter ID Display Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.fingerprint_rounded, color: AppColors.primaryGreen, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Visiter ID',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _resolvedRetailerId ?? widget.profile.visiterId ?? widget.profile.retailerId ?? 'Loading...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Personal & Business Details Card
                    _buildFormCard(
                      title: 'Personal & Business Details',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Person Name *',
                          hint: 'Enter your full name',
                          icon: Icons.person_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Person name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _businessNameController,
                          label: 'Business / Store Name',
                          hint: 'e.g. Durvasa Ayurveda Store',
                          icon: Icons.storefront_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _purposeController,
                          label: 'Purpose / Role',
                          hint: 'e.g. Retailer',
                          icon: Icons.category_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _fatherNameController,
                          label: "Father's Name",
                          hint: "Enter father's name",
                          icon: Icons.family_restroom_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildGenderDropdown(),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _billedGroupController,
                          label: 'Billed Group',
                          hint: 'e.g. Group A, Retailer Tier 1',
                          icon: Icons.category_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. Contact Details Card
                    _buildFormCard(
                      title: 'Contact Information',
                      icon: Icons.phone_outlined,
                      children: [
                        _buildInputField(
                          controller: _mobileController,
                          label: 'Primary Mobile *',
                          hint: 'Enter 10-digit mobile number',
                          icon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Mobile is required';
                            if (val.trim().length != 10) return 'Enter 10-digit number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _mobileAltController,
                          label: 'Alternate Mobile',
                          hint: 'Alternate contact number',
                          icon: Icons.phone_iphone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _emergenceNoController,
                          label: 'Emergency Contact No',
                          hint: 'Emergency phone number',
                          icon: Icons.emergency_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'your.email@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3. Representative & Visit Information Card
                    _buildFormCard(
                      title: 'Representative & Visit Details',
                      icon: Icons.badge_outlined,
                      children: [
                        _buildInputField(
                          controller: _empNameController,
                          label: 'Assigned MR / Officer Name',
                          hint: 'e.g. Amit Sharma',
                          icon: Icons.support_agent_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _empMobileController,
                          label: 'MR Contact Number',
                          hint: 'e.g. 9123456788',
                          icon: Icons.phone_in_talk_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _employeeIdController,
                          label: 'MR Employee ID',
                          hint: 'e.g. EMP348109',
                          icon: Icons.badge_rounded,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _empTypeController,
                                label: 'Employment Type',
                                hint: 'e.g. Permanent',
                                icon: Icons.work_history_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                controller: _visitForController,
                                label: 'Visit For',
                                hint: 'e.g. Business Development',
                                icon: Icons.business_center_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRevisitedDropdown(),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _remarkController,
                          label: 'Remark / Notes',
                          hint: 'e.g. Profile updated successfully',
                          icon: Icons.notes_rounded,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. Address & Location Card
                    _buildFormCard(
                      title: 'Pharmacy & Location Address',
                      icon: Icons.storefront_outlined,
                      children: [
                        _buildInputField(
                          controller: _addressController,
                          label: 'Store / Business Address',
                          hint: 'Shop / Complex number, Street, Landmark',
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _districtController,
                                label: 'District',
                                hint: 'District name',
                                icon: Icons.location_city_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                controller: _blockController,
                                label: 'Block',
                                hint: 'Block name',
                                icon: Icons.domain_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'State name',
                                icon: Icons.public_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                controller: _postOfficeController,
                                label: 'Post Office',
                                hint: 'Post Office name',
                                icon: Icons.local_post_office_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInputField(
                          controller: _countryController,
                          label: 'Country',
                          hint: 'India',
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 5. Security Details Card
                    _buildFormCard(
                      title: 'Account Security',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        _buildInputField(
                          controller: _passwordController,
                          label: 'New Password (Optional)',
                          hint: 'Leave blank to keep existing password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryGold, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Save & Update Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR PICKER WIDGET
  // ============================================================
  Widget _buildAvatarSection() {
    final existingUrl = widget.profile.resolvedImageUrl;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 95,
            width: 95,
            padding: const EdgeInsets.all(3),
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
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
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
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: _newProfileImage != null
                    ? Image.file(
                        _newProfileImage!,
                        fit: BoxFit.cover,
                      )
                    : existingUrl.isNotEmpty
                        ? Image.network(
                            existingUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.storefront_rounded,
                              size: 48,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : const Icon(
                            Icons.storefront_rounded,
                            size: 48,
                            color: AppColors.primaryGreen,
                          ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORM CARD CONTAINER
  // ============================================================
  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INPUT FIELD HELPER
  // ============================================================
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(icon, size: 18, color: AppColors.primaryGold),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.creamBackground.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGold.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGold.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENDER DROPDOWN
  // ============================================================
  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedGender = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RE-VISITED DROPDOWN
  // ============================================================
  Widget _buildRevisitedDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Re-Visited Status',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedRevisited,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold),
              items: ['No', 'Yes'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedRevisited = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

