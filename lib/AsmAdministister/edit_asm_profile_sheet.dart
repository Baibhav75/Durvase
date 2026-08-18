import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../controller/app_security_controller.dart';
import '../model/asm_profile_model.dart';
import '../service/asm_profile_service.dart';
import '../service/session_manager.dart';

class EditAsmProfileSheet extends StatefulWidget {
  final AsmProfileModel profile;
  final int asmId;
  final VoidCallback onProfileUpdated;

  const EditAsmProfileSheet({
    super.key,
    required this.profile,
    required this.asmId,
    required this.onProfileUpdated,
  });

  @override
  State<EditAsmProfileSheet> createState() => _EditAsmProfileSheetState();
}

class _EditAsmProfileSheetState extends State<EditAsmProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final AppSecurityController _securityController = Get.put(AppSecurityController());

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fathersNameController;
  late TextEditingController _regionController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;
  late TextEditingController _emergenceNoController;
  late TextEditingController _bloodGroupController;

  File? _newProfileImage;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name ?? '');
    _mobileController = TextEditingController(text: widget.profile.mobile ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _passwordController = TextEditingController();
    _fathersNameController = TextEditingController(
      text: widget.profile.fatherName ?? widget.profile.fathersName ?? '',
    );
    _regionController = TextEditingController(
      text: widget.profile.region ?? widget.profile.state ?? '',
    );
    _areaController = TextEditingController(
      text: widget.profile.area ?? widget.profile.district ?? '',
    );
    _addressController = TextEditingController(text: widget.profile.address ?? '');
    _emergenceNoController = TextEditingController(text: widget.profile.emergenceNo ?? '');
    _bloodGroupController = TextEditingController(text: widget.profile.billedGroup ?? widget.profile.bloodGroup ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fathersNameController.dispose();
    _regionController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _emergenceNoController.dispose();
    _bloodGroupController.dispose();
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
        setState(() {
          _newProfileImage = File(picked.path);
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

    setState(() => _isSubmitting = true);

    try {
      final response = await AsmProfileService.editAsmProfile(
        asmId: widget.asmId,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : null,
        email: _emailController.text.trim(),
        region: _regionController.text.trim(),
        area: _areaController.text.trim(),
        fathersName: _fathersNameController.text.trim(),
        address: _addressController.text.trim(),
        emergenceNo: _emergenceNoController.text.trim(),
        billedGroup: _bloodGroupController.text.trim(),
        profileImageFile: _newProfileImage,
      );

      debugPrint('Edit ASM Profile response: $response');

      // Update session cache if needed
      final currentLoginData = await SessionManager.getLoginData();
      if (currentLoginData != null) {
        currentLoginData.name = _nameController.text.trim();
        currentLoginData.email = _emailController.text.trim();
        currentLoginData.mobile = _mobileController.text.trim();
        await SessionManager.saveLoginData(currentLoginData);
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
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
              child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 45,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Title Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit ASM Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Form Fields
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Image Selector
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 95,
                            width: 95,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold, width: 2),
                            ),
                            child: ClipOval(
                              child: _newProfileImage != null
                                  ? Image.file(_newProfileImage!, fit: BoxFit.cover)
                                  : widget.profile.resolvedImageUrl.isNotEmpty
                                      ? Image.network(
                                          widget.profile.resolvedImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppColors.primaryGreen,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppColors.primaryGreen,
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Full Name
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name (Non-Editable)',
                      icon: Icons.person_outline,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        size: 17,
                        color: Colors.grey,
                      ),
                    ),

                    // 2. Mobile
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number *',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Please enter mobile' : null,
                    ),

                    // 3. Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address *',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter email';
                        if (!val.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),

                    // 4. Password (Optional)
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password (leave blank to keep current)',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    // 5. Father's Name
                    _buildTextField(
                      controller: _fathersNameController,
                      label: 'Father\'s Name (Non-Editable)',
                      icon: Icons.family_restroom_outlined,
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        size: 17,
                        color: Colors.grey,
                      ),
                    ),

                    // 6. Region
                    _buildTextField(
                      controller: _regionController,
                      label: 'Region (e.g. South, North)',
                      icon: Icons.map_outlined,
                    ),

                    // 7. Area
                    _buildTextField(
                      controller: _areaController,
                      label: 'Area (e.g. Sector 62, Noida)',
                      icon: Icons.location_city_outlined,
                    ),

                    // 8. Emergency Contact Number
                    _buildTextField(
                      controller: _emergenceNoController,
                      label: 'Emergency Contact Number',
                      icon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    // 9. Blood Group
                    _buildTextField(
                      controller: _bloodGroupController,
                      label: 'Blood Group (e.g. A+, O+, B+)',
                      icon: Icons.bloodtype_outlined,
                    ),

                    // 10. Address
                    _buildTextField(
                      controller: _addressController,
                      label: 'Full Residential Address',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),
                    _buildSecuritySection(),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : Text(
                                'Save Profile Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
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

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'App Security & Unlock',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
          ),
          child: Obx(() {
            final isFpEnabled = _securityController.isFingerprintEnabled.value;
            final fpDate = _securityController.fingerprintEnabledDate.value;
            final isBiometricSupported = _securityController.isBiometricSupported.value;

            final isPwdEnabled = _securityController.isAppPasswordEnabled.value;
            final pwdDate = _securityController.appPasswordEnabledDate.value;

            return Column(
              children: [
                // 1. Fingerprint Login Tile
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isFpEnabled
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      color: isFpEnabled ? AppColors.primaryGreen : Colors.grey.shade600,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Fingerprint Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Use fingerprint to unlock the app quickly.',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      if (!isBiometricSupported)
                        Text(
                          'Fingerprint authentication is not available on this device.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          isFpEnabled
                              ? (fpDate.isNotEmpty ? 'Enabled on: $fpDate' : 'Enabled')
                              : 'Disabled',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isFpEnabled ? AppColors.secondaryGreen : Colors.grey.shade500,
                            fontWeight: isFpEnabled ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  value: isFpEnabled,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (val) => _securityController.toggleFingerprint(val, context: context),
                ),

                Divider(height: 1, color: Colors.grey[200]),

                // 2. App Password Tile (Testing Mode: 1234)
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPwdEnabled
                          ? AppColors.primaryGreen.withOpacity(0.1)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: isPwdEnabled ? AppColors.primaryGreen : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'App Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        'Use a password to unlock the app (Test: 1234)',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPwdEnabled
                            ? (pwdDate.isNotEmpty ? 'Enabled on: $pwdDate' : 'Enabled')
                            : 'Disabled',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isPwdEnabled ? AppColors.secondaryGreen : Colors.grey.shade500,
                          fontWeight: isPwdEnabled ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  value: isPwdEnabled,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (val) => _securityController.toggleAppPassword(val, context: context),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
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
            readOnly: readOnly,
            obscureText: obscureText,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 19),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.creamBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
