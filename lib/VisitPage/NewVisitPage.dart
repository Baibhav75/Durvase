import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '/service/visitor_service.dart';
import '/service/dynamic_location_service.dart'; // Added import for dynamic location service
import '../model/TodoModel1.dart'; // For employee data
// Added import for location data model
import '/model/location_dart_model.dart';

class NewVisitForm extends StatefulWidget {
  final Data1? employeeData;

  const NewVisitForm({Key? key, this.employeeData}) : super(key: key);

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

  final List<String> purposes = ['Meeting', 'Survey', 'Follow-up'];

  @override
  void initState() {
    super.initState();
    _printEmployeeDetails();
    _loadLocationData();
  }

  void _printEmployeeDetails() {
    print('Employee Details:');
    print('Name: ${widget.employeeData?.name}');
    print('Mobile: ${widget.employeeData?.mobile}');
    print('Employee ID: ${widget.employeeData?.employeeId}');
    print('Emp ID: ${widget.employeeData?.empId}');
    print('Employee Type: ${widget.employeeData?.employeeType}');

    // Debug: Check if we have any ID field
    if (widget.employeeData?.employeeId == null &&
        widget.employeeData?.empId == null) {
      print('❌ ERROR: No employee ID available!');
    } else {
      print(
        '✅ Employee ID available: ${widget.employeeData?.employeeId ?? widget.employeeData?.empId}',
      );
    }
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
      print(
        '❌ Employee ID not available. employeeId: ${widget.employeeData?.employeeId}, empId: ${widget.employeeData?.empId}',
      );
      return;
    }

    setState(() {
      _isLoadingLocationData = true;
      _locationError = '';
    });

