import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../model/TodoModel1.dart';
import '/model/location_dart_model.dart';
import '/service/dynamic_location_service.dart';
import '/service/visitor_service.dart';

class NewVisitForm extends StatefulWidget {
  final Data1? employeeData;

  const NewVisitForm({super.key, this.employeeData});

  @override
  _NewVisitFormState createState() => _NewVisitFormState();
}

class _NewVisitFormState extends State<NewVisitForm> {
  String visitType = 'Doctor';
  String? selectedPurpose;
  bool? reVisitRequired;
  DateTime? _selectedReVisitDate;

  // Location dropdown values
  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;

  // Location data
  LocationDataModel? _locationData;
  List<LocationItem> _states = [];
  List<LocationItem> _districts = [];
  List<LocationItem> _blocks = [];

  // Form state
  bool isLoading = false;
  bool isSubmitting = false;
  bool _isLoadingLocationData = false;
  String _locationError = '';

  // Camera related variables
  File? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final businessNameController = TextEditingController();
  final personNameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final remarksController = TextEditingController();
  final passwordController = TextEditingController();

  final List<String> purposes = ['Meeting', 'Survey', 'Follow-up'];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  @override
  void dispose() {
    businessNameController.dispose();
    personNameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    remarksController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Load location data from API
  Future<void> _loadLocationData() async {
    final employeeId =
        widget.employeeData?.employeeId ?? widget.employeeData?.empId;

    if (employeeId == null || employeeId.isEmpty) {
      setState(() {
        _locationError =
            'Employee ID not available. Please try again or contact support.';
      });
      return;
    }

    setState(() {
      _isLoadingLocationData = true;
      _locationError = '';
    });

    try {
      final locationData = await DynamicLocationService.getLocationData(
        employeeId,
      );

      if (mounted) {
        setState(() {
          _locationData = locationData;
          _states = locationData?.states ?? [];
          _isLoadingLocationData = false;

          // Set default selections if available
          if (_states.isNotEmpty) {
            selectedState = _states.first.name;
            _updateDistricts(_states.first);
          } else {
            _locationError = 'No location data available for this employee.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocationData = false;
          _locationError =
              'Failed to load location data. Please check your connection and retry.';
        });
      }
    }
  }

  void _updateDistricts(LocationItem state) {
    setState(() {
      _districts = state.districts ?? [];
      selectedDistrict = _districts.isNotEmpty ? _districts.first.name : null;
      _blocks = [];
      selectedBlock = null;

      if (_districts.isNotEmpty) {
        _updateBlocks(_districts.first);
      }
    });
  }

  void _updateBlocks(LocationItem district) {
    setState(() {
      _blocks = district.blocks ?? [];
      selectedBlock = _blocks.isNotEmpty ? _blocks.first.name : null;
    });
  }

  void _onStateChanged(String? newStateName) {
    if (newStateName == null) return;

    final selectedStateItem = _states.firstWhere(
      (state) => state.name == newStateName,
      orElse: () => LocationItem(),
    );

    setState(() {
      selectedState = newStateName;
      selectedDistrict = null;
      selectedBlock = null;
      _districts = [];
      _blocks = [];
    });

    if (selectedStateItem.name != null) {
      _updateDistricts(selectedStateItem);
    }
  }

  void _onDistrictChanged(String? newDistrictName) {
    if (newDistrictName == null) return;

    final selectedDistrictItem = _districts.firstWhere(
      (district) => district.name == newDistrictName,
      orElse: () => LocationItem(),
    );

    setState(() {
      selectedDistrict = newDistrictName;
      selectedBlock = null;
      _blocks = [];
    });

    if (selectedDistrictItem.name != null) {
      _updateBlocks(selectedDistrictItem);
    }
  }

  void _onBlockChanged(String? newBlockName) {
    setState(() {
      selectedBlock = newBlockName;
    });
  }

  // Convert image to base64
  String? _imageToBase64(File? imageFile) {
    if (imageFile == null) return null;
    try {
      final bytes = imageFile.readAsBytesSync();
      return base64Encode(bytes);
    } catch (_) {
      return null;
    }
  }

  // Format date for API (YYYY-MM-DDTHH:mm:ss)
  String _formatDateForAPI(DateTime date) {
    final now = DateTime.now();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  // Camera permission methods
  Future<bool> _checkCameraPermission() async {
    try {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return false;
      }

      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Camera Permission Required',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        content: Text(
          'Please enable camera permission from app settings to capture visit site images.',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Open Settings', style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  // Image capture methods
  Future<void> _captureImage() async {
    try {
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _capturedImage = File(pickedFile.path);
        });

        _showSnackBar('Image captured successfully', AppColors.primaryGreen);
      }
    } catch (_) {
      _showSnackBar('Failed to capture image. Please try again.', AppColors.error);
    }
  }

  void _removeImage() {
    setState(() {
      _capturedImage = null;
    });
  }

  // Date picker method
  Future<void> _selectReVisitDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryGreen,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedReVisitDate) {
      setState(() {
        _selectedReVisitDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Form validation
  bool _validateForm() {
    if (businessNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter business name', AppColors.warning);
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter password', AppColors.warning);
      return false;
    }

    if (personNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter contact person name', AppColors.warning);
      return false;
    }

    if (mobileController.text.trim().isEmpty) {
      _showSnackBar('Please enter mobile number', AppColors.warning);
      return false;
    }

    if (mobileController.text.trim().length != 10) {
      _showSnackBar('Please enter a valid 10-digit mobile number', AppColors.warning);
      return false;
    }

    if (_states.isNotEmpty) {
      if (selectedState == null) {
        _showSnackBar('Please select state', AppColors.warning);
        return false;
      }
      if (selectedDistrict == null) {
        _showSnackBar('Please select district', AppColors.warning);
        return false;
      }
      if (selectedBlock == null) {
        _showSnackBar('Please select block', AppColors.warning);
        return false;
      }
    }

    if (reVisitRequired == true && _selectedReVisitDate == null) {
      _showSnackBar('Please select a re-visit date', AppColors.warning);
      return false;
    }

    return true;
  }

  // Submit Handler with API Call
  Future<void> _handleSubmit() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final String empType = widget.employeeData?.employeeType ?? "Employee";
      final String empMobile = widget.employeeData?.mobile ?? "";
      final String empName = widget.employeeData?.name ?? "Unknown Employee";
      final String empId = widget.employeeData?.employeeId ?? widget.employeeData?.empId ?? "EMP000000";
      final String visitDate = _formatDateForAPI(DateTime.now());
      final String empPassword = passwordController.text.trim();

      final calculatedRevisitDate = reVisitRequired == true && _selectedReVisitDate != null
          ? _formatDateForAPI(_selectedReVisitDate!)
          : null;

      final result = await VisitorService.submitVisitorData(
        empType: empType,
        empMobile: empMobile,
        empName: empName,
        empId: empId,
        employeeId: empId,
        password: empPassword,
        visitFor: visitType,
        country: 'India',
        state: selectedState ?? widget.employeeData?.state ?? '',
        district: selectedDistrict ?? widget.employeeData?.district ?? '',
        block: selectedBlock ?? widget.employeeData?.block ?? '',
        businessName: businessNameController.text.trim(),
        personName: personNameController.text.trim(),
        mobile: mobileController.text.trim(),
        address: addressController.text.trim(),
        purpose: selectedPurpose ?? purposes.first,
        reVisited: reVisitRequired == true ? 'Yes' : 'No',
        remark: remarksController.text.trim(),
        imageFile: _capturedImage,
        photoBase64: _imageToBase64(_capturedImage),
        reVisitDate: calculatedRevisitDate, visitDate: '',
      );

      setState(() {
        isSubmitting = false;
      });

      if (result['success'] == true) {
        _showSnackBar(result['message'] ?? 'Visit submitted successfully!', AppColors.primaryGreen);
        _clearForm();

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnackBar(result['message'] ?? 'Failed to submit visit.', AppColors.error);
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      _showSnackBar('Error submitting form. Please try again.', AppColors.error);
    }
  }

  void _clearForm() {
    businessNameController.clear();
    personNameController.clear();
    mobileController.clear();
    addressController.clear();
    remarksController.clear();
    setState(() {
      selectedPurpose = null;
      reVisitRequired = null;
      _selectedReVisitDate = null;
      _capturedImage = null;
      visitType = 'Doctor';
      selectedState = null;
      selectedDistrict = null;
      selectedBlock = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empName = widget.employeeData?.name ?? 'Employee';
    final empId = widget.employeeData?.employeeId ?? widget.employeeData?.empId;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(
          "New Visit Form",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (empId != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                  ),
                  child: Text(
                    'ID: $empId',
                    style: GoogleFonts.poppins(
                      color: AppColors.lightGold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              children: [
                // 1. Employee Info Banner
                _buildEmployeeInfoCard(empName, empId),
                const SizedBox(height: 14),

                // 2. Visit Category Type Section
                _buildSection(
                  "Visit Information",
                  Icons.category_rounded,
                  child: _buildVisitTypeSection(),
                ),

                // 3. Dynamic Location Section
                _buildSection(
                  "Location Information",
                  Icons.map_rounded,
                  child: _buildLocationSection(),
                ),

                // 4. Business & Customer Information Section
                _buildSection(
                  "Business Information",
                  Icons.storefront_rounded,
                  child: Column(
                    children: [
                      _buildTextField(
                        "Business / Clinic Name",
                        Icons.business_rounded,
                        businessNameController,
                      ),
                      _buildTextField(
                        "Person / Doctor Name",
                        Icons.person_rounded,
                        personNameController,
                      ),
                      _buildTextField(
                        "Mobile Number",
                        Icons.phone_rounded,
                        mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      ),
                      _buildTextField(
                        "Address",
                        Icons.location_on_rounded,
                        addressController,
                        maxLines: 2,
                      ),
                      _buildTextField(
                        "Password",
                        Icons.lock_rounded,
                        passwordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      _buildDropdown(
                        "Select Visit Purpose",
                        purposes,
                        selectedPurpose,
                        (value) => setState(() => selectedPurpose = value),
                        Icons.assignment_turned_in_rounded,
                      ),
                    ],
                  ),
                ),

                // 5. Visited Location Photo Section
                _buildSection(
                  "Capture Location Photo",
                  Icons.camera_alt_rounded,
                  child: _buildPhotoCaptureSection(),
                ),

                // 6. Re-visit Requirement Section
                _buildSection(
                  "Re-Visit Requirement",
                  Icons.event_repeat_rounded,
                  child: _buildRevisitSection(),
                ),

                // 7. Remarks Section
                _buildSection(
                  "Remarks & Notes",
                  Icons.rate_review_rounded,
                  child: _buildTextField(
                    "Enter additional visit remarks or notes...",
                    Icons.note_alt_rounded,
                    remarksController,
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: 12),

                // 8. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    onPressed: isSubmitting ? null : _handleSubmit,
                    icon: isSubmitting
                        ? const SizedBox.shrink()
                        : const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
                    label: isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : Text(
                            "Submit Visit",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (isSubmitting) _buildSubmissionOverlay(),
        ],
      ),
    );
  }

  // ========== HELPER BUILDERS ==========

  Widget _buildEmployeeInfoCard(String empName, String? empId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.darkGreen,
            AppColors.primaryGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
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
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primaryGreen, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  empName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.employeeData?.employeeType ?? "Medical Representative"} • ID: ${empId ?? "N/A"}',
                  style: GoogleFonts.poppins(
                    color: AppColors.lightGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.employeeData?.mobile != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '📞 ${widget.employeeData!.mobile}',
                    style: GoogleFonts.poppins(
                      color: AppColors.white.withOpacity(0.85),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 19, color: AppColors.primaryGreen),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildVisitTypeSection() {
    final types = ['Doctor', 'Medical Hall', 'Other'];
    return Row(
      children: types.map((type) {
        final isSelected = visitType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => visitType = type),
            child: Container(
              margin: EdgeInsets.only(
                right: type != types.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.7),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationSection() {
    if (_isLoadingLocationData) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading dynamic location data...',
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_locationError.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              _locationError,
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontSize: 12.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadLocationData,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
              label: Text(
                'Retry Loading',
                style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_states.isNotEmpty) {
      return Column(
        children: [
          _buildLocationDropdown(
            "State",
            _states.map((s) => s.name ?? '').where((n) => n.isNotEmpty).toList(),
            selectedState,
            _onStateChanged,
            Icons.public_rounded,
          ),
          const SizedBox(height: 12),
          _buildLocationDropdown(
            "District",
            _districts.map((d) => d.name ?? '').where((n) => n.isNotEmpty).toList(),
            selectedDistrict,
            _onDistrictChanged,
            Icons.location_city_rounded,
          ),
          const SizedBox(height: 12),
          _buildLocationDropdown(
            "Block",
            _blocks.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList(),
            selectedBlock,
            _onBlockChanged,
            Icons.domain_rounded,
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_rounded,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'No assigned territory areas found',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please verify your work profile assignment with administrator.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCaptureSection() {
    return Column(
      children: [
        if (_capturedImage != null) ...[
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.creamBackground,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: AppColors.warning, size: 40),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                label: Text(
                  'Remove Photo',
                  style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
              const SizedBox(width: 14),
              TextButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen, size: 18),
                label: Text(
                  'Retake Photo',
                  style: GoogleFonts.poppins(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.6),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 28, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Capture Visit Site Photo",
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Tap here to take real-time camera photo",
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRevisitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    reVisitRequired = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: reVisitRequired == true ? AppColors.primaryGreen : AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: reVisitRequired == true ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        reVisitRequired == true ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                        size: 17,
                        color: reVisitRequired == true ? AppColors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Re-visit Needed (Yes)",
                        style: GoogleFonts.poppins(
                          fontWeight: reVisitRequired == true ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          color: reVisitRequired == true ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    reVisitRequired = false;
                    _selectedReVisitDate = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: reVisitRequired == false ? AppColors.primaryGreen : AppColors.creamBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: reVisitRequired == false ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        reVisitRequired == false ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                        size: 17,
                        color: reVisitRequired == false ? AppColors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "No Re-visit",
                        style: GoogleFonts.poppins(
                          fontWeight: reVisitRequired == false ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          color: reVisitRequired == false ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (reVisitRequired == true) ...[
          const SizedBox(height: 14),
          Text(
            "Schedule Re-visit Date:",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectReVisitDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedReVisitDate != null ? AppColors.primaryGreen : AppColors.lightGold.withOpacity(0.8),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedReVisitDate != null
                          ? _formatDate(_selectedReVisitDate!)
                          : "Select future date...",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: _selectedReVisitDate != null ? FontWeight.w600 : FontWeight.w400,
                        color: _selectedReVisitDate != null ? AppColors.textDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationDropdown(
    String label,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.creamBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: selectedItem,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      dropdownColor: AppColors.white,
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? selectedItem,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          filled: true,
          fillColor: AppColors.creamBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        value: selectedItem,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: onChanged,
        dropdownColor: AppColors.white,
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          filled: true,
          fillColor: AppColors.creamBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.lightGold.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          counterText: "",
        ),
        style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 13.5),
      ),
    );
  }

  Widget _buildSubmissionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightGold),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
              const SizedBox(height: 18),
              Text(
                'Submitting Visit Record...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please wait while data is synced',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
