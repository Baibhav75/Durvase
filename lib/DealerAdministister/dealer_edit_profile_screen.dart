import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../model/Dealer_Model/dealer_profile_model.dart';
import '../service/Dealer_service/dealer_edit_profile_service.dart';


class EditDealerProfileSheet extends StatefulWidget {
  final DealerProfileModel profile;
  final String dealerId;
  final VoidCallback onProfileUpdated;

  const EditDealerProfileSheet({
    super.key,
    required this.profile,
    required this.dealerId,
    required this.onProfileUpdated,
  });

  @override
  State<EditDealerProfileSheet> createState() => _EditDealerProfileSheetState();
}

class _EditDealerProfileSheetState extends State<EditDealerProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _gstController;
  late final TextEditingController _addressController;

  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _passwordController = TextEditingController();
    _gstController = TextEditingController(text: widget.profile.gstNumber ?? '');
    _addressController = TextEditingController(text: widget.profile.businessAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name and phone are required', style: GoogleFonts.poppins(color: AppColors.white)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await DealerEditProfileService.updateProfile(
      dealerId: widget.dealerId,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      gstNumber: _gstController.text.trim(),
      businessAddress: _addressController.text.trim(),
      imageFile: _pickedImage,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      Navigator.pop(context);
      widget.onProfileUpdated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'], style: GoogleFonts.poppins(color: AppColors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Edit Dealer Profile',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 18),

              // Profile photo picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 2),
                          color: AppColors.creamBackground,
                        ),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : (widget.profile.resolvedImageUrl.isNotEmpty
                              ? Image.network(
                            widget.profile.resolvedImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.storefront_rounded,
                              size: 40,
                              color: AppColors.primaryGreen,
                            ),
                          )
                              : const Icon(
                            Icons.storefront_rounded,
                            size: 40,
                            color: AppColors.primaryGreen,
                          )),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: AppColors.darkGreen),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              _buildLabel('Full Name'),
              const SizedBox(height: 6),
              _buildField(controller: _nameController, hint: 'Enter full name', icon: Icons.person_outline),
              const SizedBox(height: 14),

              _buildLabel('Email'),
              const SizedBox(height: 6),
              _buildField(controller: _emailController, hint: 'Enter email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),

              _buildLabel('Phone'),
              const SizedBox(height: 6),
              _buildField(controller: _phoneController, hint: 'Enter phone number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),

              _buildLabel('New Password (optional)'),
              const SizedBox(height: 6),
              _buildField(controller: _passwordController, hint: 'Leave blank to keep current', icon: Icons.lock_outline, obscureText: true),
              const SizedBox(height: 14),

              _buildLabel('GST Number'),
              const SizedBox(height: 6),
              _buildField(controller: _gstController, hint: 'Enter GST number', icon: Icons.receipt_long_outlined),
              const SizedBox(height: 14),

              _buildLabel('Business Address'),
              const SizedBox(height: 6),
              _buildField(controller: _addressController, hint: 'Enter business address', icon: Icons.location_on_outlined, maxLines: 2),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                      : Text(
                    'Save Changes',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 20),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}