    try {
      print('📤 Fetching location data for employee ID: $employeeId');
      final locationData = await DynamicLocationService.getLocationData(
        employeeId,
      );

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
    } catch (e) {
      print('❌ Error loading location data: $e');
      setState(() {
        _isLoadingLocationData = false;
        _locationError =
        'Failed to load location data. Please check your internet connection and try again.';
      });
    }
  }

  void _updateDistricts(LocationItem state) {
    setState(() {
      _districts = state.districts ?? [];
      selectedDistrict = _districts.isNotEmpty ? _districts.first.name : null;
      _blocks = [];
      selectedBlock = null;

      // Update blocks if district is available
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
    } catch (e) {
      print('❌ Error converting image to base64: $e');
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
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Camera Permission Required', style: GoogleFonts.poppins()),
        content: Text(
          'Please enable camera permission from app settings to capture images.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Open Settings', style: GoogleFonts.poppins()),
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
        source: ImageSource.camera, // Only camera, no gallery option
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _capturedImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Image captured successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to capture image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text('Take Photo', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
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
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green[700],
            colorScheme: ColorScheme.light(primary: Colors.green[700]!),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
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

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Form validation
  bool _validateForm() {
    if (businessNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please enter business name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (personNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please enter person name'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (mobileController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please enter mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Only validate location fields if we have location data available
    if (_states.isNotEmpty) {
      if (selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Please select state'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Please select district'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      if (selectedBlock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Please select block'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (reVisitRequired == true && _selectedReVisitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Please select a re-visit date'),
          backgroundColor: Colors.red,
        ),
      );
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
      // Get employee details
      final String empType = widget.employeeData?.employeeType ?? "Employee";
      final String empMobile = widget.employeeData?.mobile ?? "";
      final String empName = widget.employeeData?.name ?? "Unknown Employee";
      final String empId = widget.employeeData?.employeeId ?? "EMP000000";

      print('🚀 Submitting visit data:');
      print('   👤 Employee: $empName ($empId)');
      print('   📞 Mobile: $empMobile');
      print('   🏢 Type: $empType');
      print('   🏥 Visit Type: $visitType');
      print('   🏢 Business: ${businessNameController.text}');
      print('   👨 Person: ${personNameController.text}');
      print('   📍 State: $selectedState');
      print('   📍 District: $selectedDistrict');
      print('   📍 Block: $selectedBlock');
      print('   📅 Re-Visited: ${reVisitRequired == true ? 'Yes' : 'No'}');
      
      final calculatedRevisitDate = reVisitRequired == true && _selectedReVisitDate != null
          ? _formatDateForAPI(_selectedReVisitDate!)
          : null;
      print('   📅 RevisitDate (Formatted): $calculatedRevisitDate');

      final result = await VisitorService.submitVisitorData(
        empType: empType,
        empMobile: empMobile,
        empName: empName,
        empId: empId,
        visitFor: visitType,
        country: 'India',
        state: selectedState ?? widget.employeeData?.state ?? '',
        district: selectedDistrict ?? widget.employeeData?.district ?? '',
        block: selectedBlock ?? widget.employeeData?.block ?? '',
        businessName: businessNameController.text,
        personName: personNameController.text,
        mobile: mobileController.text,
        address: addressController.text,
        purpose: selectedPurpose ?? purposes.first,
        reVisited: reVisitRequired == true ? 'Yes' : 'No',
        remark: remarksController.text,
        photoBase64: _imageToBase64(_capturedImage),
        reVisitDate: calculatedRevisitDate,
      );

      setState(() {
        isSubmitting = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${result['message'] ?? 'Visit submitted successfully!'}',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        _clearForm();

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${result['message'] ?? 'Failed to submit visit.'}',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error submitting form: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Clear form after submission
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
      // Reset location to default
      selectedState = null;
      selectedDistrict = null;
      selectedBlock = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Visit - ${widget.employeeData?.name ?? 'Employee'}",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          if (widget.employeeData?.employeeId != null)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'ID: ${widget.employeeData?.employeeId}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Employee Info Card
                _buildEmployeeInfoCard(),

                _buildSection(
                  "Visit Information",
                  child: _buildVisitTypeSection(),
                ),

                // DYNAMIC LOCATION SECTION
                _buildSection(
                  "Location Information",
                  child: Column(
                    children: [
                      if (_isLoadingLocationData)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Loading location data...',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                      if (_locationError.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$_locationError',
                                style: GoogleFonts.poppins(
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: _loadLocationData,
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.poppins(
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!_isLoadingLocationData &&
                          _locationError.isEmpty &&
                          _states.isNotEmpty)
                        Column(
                          children: [
                            _buildLocationDropdown(
                              "State",
                              _states
                                  .map((state) => state.name ?? '')
                                  .where((name) => name.isNotEmpty)
                                  .toList(),
                              selectedState,
                              _onStateChanged,
                              Icons.location_city,
                            ),
                            SizedBox(height: 12),
                            _buildLocationDropdown(
                              "District",
                              _districts
                                  .map((district) => district.name ?? '')
                                  .where((name) => name.isNotEmpty)
                                  .toList(),
                              selectedDistrict,
                              _onDistrictChanged,
                              Icons.map,
                            ),
                            SizedBox(height: 12),
                            _buildLocationDropdown(
                              "Block",
                              _blocks
                                  .map((block) => block.name ?? '')
                                  .where((name) => name.isNotEmpty)
                                  .toList(),
                              selectedBlock,
                              _onBlockChanged,
                              Icons.location_on,
                            ),
                          ],
                        ),
                      if (!_isLoadingLocationData &&
                          _locationError.isEmpty &&
                          _states.isEmpty &&
                          !_isLoadingLocationData)
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No location data available',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please contact your administrator to assign work areas.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                _buildSection(
                  "Business Information",
                  child: Column(
                    children: [
                      _buildTextField(
                        "Business Name",
                        Icons.business,
                        businessNameController,
                      ),
                      _buildTextField(
                        "Person Name",
                        Icons.person,
                        personNameController,
                      ),
                      _buildTextField(
                        "Mobile No.",
                        Icons.phone,
                        mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      ),
                      _buildTextField(
                        "Address",
                        Icons.location_on,
                        addressController,
                        maxLines: 2,
                      ),
                      _buildDropdown(
                        "Select Purpose",
                        purposes,
                        selectedPurpose,
                            (value) => setState(() => selectedPurpose = value),
                      ),
                    ],
                  ),
                ),

                _buildSection(
                  "Capture of visited location",
                  child: Column(
                    children: [
                      if (_capturedImage != null) ...[
                        Container(
                          width: 200,
                          height: 200,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _capturedImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Remove Image',
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _captureImage,
                            icon: Icon(
                              _capturedImage != null
                                  ? Icons.camera_alt_outlined
                                  : Icons.camera_alt,
                              color: Colors.green,
                            ),
                            label: Text(
                              _capturedImage != null
                                  ? "Retake Image"
                                  : "Capture Image",
                              style: GoogleFonts.poppins(
                                color: Colors.green[700],
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                _buildSection(
                  "Re-visited date (if required... )",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: reVisitRequired,
                            onChanged: (value) {
                              setState(() {
                                reVisitRequired = value;
                                if (value == false) {
                                  _selectedReVisitDate = null;
                                }
                              });
                            },
                          ),
                          Text("Yes", style: GoogleFonts.poppins()),
                          SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: reVisitRequired,
                            onChanged: (value) {
                              setState(() {
                                reVisitRequired = value;
                                _selectedReVisitDate = null;
                              });
                            },
                          ),
                          Text("No", style: GoogleFonts.poppins()),
                        ],
                      ),
                      if (reVisitRequired == true) ...[
                        SizedBox(height: 16),
                        Text(
                          "Select Re-visit Date:",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _selectReVisitDate,
                            icon: Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            label: Text(
                              _selectedReVisitDate != null
                                  ? _formatDate(_selectedReVisitDate!)
                                  : "Select Date",
                              style: GoogleFonts.poppins(
                                color: _selectedReVisitDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        if (_selectedReVisitDate != null) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[100]!),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Selected Date: ${_formatDate(_selectedReVisitDate!)}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[800],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedReVisitDate = null;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_selectedReVisitDate == null) ...[
                          SizedBox(height: 8),
                          Text(
                            "Please select a future date for re-visit",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                _buildSection(
                  "Remarks",
                  child: _buildTextField(
                    "Enter remarks",
                    Icons.note_alt,
                    remarksController,
                    maxLines: 3,
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSubmitting ? null : _handleSubmit,
                    child: isSubmitting
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : Text(
                      "Submit Visit",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (isSubmitting) _buildSubmissionOverlay(),
        ],
      ),
    );
  }

  // ========== HELPER METHODS ==========

  Widget _buildEmployeeInfoCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.employeeData?.name ?? "Unknown Employee"}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${widget.employeeData?.employeeId ?? "N/A"} | ${widget.employeeData?.employeeType ?? "Employee"}',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mobile: ${widget.employeeData?.mobile ?? "N/A"}',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, {required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildVisitTypeSection() {
    return Row(
      children: ['Doctor', 'Medical Hall', 'Other'].map((type) {
        return Expanded(
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: type,
            groupValue: visitType,
            title: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
            onChanged: (value) => setState(() => visitType = value!),
          ),
        );
      }).toList(),
    );
  }

  // NEW METHOD FOR LOCATION DROPDOWNS
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
        labelStyle: GoogleFonts.poppins(
          color: Colors.black87,
        ), // ✅ Label color black
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      value: selectedItem,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.poppins(
              color: Colors.black, // ✅ Dropdown item text black
            ),
          ),
        ),
      )
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
      style: GoogleFonts.poppins(
        color: Colors.black,
      ), // ✅ Selected value text black
      dropdownColor: Colors.white,
    );
  }

  Widget _buildDropdown(
      String hint,
      List<String> items,
      String? selectedItem,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.poppins(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      value: selectedItem,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins()),
        ),
      )
          .toList(),
      onChanged: onChanged,
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
          labelStyle: GoogleFonts.poppins(),
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          counterText: "",
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildSubmissionOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              ),
              SizedBox(height: 16),
              Text(
                'Submitting Visit...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
