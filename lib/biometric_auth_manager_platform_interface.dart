import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

enum BiometricType {
  fingerprint,
  faceID,
  passkey,
  none,
}

abstract class BiometricAuthManagerPlatform extends PlatformInterface {
  BiometricAuthManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BiometricAuthManagerPlatform _instance =
      MethodChannelBiometricAuthManager();

  static BiometricAuthManagerPlatform get instance => _instance;

  static set instance(BiometricAuthManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isBiometricAvailable() {
    throw UnimplementedError(
        'isBiometricAvailable() has not been implemented.');
  }

  Future<BiometricType> getAvailableBiometricType() {
    throw UnimplementedError(
        'getAvailableBiometricType() has not been implemented.');
  }

  Future<bool> authenticate({
    required String reason,
    String? title,
    String? cancelTitle,
  }) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  Future<Map<String, dynamic>?> registerPasskey({
    required Map<String, dynamic> options,
  }) {
    throw UnimplementedError('registerPasskey() has not been implemented.');
  }

  Future<Map<String, dynamic>?> authenticatePasskey({
    required Map<String, dynamic> options,
  }) {
    throw UnimplementedError('authenticatePasskey() has not been implemented.');
  }
}

class MethodChannelBiometricAuthManager extends BiometricAuthManagerPlatform {
  final MethodChannel _channel = const MethodChannel('biometric_auth_manager');

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final bool? available =
          await _channel.invokeMethod<bool>('isBiometricAvailable');
      return available ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<BiometricType> getAvailableBiometricType() async {
    try {
      final String? typeStr =
          await _channel.invokeMethod<String>('getAvailableBiometricType');
      switch (typeStr) {
        case 'fingerprint':
          return BiometricType.fingerprint;
        case 'faceID':
          return BiometricType.faceID;
        case 'passkey':
          return BiometricType.passkey;
        case 'none':
        default:
          return BiometricType.none;
      }
    } on PlatformException {
      return BiometricType.none;
    }
  }

  @override
  Future<bool> authenticate({
    required String reason,
    String? title,
    String? cancelTitle,
  }) async {
    try {
      final bool? success = await _channel.invokeMethod<bool>('authenticate', {
        'reason': reason,
        'title': title,
        'cancelTitle': cancelTitle,
      });
      return success ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> registerPasskey({
    required Map<String, dynamic> options,
  }) async {
    throw UnsupportedError(
        'Passkeys are only supported on Web in this version.');
  }

  @override
  Future<Map<String, dynamic>?> authenticatePasskey({
    required Map<String, dynamic> options,
  }) async {
    throw UnsupportedError(
        'Passkeys are only supported on Web in this version.');
  }
}
