import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';

import 'model/TodoModel.dart';
import 'model/TodoModel1.dart';
import 'service/api_serviceProfile.dart';
import 'viewHome/widgets/MrprofileEdit.dart';

class HomeProfilePage extends StatefulWidget {
  final TodoModel userData;

  const HomeProfilePage({super.key, required this.userData});

  @override
  State<HomeProfilePage> createState() => _HomeProfilePageState();
}

class _HomeProfilePageState extends State<HomeProfilePage> {
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
      setState(() {
        _errorMessage = 'Mobile number not available';
      });
      return;
    }

    final mobile = widget.userData.mobile!;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileData = await ApiService.fetchProfile(mobile);
      setState(() {
        _profileData = profileData;
      });
    } on TimeoutException catch (e) {
      setState(() {
        _errorMessage =
        'Request timeout. Please check your internet connection and try again.';
      });
    } on SocketException catch (e) {
      setState(() {
        _errorMessage =
        'Network error. Please check your internet connection and try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Failed to load profile')
            ? e.toString()
            : 'Failed to load profile. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          if (widget.userData.mobile != null) {
            ApiService.clearProfileCache(widget.userData.mobile);
          }
          _fetchProfileData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstEmp = _profileData?.firstEmployee;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Employee Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (firstEmp != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => _openEditProfileModal(firstEmp),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _errorMessage != null
          ? _buildErrorDisplay()
          : _buildProfileContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Loading profile...",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            "Fetching employee details",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Please check your connection and try again",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text("Retry", style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null ||
        _profileData!.data1 == null ||
        _profileData!.data1!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchProfileData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: Text("Retry", style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );
    }

    final employeeData = _profileData!.data1!.first;
    final isCached = ApiService.isProfileCached(widget.userData.mobile!);
    DateTime? lastUpdated;
    if (isCached) {
      lastUpdated = ApiService.getCacheTimestamp(widget.userData.mobile!);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with basic info
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),
                Text(
                  employeeData.name ?? 'No Name',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employeeData.employeeType ?? 'Employee',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employeeData.empId ?? 'No ID',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Cache info
          if (isCached && lastUpdated != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Data loaded from cache. Last updated: ${_formatDateTime(lastUpdated)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.deepPurple[700],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: Colors.deepPurple,
                    ),
                    onPressed: _fetchProfileData,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Profile details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                _buildSectionHeader("Personal Information"),
                _buildProfileItem("ID", employeeData.id?.toString()),
                _buildProfileItem("Name", employeeData.name),
                _buildProfileItem("Father Name", employeeData.fatherName),
                _buildProfileItem("Gender", employeeData.gender),
                _buildProfileItem("Join Date", employeeData.joinDate),

                // Contact Information Section
                _buildSectionHeader("Contact Information"),
                _buildProfileItem("Mobile", employeeData.mobile),
                _buildProfileItem("Alternate Mobile", employeeData.mobileAlt),
                _buildProfileItem("Email", employeeData.email),
                _buildProfileItem("Address", employeeData.address),
                _buildProfileItem("Post Office", employeeData.postOffice),
                _buildProfileItem("Block", employeeData.block),
                _buildProfileItem("District", employeeData.district),
                _buildProfileItem("State", employeeData.state),
                _buildProfileItem("Country", employeeData.country),

                // Employment Information Section
                _buildSectionHeader("Employment Information"),
                _buildProfileItem("Employee ID", employeeData.employeeId),
                _buildProfileItem("Employee Code", employeeData.employeeCode),
                _buildProfileItem("Emp ID", employeeData.empId),
                _buildProfileItem("Employee Type", employeeData.employeeType),
                _buildProfileItem("Status", employeeData.status),
                _buildProfileItem("User ID", employeeData.userId),

                // System Information Section
                _buildSectionHeader("System Information"),
                _buildProfileItem("Created At", employeeData.createdAt),
                _buildProfileItem("Updated At", employeeData.updatedAt),

                const SizedBox(height: 24),

                // Edit Profile Button
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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

  // Enhanced profile item with better styling
  Widget _buildProfileItem(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not available',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
