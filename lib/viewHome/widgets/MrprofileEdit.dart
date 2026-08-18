import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/TodoModel1.dart';
import '../../service/edit_employee_profile_service.dart';

class MrProfileEditSheet extends StatefulWidget {
  final Data1 employeeData;
  final VoidCallback onProfileUpdated;

  const MrProfileEditSheet({
    super.key,
    required this.employeeData,
    required this.onProfileUpdated,
  });

  @override
  State<MrProfileEditSheet> createState() => _MrProfileEditSheetState();
}

class _MrProfileEditSheetState extends State<MrProfileEditSheet> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _mobileAltController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fatherNameController;
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  late TextEditingController _postOfficeController;
  late TextEditingController _blockController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _emergenceNoController;
  late TextEditingController _bloodGroupController;

  File? _newProfileImage;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final data = widget.employeeData;
    _nameController = TextEditingController(text: data.name ?? '');
    _mobileController = TextEditingController(text: data.mobile ?? '');
    _mobileAltController = TextEditingController(text: data.mobileAlt ?? '');
    _emailController = TextEditingController(text: data.email ?? '');
    _passwordController = TextEditingController();
    _fatherNameController = TextEditingController(text: data.fatherName ?? '');
    _genderController = TextEditingController(text: data.gender ?? '');
    _addressController = TextEditingController(text: data.address ?? '');
    _postOfficeController = TextEditingController(text: data.postOffice ?? '');
    _blockController = TextEditingController(text: data.block ?? '');
    _districtController = TextEditingController(text: data.district ?? '');
    _stateController = TextEditingController(text: data.state ?? '');
    _countryController = TextEditingController(text: data.country ?? 'India');
    _emergenceNoController = TextEditingController(text: data.emergenceNo ?? '');
    _bloodGroupController = TextEditingController(text: data.billedGroup ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _mobileAltController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fatherNameController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _postOfficeController.dispose();
    _blockController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
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
      backgroundColor: Colors.white,
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
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Colors.deepPurple),
                title: Text('Take Photo from Camera', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.deepPurple),
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
    // 1. Resolve EmpId and EmployeeId with multiple robust fallbacks so they always match
    final resolvedEmpId = (widget.employeeData.empId != null && widget.employeeData.empId!.trim().isNotEmpty)
        ? widget.employeeData.empId!.trim()
        : (widget.employeeData.employeeId != null && widget.employeeData.employeeId!.trim().isNotEmpty)
            ? widget.employeeData.employeeId!.trim()
            : (widget.employeeData.employeeCode != null && widget.employeeData.employeeCode!.trim().isNotEmpty)
                ? widget.employeeData.employeeCode!.trim()
                : (widget.employeeData.id != null ? widget.employeeData.id.toString() : '');

    setState(() => _isSubmitting = true);

    try {
      final response = await EditEmployeeProfileService.editEmployeeProfile(
        empId: resolvedEmpId,
        employeeId: resolvedEmpId,
        id: widget.employeeData.id,
        employeeCode: widget.employeeData.employeeCode ?? resolvedEmpId,
        userId: widget.employeeData.userId,
        password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
        joinDate: widget.employeeData.joinDate,
        gender: _genderController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : (widget.employeeData.name ?? ''),
        fatherName: _fatherNameController.text.trim(),
        address: _addressController.text.trim(),
        mobile: _mobileController.text.trim().isNotEmpty ? _mobileController.text.trim() : (widget.employeeData.mobile ?? ''),
        mobileAlt: _mobileAltController.text.trim(),
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : (widget.employeeData.email ?? ''),
        postOffice: _postOfficeController.text.trim(),
        country: _countryController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        block: _blockController.text.trim(),
        employeeType: widget.employeeData.employeeType ?? 'MR',
        emergenceNo: _emergenceNoController.text.trim(),
        billedGroup: _bloodGroupController.text.trim(),
        profileImageFile: _newProfileImage,
      );

      debugPrint('Edit Employee Profile response: ${response.message}');

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  response.message.isNotEmpty ? response.message : 'Profile updated successfully!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Failed',
            style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w700),
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: GoogleFonts.poppins(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
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
    final imageUrl = widget.employeeData.resolvedImageUrl;
    final displayEmpId = widget.employeeData.empId ?? widget.employeeData.employeeId ?? 'N/A';

    return Container(
      height: mediaQuery.size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
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

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit MR Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      'Emp ID: $displayEmpId',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Picker Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.deepPurple.shade300, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _newProfileImage != null
                                ? Image.file(_newProfileImage!, fit: BoxFit.cover)
                                : imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 55,
                                          color: Colors.deepPurple,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 55,
                                        color: Colors.deepPurple,
                                      ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section: Personal Details
                  _buildSectionTitle('Personal Details', Icons.person_outline),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name (Non-Editable)',
                    icon: Icons.person_rounded,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock_outline, size: 17, color: Colors.grey),
                  ),
                  _buildTextField(
                    controller: _fatherNameController,
                    label: 'Father\'s Name (Non-Editable)',
                    icon: Icons.family_restroom_outlined,
                    readOnly: true,
                    suffixIcon: const Icon(Icons.lock_outline, size: 17, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _genderController,
                          label: 'Gender',
                          icon: Icons.wc_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _bloodGroupController,
                          label: 'Blood Group',
                          icon: Icons.bloodtype_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Section: Contact Details
                  _buildSectionTitle('Contact Details', Icons.contact_phone_outlined),
                  _buildTextField(
                    controller: _mobileController,
                    label: 'Primary Mobile',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _mobileAltController,
                    label: 'Alternate Mobile',
                    icon: Icons.phone_iphone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _emergenceNoController,
                    label: 'Emergency Contact Number',
                    icon: Icons.emergency_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),

                  // Section: Address & Territory
                  _buildSectionTitle('Address & Territory', Icons.location_on_outlined),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Residential / Office Address',
                    icon: Icons.home_outlined,
                    maxLines: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _postOfficeController,
                          label: 'Post Office',
                          icon: Icons.local_post_office_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _blockController,
                          label: 'Block',
                          icon: Icons.domain_outlined,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _districtController,
                          label: 'District',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.public_outlined,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 10),

                  // Section: Account Security
                  _buildSectionTitle('Account Security', Icons.lock_outline),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password (leave blank to keep current)',
                    icon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Save Profile Changes',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple[800],
            ),
          ),
        ],
      ),
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
              color: readOnly ? Colors.grey[600] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: readOnly ? Colors.black54 : Colors.black87,
              fontWeight: readOnly ? FontWeight.w500 : FontWeight.normal,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: readOnly ? Colors.grey[500] : Colors.deepPurple,
                size: 19,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: readOnly ? Colors.grey[300]! : Colors.deepPurple,
                  width: readOnly ? 1.0 : 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
