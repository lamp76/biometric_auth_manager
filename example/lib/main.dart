import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:biometric_auth_manager/biometric_auth_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Auth Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1), // Indigo
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        cardColor: const Color(0xFF1E293B), // Slate 800
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF3B82F6), // Blue
          surface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BiometricAuthManager _authManager = BiometricAuthManager();

  bool _isAvailable = false;
  BiometricType _biometricType = BiometricType.none;
  String _statusMessage = 'Check support to get started';
  bool _isLoading = false;
  Map<String, dynamic>? _lastCredentialResult;

  @override
  void initState() {
    super.initState();
    _checkSupportSilently();
  }

  Future<void> _checkSupportSilently() async {
    try {
      final available = await _authManager.isBiometricAvailable();
      final type = await _authManager.getAvailableBiometricType();
      setState(() {
        _isAvailable = available;
        _biometricType = type;
      });
    } catch (_) {}
  }

  Future<void> _checkSupport() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking support...';
    });
    try {
      final available = await _authManager.isBiometricAvailable();
      final type = await _authManager.getAvailableBiometricType();
      setState(() {
        _isAvailable = available;
        _biometricType = type;
        _statusMessage = available
            ? 'Biometrics are available! Type: ${_getBiometricName(type)}'
            : 'Biometrics are not configured or supported.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Authenticating...';
    });
    try {
      final success = await _authManager.authenticate(
        reason: 'Please authenticate to log in securely.',
        title: 'Security Verification',
        cancelTitle: 'Cancel',
      );
      setState(() {
        _statusMessage =
            success ? 'Authentication Successful!' : 'Authentication Failed.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Authentication Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerPasskey() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Registering Passkey...';
      _lastCredentialResult = null;
    });
    try {
      // Standard credentials options with Base64url encoded challenge and user ID
      final options = {
        'publicKey': {
          'challenge': 'aGVsZG93b3JsZA', // "heldoworld"
          'rp': {
            'name': 'Biometric Auth Manager Example',
            'id': 'localhost',
          },
          'user': {
            'id': 'dXNlcl9pZF8xMjM', // "user_id_123"
            'name': 'john.doe@example.com',
            'displayName': 'John Doe',
          },
          'pubKeyCredParams': [
            {'type': 'public-key', 'alg': -7}, // ES256
            {'type': 'public-key', 'alg': -257}, // RS256
          ],
          'timeout': 60000,
          'authenticatorSelection': {
            'authenticatorAttachment': 'platform',
            'requireResidentKey': true,
            'userVerification': 'required',
          },
        }
      };

      final result = await _authManager.registerPasskey(options: options);
      setState(() {
        if (result != null) {
          _lastCredentialResult = result;
          _statusMessage = 'Passkey Registered Successfully!';
        } else {
          _statusMessage = 'Passkey Registration Failed.';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Registration Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginPasskey() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Logging in with Passkey...';
      _lastCredentialResult = null;
    });
    try {
      final options = {
        'publicKey': {
          'challenge': 'c29tZV9jaGFsbGVuZ2U', // "some_challenge"
          'timeout': 60000,
          'rpId': 'localhost',
          'userVerification': 'required',
        }
      };

      final result = await _authManager.authenticatePasskey(options: options);
      setState(() {
        if (result != null) {
          _lastCredentialResult = result;
          _statusMessage = 'Passkey Login Successful!';
        } else {
          _statusMessage = 'Passkey Login Failed.';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Login Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.faceID:
        return 'FaceID';
      case BiometricType.passkey:
        return 'Passkey (WebAuthn)';
      case BiometricType.none:
        return 'None';
    }
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.faceID:
        return Icons.face;
      case BiometricType.passkey:
        return Icons.vpn_key;
      case BiometricType.none:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGradients = [
      const Color(0xFF6366F1),
      const Color(0xFF3B82F6),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: primaryGradients,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Icon(
                          _getBiometricIcon(_biometricType),
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Biometric Manager',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure Multi-platform Authentication',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Support Status Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _isAvailable
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isAvailable
                                  ? 'Biometrics Available'
                                  : 'Biometrics Unavailable',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Type Detected:',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              _getBiometricName(_biometricType),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Status Card
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF334155),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(Icons.info_outline,
                            size: 18, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(
                              fontSize: 13, fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Core Authentication Section
                const Text(
                  'NATIVE OS FLOW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _checkSupport,
                  icon: const Icon(Icons.security),
                  label: const Text('Check Biometric Support'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: _isAvailable && !_isLoading
                          ? primaryGradients
                          : [Colors.grey[800]!, Colors.grey[700]!],
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        _isAvailable && !_isLoading ? _authenticate : null,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text(
                      'Authenticate with Biometry',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // WebAuthn Passkeys Section (Visible only on Web or shown as disabled on Mobile)
                const Text(
                  'WEBAUTHN PASSKEYS (WEB ONLY)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 12),
                if (!kIsWeb)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFEF4444)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Passkey demo options are enabled only when compiled and executed on Web.',
                            style:
                                TextStyle(color: Colors.red[300], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: kIsWeb && !_isLoading ? _registerPasskey : null,
                  icon: const Icon(Icons.add_moderator),
                  label: const Text('Register Passkey (Attestation)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: kIsWeb && !_isLoading ? _loginPasskey : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Login with Passkey (Assertion)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                if (_lastCredentialResult != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'LAST CREDENTIAL RESULT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        const JsonEncoder.withIndent('  ')
                            .convert(_lastCredentialResult),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
