import 'biometric_auth_manager_platform_interface.dart';

export 'biometric_auth_manager_platform_interface.dart' show BiometricType;

class BiometricAuthManager {
  Future<bool> isBiometricAvailable() {
    return BiometricAuthManagerPlatform.instance.isBiometricAvailable();
  }

  Future<BiometricType> getAvailableBiometricType() {
    return BiometricAuthManagerPlatform.instance.getAvailableBiometricType();
  }

  Future<bool> authenticate({
    required String reason,
    String? title,
    String? cancelTitle,
  }) {
    return BiometricAuthManagerPlatform.instance.authenticate(
      reason: reason,
      title: title,
      cancelTitle: cancelTitle,
    );
  }

  Future<Map<String, dynamic>?> registerPasskey({
    required Map<String, dynamic> options,
  }) {
    return BiometricAuthManagerPlatform.instance
        .registerPasskey(options: options);
  }

  Future<Map<String, dynamic>?> authenticatePasskey({
    required Map<String, dynamic> options,
  }) {
    return BiometricAuthManagerPlatform.instance
        .authenticatePasskey(options: options);
  }
}
