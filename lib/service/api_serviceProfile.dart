
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/TodoModel1.dart';

class ApiService {
  static const String baseUrl = 'https://durvasaayurved.online/API/';
  static const int timeoutSeconds = 15; // Reduced timeout for better UX
  static const int cacheExpiryMinutes =
  2; // Reduced cache time for fresher data

  // Simple cache for profile data
  static Map<String, TodoModel1> _profileCache = {};
  static Map<String, DateTime> _cacheTimestamps = {};

  static Future<TodoModel1?> fetchProfile(String mobile) async {
    // Check if we have valid cached data
    if (_profileCache.containsKey(mobile)) {
      final cachedTime = _cacheTimestamps[mobile];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime).inMinutes <
              cacheExpiryMinutes) {
        print('🔍 Using cached profile data for mobile: $mobile');
        return _profileCache[mobile];
      }
    }

    try {
      print('📤 Fetching profile data for mobile: $mobile');
      final startTime = DateTime.now();

      final response = await http
          .get(
        Uri.parse('$baseUrl/Profile?mobile=$mobile'),
        headers: {'Content-Type': 'application/json'},
      )
          .timeout(const Duration(seconds: timeoutSeconds));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('⏱️ Profile API call took ${duration.inMilliseconds}ms');

      print('🔍 Profile API Response Status: ${response.statusCode}');
      // Only log first 500 characters of response body to avoid console spam
      print(
        '🔍 Profile API Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if API returned success
        if (data['message']?.toString().toLowerCase().contains('success') ==
            true) {
          final profileData = TodoModel1.fromJson(data);

          // Cache the data
          _profileCache[mobile] = profileData;
          _cacheTimestamps[mobile] = DateTime.now();

          return profileData;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception(
          'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('❌ Error in fetchProfile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  // Method to check if profile data is cached for a mobile number
  static bool isProfileCached(String mobile) {
    return _profileCache.containsKey(mobile) &&
        _cacheTimestamps.containsKey(mobile) &&
        DateTime.now().difference(_cacheTimestamps[mobile]!).inMinutes <
            cacheExpiryMinutes;
  }

  // Method to get cache timestamp for a mobile number
  static DateTime? getCacheTimestamp(String mobile) {
    return _cacheTimestamps[mobile];
  }

  // Method to clear cache for a specific mobile or all cache
  static void clearProfileCache([String? mobile]) {
    if (mobile != null) {
      _profileCache.remove(mobile);
      _cacheTimestamps.remove(mobile);
    } else {
      _profileCache.clear();
      _cacheTimestamps.clear();
    }
  }

  // Additional method to validate employee data
  static bool isValidEmployeeData(Data1? employeeData) {
    if (employeeData == null) return false;

    // Check if we have basic required fields and location data
    bool hasBasicInfo =
        employeeData.name != null &&
            employeeData.name!.isNotEmpty &&
            employeeData.mobile != null &&
            employeeData.mobile!.isNotEmpty;

    bool hasLocationData =
        (employeeData.country != null && employeeData.country!.isNotEmpty) ||
            (employeeData.state != null && employeeData.state!.isNotEmpty) ||
            (employeeData.district != null && employeeData.district!.isNotEmpty);

    return hasBasicInfo && hasLocationData;
  }

  // Helper method to get formatted location details
  static String getFormattedLocation(Data1? employeeData) {
    if (employeeData == null) return 'Location not available';

    List<String> locations = [];

    if (employeeData.state != null && employeeData.state!.isNotEmpty) {
      locations.add(employeeData.state!);
    }

    if (employeeData.district != null && employeeData.district!.isNotEmpty) {
      locations.add(employeeData.district!);
    }

    if (employeeData.block != null && employeeData.block!.isNotEmpty) {
      locations.add(employeeData.block!);
    }

    return locations.join(', ');
  }
}
