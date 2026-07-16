import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_auth_manager/biometric_auth_manager.dart';
import 'package:biometric_auth_manager/biometric_auth_manager_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBiometricAuthManagerPlatform
    with MockPlatformInterfaceMixin
    implements BiometricAuthManagerPlatform {
  bool isAvailableMock = true;
  BiometricType biometricTypeMock = BiometricType.fingerprint;
  bool authenticateResult = true;
  Map<String, dynamic>? registerResult;
  Map<String, dynamic>? authenticatePasskeyResult;

  @override
  Future<bool> isBiometricAvailable() async => isAvailableMock;

  @override
  Future<BiometricType> getAvailableBiometricType() async => biometricTypeMock;

  @override
  Future<bool> authenticate({
    required String reason,
    String? title,
    String? cancelTitle,
  }) async =>
      authenticateResult;

  @override
  Future<Map<String, dynamic>?> registerPasskey({
    required Map<String, dynamic> options,
  }) async =>
      registerResult;

  @override
  Future<Map<String, dynamic>?> authenticatePasskey({
    required Map<String, dynamic> options,
  }) async =>
      authenticatePasskeyResult;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BiometricAuthManager authManager;
  late MockBiometricAuthManagerPlatform mockPlatform;

  setUp(() {
    authManager = BiometricAuthManager();
    mockPlatform = MockBiometricAuthManagerPlatform();
    BiometricAuthManagerPlatform.instance = mockPlatform;
  });

  test('isBiometricAvailable returns correct status', () async {
    mockPlatform.isAvailableMock = true;
    expect(await authManager.isBiometricAvailable(), true);

    mockPlatform.isAvailableMock = false;
    expect(await authManager.isBiometricAvailable(), false);
  });

  test('getAvailableBiometricType returns correct type', () async {
    mockPlatform.biometricTypeMock = BiometricType.faceID;
    expect(await authManager.getAvailableBiometricType(), BiometricType.faceID);

    mockPlatform.biometricTypeMock = BiometricType.none;
    expect(await authManager.getAvailableBiometricType(), BiometricType.none);
  });

  test('authenticate handles success and parameters correctly', () async {
    mockPlatform.authenticateResult = true;
    final result = await authManager.authenticate(
      reason: 'test reason',
      title: 'test title',
      cancelTitle: 'cancel',
    );
    expect(result, true);
  });

  test('registerPasskey forwards correct values', () async {
    final mockRes = {'id': 'cred_123'};
    mockPlatform.registerResult = mockRes;

    final result =
        await authManager.registerPasskey(options: {'challenge': '123'});
    expect(result, mockRes);
  });

  test('authenticatePasskey forwards correct values', () async {
    final mockRes = {'id': 'auth_123'};
    mockPlatform.authenticatePasskeyResult = mockRes;

    final result =
        await authManager.authenticatePasskey(options: {'challenge': '123'});
    expect(result, mockRes);
  });
}
