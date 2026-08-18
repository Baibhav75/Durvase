import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String? value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value != null && value.trim().isNotEmpty && value.trim().toLowerCase() != 'null'
                  ? value.trim()
                  : 'Not available',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null || _profileData!.data1 == null || _profileData!.data1!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No profile data available",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final employeeData = _profileData!.data1!.first;
    final imageUrl = employeeData.resolvedImageUrl;

    final isCached = ApiService.isProfileCached(widget.userData.mobile!);
    DateTime? lastUpdated;
    if (isCached) {
      lastUpdated = ApiService.getCacheTimestamp(widget.userData.mobile!);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cache indicator
            if (isCached && lastUpdated != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Data loaded from cache. Last updated: ${_formatDateTime(lastUpdated)}",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.deepPurple[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Color(0xFF512DA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.deepPurple,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.deepPurple,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _openEditProfileModal(employeeData),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.black87,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    employeeData.name ?? 'Employee',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    employeeData.employeeType ?? 'Medical Representative (MR)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Emp ID: ${employeeData.empId ?? "N/A"}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 1. Personal Information
            _buildSectionHeader("Personal Information"),
            _buildProfileItem("ID", employeeData.id?.toString()),
            _buildProfileItem("Full Name", employeeData.name),
            _buildProfileItem("Father Name", employeeData.fatherName),
            _buildProfileItem("Gender", employeeData.gender),
            _buildProfileItem("Blood Group", employeeData.billedGroup),
            _buildProfileItem("Join Date", employeeData.joinDate),

            // 2. Contact Information
            _buildSectionHeader("Contact Information"),
            _buildProfileItem("Primary Mobile", employeeData.mobile),
            _buildProfileItem("Alternate Mobile", employeeData.mobileAlt),
            _buildProfileItem("Emergency Contact", employeeData.emergenceNo, valueColor: Colors.red[700]),
            _buildProfileItem("Email", employeeData.email),
            _buildProfileItem("Address", employeeData.address),
            _buildProfileItem("Post Office", employeeData.postOffice),
            _buildProfileItem("Block", employeeData.block),
            _buildProfileItem("District", employeeData.district),
            _buildProfileItem("State", employeeData.state),
            _buildProfileItem("Country", employeeData.country),

            // 3. Employment Information
            _buildSectionHeader("Employment Information"),
            _buildProfileItem("Employee ID", employeeData.empId),
            _buildProfileItem("Employee Code", employeeData.employeeCode),
            _buildProfileItem("Employee Type", employeeData.employeeType),
            _buildProfileItem("Status", employeeData.status),
            _buildProfileItem("User ID", employeeData.userId),

            // 4. System Information
            _buildSectionHeader("System Information"),
            _buildProfileItem("Created At", employeeData.createdAt),
            _buildProfileItem("Updated At", employeeData.updatedAt),

            const SizedBox(height: 20),

            // Edit Profile Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openEditProfileModal(employeeData),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                label: Text(
                  'Edit Profile Details',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "Employee Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_profileData?.firstEmployee != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => _openEditProfileModal(_profileData!.firstEmployee!),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ApiService.clearProfileCache(widget.userData.mobile);
              _fetchProfileData();
            },
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text(
                    "Loading profile...",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fetching employee details",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please check your connection and try again",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchProfileData,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text("Retry", style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildProfileContent(),


    );
  }
}
