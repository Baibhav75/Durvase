import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DealerEditProfileService {
  static const String _baseUrl = 'https://durvasaayurved.online/api/editdealerprofile';

  /// Updates dealer profile. Pass [imageFile] only if user picked a new photo.
  /// [password] is optional — pass null/empty to keep it unchanged if backend supports that,
  /// otherwise pass the current password if backend requires it on every update.
  static Future<Map<String, dynamic>> updateProfile({
    required String dealerId,
    required String fullName,
    required String email,
    required String phone,
    String? password,
    required String gstNumber,
    required String businessAddress,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      request.fields['DealerID'] = dealerId;
      request.fields['FullName'] = fullName;
      request.fields['Email'] = email;
      request.fields['Phone'] = phone;
      if (password != null && password.trim().isNotEmpty) {
        request.fields['Password'] = password.trim();
      }
      request.fields['GSTNumber'] = gstNumber;
      request.fields['BusinessAddress'] = businessAddress;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Profile', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Update failed. Try again. (${response.statusCode})',
        };
      }

      final decoded = jsonDecode(response.body);
      final isSuccess = decoded['status']?.toString().toLowerCase() == 'success';

      return {
        'success': isSuccess,
        'message': decoded['message']?.toString() ?? (isSuccess ? 'Profile updated successfully!' : 'Update failed. Try again.'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Try again.',
      };
    }
  }
}