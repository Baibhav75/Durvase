import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../model/TodoModel.dart';
import '/controller/countryController.dart';
import '../model/country_model.dart';
import '/controller/state_controller.dart';
import '../model/state_model.dart';
import '../model/district_model.dart';
import '../model/block_model.dart';
import 'package:get/get.dart';

class YourTeamPage extends StatefulWidget {
  final TodoModel? userData;

  const YourTeamPage({
    super.key,
    this.userData,
  });

  @override
  State<YourTeamPage> createState() => _YourTeamPageState();
}

class _YourTeamPageState extends State<YourTeamPage> {
  late final CountryController countryController;
  late final StateController stateController;
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedBlock;

  int? _selectedCountryId;
  String? _selectedCountryName;

  String _selectedStatusFilter = 'ALL';

  bool _isLoading = false;
  List<TeamMember> _allTeamMembers = [];
  List<TeamMember> _filteredMembers = [];

  // Hierarchical State -> District -> Block data dictionary
  final Map<String, Map<String, List<String>>> _locationHierarchy = {
    'Uttar Pradesh': {
      'Gautam Buddha Nagar': ['Noida Sector 62', 'Noida Sector 15', 'Greater Noida', 'Dadri', 'Jewar'],
      'Ghaziabad': ['Indirapuram', 'Vaishali', 'Sahibabad', 'Muradnagar', 'Modinagar'],
      'Lucknow': ['Alambagh', 'Hazratganj', 'Gomti Nagar', 'Indira Nagar', 'Chinhat'],
      'Kanpur Nagar': ['Kalyanpur', 'Civil Lines', 'Govind Nagar', 'Kidwai Nagar', 'Bithoor'],
      'Varanasi': ['Cantt', 'Lanka', 'Sigra', 'Shivpur', 'Pindra'],
      'Agra': ['Tajganj', 'Sikandra', 'Fatehabad', 'Kheragarh', 'Etmadpur'],
      'Prayagraj': ['Civil Lines', 'Katra', 'Naini', 'Phulpur', 'Soraon'],
      'Amroha': ['Amroha', 'Dhanaura', 'Hasanpur', 'Gajraula', 'Joya'],
      'Basti': ['Basti Sadar', 'Harraiya', 'Rudhauli', 'Captainganj', 'Siswari'],
      'Meerut': ['Meerut Cantt', 'Sardhana', 'Mawana', 'Hastinapur', 'Daurala'],
      'Bareilly': ['Bareilly City', 'Aonla', 'Baheri', 'Faridpur', 'Nawabganj'],
    },
    'Bihar': {
      'Patna': ['Patna Sadar', 'Danapur', 'Phulwari Sharif', 'Barh', 'Mokama', 'Bakhtiyarpur'],
      'Muzaffarpur': ['Musahari', 'Kanti', 'Motipur', 'Sahebganj', 'Sakra', 'Minapur'],
      'Gaya': ['Gaya Town', 'Bodh Gaya', 'Sherghati', 'Tekari', 'Wazirganj'],
      'Bhagalpur': ['Jagdishpur', 'Nathnagar', 'Sultanganj', 'Kahalgaon', 'Pirpainti'],
      'Darbhanga': ['Darbhanga Sadar', 'Benipur', 'Baheri', 'Biraul', 'Hayaghat'],
    },
    'Delhi': {
      'Central Delhi': ['Connaught Place', 'Karol Bagh', 'Pahar Ganj', 'Daryaganj'],
      'South Delhi': ['Saket', 'Hauz Khas', 'Mehrauli', 'Greater Kailash'],
      'East Delhi': ['Preet Vihar', 'Mayur Vihar', 'Laxmi Nagar', 'Gandhi Nagar'],
      'North Delhi': ['Civil Lines', 'Model Town', 'Narela', 'Alipur'],
      'West Delhi': ['Rajouri Garden', 'Punjabi Bagh', 'Janakpuri', 'Tilak Nagar'],
    },
    'Maharashtra': {
      'Mumbai Suburban': ['Andheri', 'Bandra', 'Borivali', 'Kurla'],
      'Pune': ['Haveli', 'Kothrud', 'Pimpri', 'Chinchwad', 'Baramati'],
      'Nagpur': ['Nagpur Urban', 'Nagpur Rural', 'Kamptee', 'Hingna', 'Katol'],
      'Thane': ['Thane City', 'Kalyan', 'Dombivli', 'Ulhasnagar', 'Bhiwandi'],
    },
    'Madhya Pradesh': {
      'Bhopal': ['Huzur', 'Berasia', 'Govindpura', 'Kolar'],
      'Indore': ['Indore Urban', 'Mhow', 'Depalpur', 'Sanwer'],
      'Gwalior': ['Gwalior City', 'Dabra', 'Bhitarwar', 'Morar'],
      'Jabalpur': ['Jabalpur Urban', 'Patan', 'Sihora', 'Panagar'],
    },
    'Rajasthan': {
      'Jaipur': ['Jaipur City', 'Sanganer', 'Amer', 'Chaksu', 'Kotputli'],
      'Jodhpur': ['Jodhpur Urban', 'Luni', 'Bilara', 'Osian'],
      'Udaipur': ['Girwa', 'Badgaon', 'Mavli', 'Vallabhnagar'],
      'Kota': ['Kota City', 'Ladpura', 'Digod', 'Sangod'],
    },
    'Haryana': {
      'Gurugram': ['Gurugram Sadar', 'Badshahpur', 'Pataudi', 'Sohna', 'Manesar'],
      'Faridabad': ['Faridabad City', 'Ballabgarh', 'Badkhal', 'Mohna'],
      'Ambala': ['Ambala Cantt', 'Ambala City', 'Barara', 'Naraingarh'],
    },
    'Punjab': {
      'Ludhiana': ['Ludhiana East', 'Ludhiana West', 'Jagraon', 'Khanna'],
      'Amritsar': ['Amritsar-I', 'Amritsar-II', 'Ajnala', 'Baba Bakala'],
      'Jalandhar': ['Jalandhar-I', 'Jalandhar-II', 'Nakodar', 'Phillaur'],
    },
    'Telangana': {
      'Hyderabad': ['Amberpet', 'Khairatabad', 'Secunderabad', 'Charminar', 'Jubilee Hills'],
      'Rangareddy': ['Rajendranagar', 'Serilingampally', 'LB Nagar', 'Ibrahimpatnam'],
    },
  };

