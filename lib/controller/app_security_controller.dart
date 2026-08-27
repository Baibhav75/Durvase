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
      if (context.mounted) {
        _showSnackBar(context, message: 'Fingerprint unlock disabled', isError: false);
      }
      return true;
    }

    // Challenge user with native biometric verification prompt
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
          message: 'Fingerprint unlock enabled successfully',
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
    try {
      if (!enable) {
        await AppSecurityService.setAppPasswordEnabled(false);
        isAppPasswordEnabled.value = false;
        appPasswordEnabledDate.value = '';
        if (context.mounted) {
          _showSnackBar(context, message: 'App Password unlock disabled', isError: false);
        }
        return true;
      }

      await AppSecurityService.setAppPasswordEnabled(true);
      isAppPasswordEnabled.value = true;
      final pwdDate = await AppSecurityService.getAppPasswordEnabledDate();
      appPasswordEnabledDate.value = AppSecurityService.formatEnabledDate(pwdDate);

      if (context.mounted) {
        _showSnackBar(
          context,
          message: 'App Password enabled successfully (Test password: ${AppSecurityService.testAppPassword})',
          isError: false,
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error toggling app password: $e');
      return false;
    }
  }

  void _showSnackBar(BuildContext context, {required String message, required bool isError}) {
    try {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF0D4B2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }
}
