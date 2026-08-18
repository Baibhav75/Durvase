import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSecurityService manages biometric (fingerprint) checks and
/// App Password authentication for local app lock security.
class AppSecurityService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // ---------------------------------------------------------------------------
  // Preference Storage Keys
  // ---------------------------------------------------------------------------
  static const String _fingerprintEnabledKey = 'fingerprint_enabled';
  static const String _fingerprintEnabledDateKey = 'fingerprint_enabled_date';

  static const String _appPasswordEnabledKey = 'app_password_enabled';
  static const String _appPasswordEnabledDateKey = 'app_password_enabled_date';

  // ---------------------------------------------------------------------------
  // TESTING / DEBUG ONLY PASSWORD
  // ---------------------------------------------------------------------------
  /// Default temporary testing password.
  /// WARNING: Do not use this hardcoded password as a production security solution.
  /// Replace with user-created secure password storage in production.
  static const String testAppPassword = '1234';

  // ---------------------------------------------------------------------------
  // Biometric Capabilities & Authentication
  // ---------------------------------------------------------------------------

  /// Check whether the device hardware supports biometrics
  static Future<bool> isBiometricSupported() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric support: $e');
      return false;
    }
  }

  /// Check whether at least one biometric (e.g. fingerprint) is enrolled
  static Future<bool> isBiometricEnrolled() async {
    try {
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking available biometrics: $e');
      return false;
    }
  }

  /// Trigger native biometric authentication prompt
  static Future<BiometricAuthResult> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to unlock Durvasa Ayurved',
  }) async {
    try {
      final bool isSupported = await isBiometricSupported();
      if (!isSupported) {
        return BiometricAuthResult(
          status: BiometricStatus.notSupported,
          message: 'Fingerprint authentication is not available on this device.',
        );
      }

      final bool isEnrolled = await isBiometricEnrolled();
      if (!isEnrolled) {
        return BiometricAuthResult(
          status: BiometricStatus.notEnrolled,
          message:
              'No fingerprint is configured on this device. Please set up fingerprint in device settings or use App Password.',
        );
      }

      final bool authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );

      if (authenticated) {
        return BiometricAuthResult(
          status: BiometricStatus.success,
          message: 'Fingerprint verified successfully.',
        );
      } else {
        return BiometricAuthResult(
          status: BiometricStatus.failed,
          message: 'Fingerprint authentication failed.',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric PlatformException: code=${e.code}, msg=${e.message}');
      if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet') {
        return BiometricAuthResult(
          status: BiometricStatus.notEnrolled,
          message:
              'No fingerprint is configured on this device. Please set up fingerprint in device settings or use App Password.',
        );
      }
      return BiometricAuthResult(
        status: BiometricStatus.cancelled,
        message: 'Fingerprint authentication cancelled.',
      );
    } catch (e) {
      debugPrint('Biometric Error: $e');
      return BiometricAuthResult(
        status: BiometricStatus.error,
        message: 'Authentication error occurred.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Preference Getters & Setters
  // ---------------------------------------------------------------------------

  /// Check if overall app-unlock security (fingerprint or app password) is enabled
  static Future<bool> isSecurityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final bool fingerprint = prefs.getBool(_fingerprintEnabledKey) ?? false;
    final bool password = prefs.getBool(_appPasswordEnabledKey) ?? false;
    return fingerprint || password;
  }

  /// Fingerprint Enabled state
  static Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fingerprintEnabledKey) ?? false;
  }

  /// Fingerprint Enabled Date in ISO format
  static Future<String?> getFingerprintEnabledDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fingerprintEnabledDateKey);
  }

  /// Enable or disable Fingerprint unlock
  static Future<void> setFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintEnabledKey, enabled);
    if (enabled) {
      final isoNow = DateTime.now().toIso8601String();
      await prefs.setString(_fingerprintEnabledDateKey, isoNow);
    } else {
      await prefs.remove(_fingerprintEnabledDateKey);
    }
  }

  /// App Password Enabled state
  static Future<bool> isAppPasswordEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appPasswordEnabledKey) ?? false;
  }

  /// App Password Enabled Date in ISO format
  static Future<String?> getAppPasswordEnabledDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appPasswordEnabledDateKey);
  }

  /// Enable or disable App Password unlock
  static Future<void> setAppPasswordEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appPasswordEnabledKey, enabled);
    if (enabled) {
      final isoNow = DateTime.now().toIso8601String();
      await prefs.setString(_appPasswordEnabledDateKey, isoNow);
    } else {
      await prefs.remove(_appPasswordEnabledDateKey);
    }
  }

  // ---------------------------------------------------------------------------
  // Password Verification (Testing Mode)
  // ---------------------------------------------------------------------------

  /// Verify entered password against test password
  static bool verifyPassword(String enteredPassword) {
    return enteredPassword.trim() == testAppPassword;
  }

  // ---------------------------------------------------------------------------
  // Date Formatting Helper
  // ---------------------------------------------------------------------------

  /// Format an ISO date string into a user-friendly format (e.g., "18 Aug 2026, 04:50 PM")
  static String formatEnabledDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (_) {
      return '';
    }
  }
}

/// Status enum for biometric authentication result
enum BiometricStatus {
  success,
  failed,
  cancelled,
  notSupported,
  notEnrolled,
  error,
}

/// Encapsulated result for biometric authentication
class BiometricAuthResult {
  final BiometricStatus status;
  final String message;

  BiometricAuthResult({
    required this.status,
    required this.message,
  });

  bool get isSuccess => status == BiometricStatus.success;
}