  @override
  void initState() {
    super.initState();

    countryController = Get.put(
      CountryController(),
    );

    stateController = Get.put(
      StateController(),
    );

    _searchController.addListener(
      _filterTeamMembers,
    );

    _loadInitialTeamData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialTeamData() {
    setState(() {
      _isLoading = true;
    });

    // Sample Team Members Data matching MR / Field structure
    _allTeamMembers = [
      TeamMember(
        id: 101,
        empId: 'EMP226505',
        name: 'Rahul Kumar',
        designation: 'Medical Representative (MR)',
        mobile: '9876543210',
        email: 'rahul.mr@gmail.com',
        state: 'Uttar Pradesh',
        district: 'Gautam Buddha Nagar',
        block: 'Noida Sector 62',
        status: 'Active',
        assignedDoctors: 28,
        todayVisits: 6,
        photoUrl: '',
      ),
      TeamMember(
        id: 102,
        empId: 'EMP241281',
        name: 'Ankur Kumar',
        designation: 'Medical Representative (MR)',
        mobile: '9140558753',
        email: 'ankur.mr@gmail.com',
        state: 'Uttar Pradesh',
        district: 'Gautam Buddha Nagar',
        block: 'Dadri',
        status: 'Active',
        assignedDoctors: 34,
        todayVisits: 8,
        photoUrl: '',
      ),
      TeamMember(
        id: 103,
        empId: 'EMP348109',
        name: 'Mohd Affan',
        designation: 'Senior MR',
        mobile: '08384842010',
        email: 'affan.mr@gmail.com',
        state: 'Uttar Pradesh',
        district: 'Amroha',
        block: 'Amroha',
        status: 'Active',
        assignedDoctors: 42,
        todayVisits: 10,
        photoUrl: '',
      ),
      TeamMember(
        id: 104,
        empId: 'EMP870398',
        name: 'Satyam Tiwari',
        designation: 'Medical Representative (MR)',
        mobile: '9140558753',
        email: 'satyam.mr@gmail.com',
        state: 'Uttar Pradesh',
        district: 'Basti',
        block: 'Siswari',
        status: 'Active',
        assignedDoctors: 22,
        todayVisits: 5,
        photoUrl: '',
      ),
      TeamMember(
        id: 105,
        empId: 'EMP363867',
        name: 'Balivada Anilkumar',
        designation: 'Area Executive (MR)',
        mobile: '8686002484',
        email: 'anil.lucky99@gmail.com',
        state: 'Telangana',
        district: 'Hyderabad',
        block: 'Amberpet',
        status: 'Active',
        assignedDoctors: 30,
        todayVisits: 7,
        photoUrl: '',
      ),
      TeamMember(
        id: 106,
        empId: 'EMP713500',
        name: 'Raj Kumar',
        designation: 'Medical Representative (MR)',
        mobile: '9113468999',
        email: 'raj.mr@gmail.com',
        state: 'Bihar',
        district: 'Muzaffarpur',
        block: 'Musahari',
        status: 'Inactive',
        assignedDoctors: 18,
        todayVisits: 0,
        photoUrl: '',
      ),
      TeamMember(
        id: 107,
        empId: 'EMP582103',
        name: 'Priya Sharma',
        designation: 'Medical Representative (MR)',
        mobile: '9811223344',
        email: 'priya.sharma@gmail.com',
        state: 'Delhi',
        district: 'Central Delhi',
        block: 'Connaught Place',
        status: 'Active',
        assignedDoctors: 36,
        todayVisits: 9,
        photoUrl: '',
      ),
      TeamMember(
        id: 108,
        empId: 'EMP619284',
        name: 'Vikas Singh',
        designation: 'Medical Representative (MR)',
        mobile: '9712345678',
        email: 'vikas.singh@gmail.com',
        state: 'Bihar',
        district: 'Patna',
        block: 'Danapur',
        status: 'Active',
        assignedDoctors: 25,
        todayVisits: 4,
        photoUrl: '',
      ),
    ];

    _filteredMembers = List.from(_allTeamMembers);
    _isLoading = false;
  }

  void _filterTeamMembers() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredMembers = _allTeamMembers.where((member) {
        // State Filter
        if (_selectedState != null && _selectedState!.isNotEmpty) {
          if (member.state.toLowerCase() != _selectedState!.toLowerCase()) {
            return false;
          }
        }

        // District Filter
        if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
          if (member.district.toLowerCase() != _selectedDistrict!.toLowerCase()) {
            return false;
          }
        }

        // Block Filter
        if (_selectedBlock != null && _selectedBlock!.isNotEmpty) {
          if (member.block.toLowerCase() != _selectedBlock!.toLowerCase()) {
            return false;
          }
        }

        // Status Filter
        if (_selectedStatusFilter == 'ACTIVE') {
          if (member.status.toUpperCase() != 'ACTIVE') return false;
        } else if (_selectedStatusFilter == 'INACTIVE') {
          if (member.status.toUpperCase() != 'INACTIVE') return false;
        }

        // Search Query (matches name, empId, mobile, block, district)
        if (query.isNotEmpty) {
          final matchesName = member.name.toLowerCase().contains(query);
          final matchesEmpId = member.empId.toLowerCase().contains(query);
          final matchesMobile = member.mobile.contains(query);
          final matchesDistrict = member.district.toLowerCase().contains(query);
          final matchesBlock = member.block.toLowerCase().contains(query);
          if (!matchesName && !matchesEmpId && !matchesMobile && !matchesDistrict && !matchesBlock) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onStateChanged(String? newState) {
    setState(() {
      _selectedState = newState;
      _selectedDistrict = null;
      _selectedBlock = null;
    });

    if (newState != null && stateController.states.isNotEmpty) {
      try {
        final matchedState = stateController.states.firstWhere(
          (s) => s.stateName.toLowerCase() == newState.toLowerCase(),
        );
        stateController.selectState(matchedState);
      } catch (_) {
        stateController.clearDistricts();
      }
    } else {
      stateController.clearDistricts();
    }

    _filterTeamMembers();
  }

  void _onDistrictChanged(String? newDistrict) {
    setState(() {
      _selectedDistrict = newDistrict;
      _selectedBlock = null;
    });

    if (newDistrict != null && stateController.districts.isNotEmpty) {
      try {
        final matchedDistrict = stateController.districts.firstWhere(
          (d) => d.districtName.toLowerCase() == newDistrict.toLowerCase(),
        );
        stateController.selectDistrict(matchedDistrict);
      } catch (_) {}
    }

    _filterTeamMembers();
  }

  void _onBlockChanged(String? newBlock) {
    setState(() {
      _selectedBlock = newBlock;
    });

    if (newBlock != null && stateController.blocks.isNotEmpty) {
      try {
        final matchedBlock = stateController.blocks.firstWhere(
          (b) => b.blockName.toLowerCase() == newBlock.toLowerCase(),
        );
        stateController.selectBlock(matchedBlock);
      } catch (_) {}
    }

    _filterTeamMembers();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCountryId = null;
      _selectedCountryName = null;
      _selectedState = null;
      _selectedDistrict = null;
      _selectedBlock = null;
      _searchController.clear();
      _selectedStatusFilter = 'ALL';
      _filteredMembers = List.from(_allTeamMembers);
    });
    countryController.clearSelection();
    stateController.clearStates();
  }

  List<String> get _currentDistricts {
    if (_selectedState == null || !_locationHierarchy.containsKey(_selectedState)) {
      return [];
    }
    return _locationHierarchy[_selectedState!]!.keys.toList();
  }

  List<String> get _currentBlocks {
    if (_selectedState == null || _selectedDistrict == null) {
      return [];
    }
    final districts = _locationHierarchy[_selectedState!];
    if (districts != null && districts.containsKey(_selectedDistrict)) {
      return districts[_selectedDistrict!]!;
    }
    return [];
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  // ============================================================
  // ALLOT / ASSIGN NEW WORK AREA MODAL
  // ============================================================
  void _openAssignAreaModal(TeamMember member) {
    String? modalState = member.state.isNotEmpty ? member.state : null;
    String? modalDistrict = member.district.isNotEmpty ? member.district : null;
    String? modalBlock = member.block.isNotEmpty ? member.block : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final districts = (modalState != null && _locationHierarchy.containsKey(modalState))
              ? _locationHierarchy[modalState!]!.keys.toList()
              : <String>[];

          final blocks = (modalState != null && modalDistrict != null && _locationHierarchy[modalState!]!.containsKey(modalDistrict))
              ? _locationHierarchy[modalState!]![modalDistrict!]!
              : <String>[];

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allot Work Area',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          '${member.name} (${member.empId})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // State Dropdown
                _buildDropdownField(
                  label: 'Select State *',
                  icon: Icons.public_outlined,
                  value: modalState,
                  items: _locationHierarchy.keys.toList(),
                  onChanged: (val) {
                    setModalState(() {
                      modalState = val;
                      modalDistrict = null;
                      modalBlock = null;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // District Dropdown
                _buildDropdownField(
                  label: 'Select District *',
                  icon: Icons.location_city_outlined,
                  value: modalDistrict,
                  items: districts,
                  hint: modalState == null ? 'Select State First' : 'Choose District',
                  onChanged: modalState == null
                      ? null
                      : (val) {
                          setModalState(() {
                            modalDistrict = val;
                            modalBlock = null;
                          });
                        },
                ),
                const SizedBox(height: 12),

                // Block Dropdown
                _buildDropdownField(
                  label: 'Select Block / Area *',
                  icon: Icons.domain_outlined,
                  value: modalBlock,
                  items: blocks,
                  hint: modalDistrict == null ? 'Select District First' : 'Choose Block',
                  onChanged: modalDistrict == null
                      ? null
                      : (val) {
                          setModalState(() {
                            modalBlock = val;
                          });
                        },
                ),
                const SizedBox(height: 20),

                // Save Allotment Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (modalState != null && modalDistrict != null && modalBlock != null)
                        ? () {
                            setState(() {
                              member.state = modalState!;
                              member.district = modalDistrict!;
                              member.block = modalBlock!;
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Work Area Allotted: $modalBlock, $modalDistrict',
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.primaryGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Confirm Area Allotment',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
          'Your Team (MR List)',
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
            onPressed: _loadInitialTeamData,
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          // 1. Top KPI Summary Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _buildTeamHeaderSummary(),
            ),
          ),

          // 2. State, District & Block Filter Form Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildFilterFormCard(),
            ),
          ),

          // 3. Search Bar & Status Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildSearchAndPills(),
            ),
          ),

          // 4. Team Members List or Empty View
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ),
            )
          else if (_filteredMembers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final member = _filteredMembers[index];
                    return _buildTeamMemberCard(member);
                  },
                  childCount: _filteredMembers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP SUMMARY BANNER
  // ============================================================
  Widget _buildTeamHeaderSummary() {
    final totalCount = _allTeamMembers.length;
    final activeCount = _allTeamMembers.where((m) => m.status.toUpperCase() == 'ACTIVE').length;
    final statesCovered = _allTeamMembers.map((m) => m.state).toSet().length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'ASM Territory & Field Staff',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.groups_rounded, size: 15, color: AppColors.primaryGold),
                    const SizedBox(width: 5),
                    Text(
                      '$totalCount Members',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),

          // 3 Metric Items
          Row(
            children: [
              _buildMetricItem('Total MRs', '$totalCount', Icons.badge_outlined),
              _buildDivider(),
              _buildMetricItem('Active on Field', '$activeCount', Icons.verified_user_outlined, color: AppColors.leafGreen),
              _buildDivider(),
              _buildMetricItem('States Covered', '$statesCovered', Icons.map_outlined, color: AppColors.primaryGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, {Color color = AppColors.white}) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATE, DISTRICT & BLOCK OPTION FORM CARD
  // ============================================================
  Widget _buildFilterFormCard() {
    final bool hasFilterActive = _selectedState != null || _selectedDistrict != null || _selectedBlock != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Territory & Area Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (hasFilterActive)
                InkWell(
                  onTap: _clearAllFilters,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      'Reset Options',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCountryDropdown(),
          const SizedBox(height: 10),

          // 1. State Option Dropdown (Dynamic from State API)
          _buildStateDropdown(),
          const SizedBox(height: 10),

          // 2. District & 3. Block Row
          Row(
            children: [
              // District Option Dropdown (Dynamic from District API)
              Expanded(
                child: _buildDistrictDropdown(),
              ),
              const SizedBox(width: 10),

              // Block Option Dropdown (Dynamic from Block API)
              Expanded(
                child: _buildBlockDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    String hint = 'Choose Option',
    required ValueChanged<String?>? onChanged,
  }) {
    final bool isEnabled = onChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isEnabled ? AppColors.creamBackground : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled ? AppColors.primaryGold.withValues(alpha: 0.4) : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value != null && items.contains(value)) ? value : null,
              isExpanded: true,
              hint: Row(
                children: [
                  Icon(icon, size: 16, color: isEnabled ? AppColors.primaryGreen : Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hint,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isEnabled ? AppColors.primaryGreen : Colors.grey,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, size: 15, color: AppColors.primaryGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR & STATUS PILLS
  // ============================================================
  Widget _buildSearchAndPills() {
    return Column(
      children: [
        // Search TextField
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Search by MR Name, Emp ID, Mobile, Block...',
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Status Filter Chips
        Row(
          children: [
            _buildStatusChip('ALL', 'All Team (${_allTeamMembers.length})'),
            const SizedBox(width: 8),
            _buildStatusChip('ACTIVE', 'Active MRs'),
            const SizedBox(width: 8),
            _buildStatusChip('INACTIVE', 'Inactive'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatusFilter = key;
          });
          _filterTeamMembers();
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.primaryGold.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEAM MEMBER CARD
  // ============================================================
  Widget _buildTeamMemberCard(TeamMember member) {
    final bool isActive = member.status.toUpperCase() == 'ACTIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Avatar, Name, Designation & Status Badge
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${member.empId} • ${member.designation}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.leafGreen.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.leafGreen.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    member.status,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.secondaryGreen : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Row 2: Territory Chips (State, District, Block)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildInfoChip(Icons.public, member.state),
                _buildInfoChip(Icons.location_city, member.district),
                _buildInfoChip(Icons.domain, member.block, isPrimary: true),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: KPI Metrics & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildKpiMiniItem('Doctors', '${member.assignedDoctors}'),
                    const SizedBox(width: 14),
                    _buildKpiMiniItem('Visits', '${member.todayVisits}'),
                  ],
                ),
                Row(
                  children: [
                    // Allot Area Button
                    OutlinedButton.icon(
                      onPressed: () => _openAssignAreaModal(member),
                      icon: const Icon(Icons.add_location_alt_outlined, size: 14, color: AppColors.primaryGreen),
                      label: Text(
                        'Allot Area',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Call Button
                    IconButton(
                      icon: const Icon(Icons.phone_rounded, color: AppColors.primaryGreen, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _makePhoneCall(member.mobile),
                    ),
                    const SizedBox(width: 8),

                    // Email Button
                    IconButton(
                      icon: const Icon(Icons.email_outlined, color: AppColors.primaryGreen, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _sendEmail(member.email),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryGreen.withValues(alpha: 0.08) : AppColors.creamBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? AppColors.primaryGreen.withValues(alpha: 0.3) : AppColors.primaryGold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: isPrimary ? AppColors.primaryGreen : AppColors.deepGold),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.primaryGreen : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMiniItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryGreen,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 55,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Team Members Found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No MRs found for the selected State, District, or Block criteria.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all_rounded, size: 18),
              label: const Text('Reset All Options'),
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

  Widget _buildCountryDropdown() {
    return Obx(() {
      if (countryController.isLoading.value) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.public_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Loading Countries...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      if (countryController.errorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  countryController.errorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
              ),
              IconButton(
                onPressed: countryController.refreshCountries,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.4),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,

            value: _selectedCountryId,

            hint: Row(
              children: [
                const Icon(
                  Icons.public_outlined,
                  size: 17,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 7),
                Text(
                  'Select Country',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryGreen,
            ),

            items: countryController.countries.map(
                  (CountryModel country) {
                return DropdownMenuItem<int>(
                  value: country.countryId,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 15,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          country.countryName,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),

            onChanged: (int? countryId) {
              if (countryId == null) return;

              final selectedCountry =
              countryController.countries.firstWhere(
                    (country) => country.countryId == countryId,
              );

              setState(() {
                _selectedCountryId =
                    selectedCountry.countryId;

                _selectedCountryName =
                    selectedCountry.countryName;

                // Country change ke baad territory filters reset
                _selectedState = null;
                _selectedDistrict = null;
                _selectedBlock = null;
              });

              countryController.selectCountry(
                selectedCountry,
              );

              // Fetch states for the selected Country
              stateController.fetchStates(
                selectedCountry.countryId,
              );

              _filterTeamMembers();

              print(
                '🌍 Selected Country ID: '
                    '${selectedCountry.countryId}',
              );

              print(
                '🌍 Selected Country Name: '
                    '${selectedCountry.countryName}',
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildStateDropdown() {
    return Obx(() {
      if (stateController.isLoading.value) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.public_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Loading States...',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      if (stateController.errorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stateController.errorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.error,
                  ),
                ),
              ),
              IconButton(
                onPressed: stateController.refreshStates,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      // If country is selected and states exist, use dynamic states; otherwise fallback to local hierarchy
      final List<String> availableStates = stateController.states.isNotEmpty
          ? stateController.states.map((s) => s.stateName).toSet().toList()
          : _locationHierarchy.keys.toList();

      return _buildDropdownField(
        label: '1. State Option',
        icon: Icons.public_outlined,
        value: _selectedState,
        items: availableStates,
        hint: _selectedCountryName != null
            ? 'All States (${_selectedCountryName})'
            : 'All States',
        onChanged: _onStateChanged,
      );
    });
  }

  Widget _buildDistrictDropdown() {
    return Obx(() {
      if (stateController.isDistrictsLoading.value) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_city_outlined,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      if (stateController.districtErrorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stateController.districtErrorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: stateController.refreshDistricts,
                child: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      final List<String> availableDistricts = stateController.districts.isNotEmpty
          ? stateController.districts.map((d) => d.districtName).toSet().toList()
          : _currentDistricts;

      return _buildDropdownField(
        label: '2. District Option',
        icon: Icons.location_city_outlined,
        value: _selectedDistrict,
        items: availableDistricts,
        hint: _selectedState == null ? 'Select State' : 'All Districts',
        onChanged: _selectedState == null ? null : _onDistrictChanged,
      );
    });
  }

  Widget _buildBlockDropdown() {
    return Obx(() {
      if (stateController.isBlocksLoading.value) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.creamBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.domain_outlined,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      if (stateController.blockErrorMessage.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stateController.blockErrorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.error,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: stateController.refreshBlocks,
                child: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        );
      }

      final List<String> availableBlocks = stateController.blocks.isNotEmpty
          ? stateController.blocks.map((b) => b.blockName).toSet().toList()
          : _currentBlocks;

      return _buildDropdownField(
        label: '3. Block Option',
        icon: Icons.domain_outlined,
        value: _selectedBlock,
        items: availableBlocks,
        hint: _selectedDistrict == null ? 'Select District' : 'All Blocks',
        onChanged: _selectedDistrict == null ? null : _onBlockChanged,
      );
    });
  }
}

// ============================================================
// DATA MODEL FOR TEAM MEMBERS
// ============================================================
class TeamMember {
  final int id;
  final String empId;
  final String name;
  final String designation;
  final String mobile;
  final String email;
  String state;
  String district;
  String block;
  final String status;
  final int assignedDoctors;
  final int todayVisits;
  final String photoUrl;

  TeamMember({
    required this.id,
    required this.empId,
    required this.name,
    required this.designation,
    required this.mobile,
    required this.email,
    required this.state,
    required this.district,
    required this.block,
    required this.status,
    required this.assignedDoctors,
    required this.todayVisits,
    required this.photoUrl,
  });
}
