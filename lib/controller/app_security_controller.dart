import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/app_security_service.dart';

class AppSecurityController extends GetxController {
  final RxBool isFingerprintEnabled = false.obs;
  final RxString fingerprintEnabledDate = ''.obs;

  final RxBool isAppPasswordEnabled = false.obs;
  final RxString appPasswordEnabledDate = ''.obs;

  final RxBool isBiometricSupported = true.obs;
  final RxBool isBiometricEnrolled = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSecuritySettings();
  }

  /// Load security preferences and hardware capabilities
  Future<void> loadSecuritySettings() async {
    isLoading.value = true;
    try {
      isBiometricSupported.value = await AppSecurityService.isBiometricSupported();
      isBiometricEnrolled.value = await AppSecurityService.isBiometricEnrolled();

      isFingerprintEnabled.value = await AppSecurityService.isFingerprintEnabled();
      final fpDate = await AppSecurityService.getFingerprintEnabledDate();
      fingerprintEnabledDate.value = AppSecurityService.formatEnabledDate(fpDate);

      isAppPasswordEnabled.value = await AppSecurityService.isAppPasswordEnabled();
      final pwdDate = await AppSecurityService.getAppPasswordEnabledDate();
      appPasswordEnabledDate.value = AppSecurityService.formatEnabledDate(pwdDate);
    } catch (e) {
      debugPrint('Error loading security settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle Fingerprint Login with biometric challenge verification
  Future<bool> toggleFingerprint(bool enable, {required BuildContext context}) async {
    if (!enable) {
      await AppSecurityService.setFingerprintEnabled(false);
      isFingerprintEnabled.value = false;
      fingerprintEnabledDate.value = '';
      return true;
    }

    // Checking hardware availability
    final supported = await AppSecurityService.isBiometricSupported();
    if (!supported) {
      isBiometricSupported.value = false;
      _showSnackBar(
        context,
        message:
            'Fingerprint authentication is not available on this device. You can use App Password instead.',
        isError: true,
      );
      return false;
    }

    final enrolled = await AppSecurityService.isBiometricEnrolled();
    if (!enrolled) {
      isBiometricEnrolled.value = false;
      _showSnackBar(
        context,
        message:
            'No fingerprint is configured on this device. Please set up fingerprint in device settings or use App Password.',
        isError: true,
      );
      return false;
    }

    // Challenge user with native fingerprint verification prompt
    final result = await AppSecurityService.authenticateWithBiometrics(
      localizedReason: 'Scan fingerprint to enable biometric app unlock',
    );

    if (result.isSuccess) {
      await AppSecurityService.setFingerprintEnabled(true);
      isFingerprintEnabled.value = true;
      final fpDate = await AppSecurityService.getFingerprintEnabledDate();
      fingerprintEnabledDate.value = AppSecurityService.formatEnabledDate(fpDate);

      if (context.mounted) {
        _showSnackBar(
          context,
          message: 'Fingerprint enabled successfully',
          isError: false,
        );
      }
      return true;
    } else {
      isFingerprintEnabled.value = false;
      if (context.mounted) {
        _showSnackBar(
          context,
          message: result.message,
          isError: true,
        );
      }
      return false;
    }
  }

  /// Toggle App Password option (Testing Mode: 1234)
  Future<bool> toggleAppPassword(bool enable, {required BuildContext context}) async {
    if (!enable) {
      await AppSecurityService.setAppPasswordEnabled(false);
      isAppPasswordEnabled.value = false;
      appPasswordEnabledDate.value = '';
      return true;
    }

    await AppSecurityService.setAppPasswordEnabled(true);
    isAppPasswordEnabled.value = true;
    final pwdDate = await AppSecurityService.getAppPasswordEnabledDate();
    appPasswordEnabledDate.value = AppSecurityService.formatEnabledDate(pwdDate);

    if (context.mounted) {
      _showSnackBar(
        context,
        message: 'App Password enabled (Test password: ${AppSecurityService.testAppPassword})',
        isError: false,
      );
    }
    return true;
  }

  void _showSnackBar(BuildContext context, {required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF0D4B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
