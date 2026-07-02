/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// Import your existing models
import '/model/MrEmpState_model.dart';
import '/model/MrEmpDistrict_model.dart';
import '/model/MrEmpBlock_model.dart';
import '/model/mr_model.dart'; // Import MrModel for the main API response

class LocationNewService extends StatefulWidget {
  final String employeeId;
  final String employeeName;
  final Function(String state, String district, String block)? onLocationSelected;

  const LocationNewService({
    Key? key,
    required this.employeeId,
    required this.employeeName,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationNewServiceState createState() => _LocationNewServiceState();
}

class _LocationNewServiceState extends State<LocationNewService> {
  // API Base URL - Using the correct API endpoint from your project
  static const String BASE_URL = "https://durvasaayurved.online/API";

  // Selected values
  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;

  // Lists for dropdown data
  List<Datas3> statesList = [];
  List<Datas4> districtsList = [];
  List<Datas5> blocksList = [];

  // Full lists for filtering
  List<Datas1> fullWorkAreaList = [];

  // Loading states
  bool isLoading = false;

  // Error messages
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  // ========== API CALL METHODS ==========

  // Load all location data from the single API endpoint
  Future<void> _loadLocationData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Fetch work area data from the single endpoint
      final response = await http.get(
        Uri.parse('$BASE_URL/WorkAreaMR?EmployeeId=${widget.employeeId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final MrModel workAreaModel = MrModel.fromJson(responseData);

        // Store the full work area list for filtering
        fullWorkAreaList = workAreaModel.datas1 ?? [];

        // Extract unique states from the work area data
        Set<String> uniqueStates = {};
        if (workAreaModel.datas1 != null) {
          for (var item in workAreaModel.datas1!) {
            if (item.state != null && item.state!.isNotEmpty) {
              uniqueStates.add(item.state!);
            }
          }
        }

        // Convert sets to lists for dropdowns using the specific models
        List<Datas3> stateItems = uniqueStates.map((state) =>
          Datas3(id: 0, empName: widget.employeeName, state: state, status: "Active")
        ).toList();

        setState(() {
          statesList = stateItems;
          isLoading = false;
        });

        if (statesList.isEmpty) {
          setState(() {
            errorMessage = 'No work areas assigned to this employee';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load location data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading location data: $e';
        isLoading = false;
      });
    }
  }

  // Filter districts based on selected state
  void _filterDistricts(String state) {
    Set<String> uniqueDistricts = {};

    for (var item in fullWorkAreaList) {
      if (item.state == state && item.district != null && item.district!.isNotEmpty) {
        uniqueDistricts.add(item.district!);
      }
    }

    List<Datas4> districtItems = uniqueDistricts.map((district) =>
      Datas4(id: 0, empName: widget.employeeName, district: district, status: "Active")
    ).toList();

    setState(() {
      districtsList = districtItems;
      selectedDistrict = null;
      blocksList = [];
      selectedBlock = null;
    });
  }

  // Filter blocks based on selected district
  void _filterBlocks(String district) {
    Set<String> uniqueBlocks = {};

    for (var item in fullWorkAreaList) {
      if (item.district == district && item.blockName != null && item.blockName!.isNotEmpty) {
        uniqueBlocks.add(item.blockName!);
      }
    }

    List<Datas5> blockItems = uniqueBlocks.map((block) =>
      Datas5(id: 0, empName: widget.employeeName, block: block, status: "Active")
    ).toList();

    setState(() {
      blocksList = blockItems;
      selectedBlock = null;
    });
  }

  // ========== EVENT HANDLERS ==========

  void _onStateChanged(String? newState) {
    if (newState == null) return;

    setState(() {
      selectedState = newState;
      selectedDistrict = null;
      selectedBlock = null;
      districtsList = [];
      blocksList = [];
    });

    // Filter districts based on selected state
    _filterDistricts(newState);
    _notifyParent();
  }

  void _onDistrictChanged(String? newDistrict) {
    if (newDistrict == null) return;

    setState(() {
      selectedDistrict = newDistrict;
      selectedBlock = null;
      blocksList = [];
    });

    // Filter blocks based on selected district
    _filterBlocks(newDistrict);
    _notifyParent();
  }

  void _onBlockChanged(String? newBlock) {
    setState(() {
      selectedBlock = newBlock;
    });

    _notifyParent();
  }

  void _notifyParent() {
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(
        selectedState ?? '',
        selectedDistrict ?? '',
        selectedBlock ?? '',
      );
    }
  }

  void _retryLoading() {
    setState(() {
      errorMessage = '';
    });
    _loadLocationData();
  }

  // ========== UI COMPONENTS ==========

  Widget _buildErrorWidget() {
    if (errorMessage.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: GoogleFonts.poppins(
                color: Colors.red[700],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 8),
          TextButton(
            onPressed: _retryLoading,
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdown() {
    return _buildDropdown(
      title: "Select State",
      value: selectedState,
      items: statesList.map((state) => state.state ?? '').toList(),
      isLoading: isLoading,
      onChanged: _onStateChanged,
      icon: Icons.flag,
    );
  }

  Widget _buildDistrictDropdown() {
    return _buildDropdown(
      title: "Select District",
      value: selectedDistrict,
      items: districtsList.map((district) => district.district ?? '').toList(),
      isLoading: false, // Districts load quickly after state selection
      onChanged: _onDistrictChanged,
      icon: Icons.location_city,
      isEnabled: selectedState != null && districtsList.isNotEmpty,
    );
  }

  Widget _buildBlockDropdown() {
    return _buildDropdown(
      title: "Select Block",
      value: selectedBlock,
      items: blocksList.map((block) => block.block ?? '').toList(),
      isLoading: false, // Blocks load quickly after district selection
      onChanged: _onBlockChanged,
      icon: Icons.map,
      isEnabled: selectedDistrict != null && blocksList.isNotEmpty,
    );
  }

  Widget _buildDropdown({
    required String title,
    required String? value,
    required List<String> items,
    required bool isLoading,
    required Function(String?) onChanged,
    required IconData icon,
    bool isEnabled = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isEnabled ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    icon,
                    color: isEnabled ? Colors.green[700] : Colors.grey[400],
                    size: 20,
                  ),
                ),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: !isEnabled || isLoading,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        hint: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            isLoading ? 'Loading...' : title,
                            style: GoogleFonts.poppins(
                              color: isLoading ? Colors.green[700] : Colors.grey[500],
                            ),
                          ),
                        ),
                        items: items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: isEnabled ? onChanged : null,
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedLocationCard() {
    if (selectedState == null && selectedDistrict == null && selectedBlock == null) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Location:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.green[800],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          if (selectedState != null)
            Text('State: $selectedState', style: GoogleFonts.poppins()),
          if (selectedDistrict != null)
            Text('District: $selectedDistrict', style: GoogleFonts.poppins()),
          if (selectedBlock != null)
            Text('Block: $selectedBlock', style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "Location Selection",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 16),

          _buildErrorWidget(),
          _buildStateDropdown(),
          _buildDistrictDropdown(),
          _buildBlockDropdown(),
          _buildSelectedLocationCard(),
        ],
      ),
    );
  }
}*/
