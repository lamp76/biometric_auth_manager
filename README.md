# biometric_auth_manager

[![CI](https://github.com/lamp76/biometric_auth_manager/actions/workflows/build_native_libraries.yml/badge.svg)](https://github.com/lamp76/biometric_auth_manager/actions/workflows/build_native_libraries.yml)
[![pub package](https://img.shields.io/pub/v/biometric_auth_manager.svg)](https://pub.dev/packages/biometric_auth_manager)
[![pub points](https://img.shields.io/pub/points/biometric_auth_manager)](https://pub.dev/packages/biometric_auth_manager/score)
[![popularity](https://img.shields.io/pub/popularity/biometric_auth_manager)](https://pub.dev/packages/biometric_auth_manager/score)
[![likes](https://img.shields.io/pub/likes/biometric_auth_manager)](https://pub.dev/packages/biometric_auth_manager/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20Me-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/lamp76)

A Flutter package for simplified management of biometric authentication (Fingerprint, FaceID, or other native methods provided by the OS) and Passkeys (WebAuthn) on the Web.

This package uses native precompiled libraries linked locally to keep the main plugin code clean and decoupled. On iOS, it uses Swift Package Manager (SPM) exclusively, eliminating CocoaPods dependencies entirely. On Android, it loads a local `.aar` file, and on the Web, it implements native WebAuthn credentials APIs without loading mobile native channels, preventing runtime exceptions.

## Features

| Feature | Android | iOS | Web |
|---------|---------|-----|-----|
| Fingerprint Authentication | ✅ | ✅ | ❌ |
| FaceID Authentication | ✅ | ✅ | ❌ |
| Hardware Support Detection | ✅ | ✅ | ✅ |
| Passkey Registration (Attestation) | ❌ | ❌ | ✅ |
| Passkey Authentication (Assertion) | ❌ | ❌ | ✅ |

---

## Installation & Platform Configuration

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  biometric_auth_manager:
    path: path/to/biometric_auth_manager
```

### Android Setup

1. Add the biometric permission to your `AndroidManifest.xml` (e.g., inside `example/android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

2. Make sure your `MainActivity` extends `FlutterFragmentActivity` instead of `FlutterActivity`. This is required for `BiometricPrompt` UI display:

```kotlin
package com.example.your_app

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
}
```

### iOS Setup

Add the FaceID usage description key to your `Info.plist` (e.g., inside `example/ios/Runner/Info.plist`):

```xml
<key>NSFaceIDUsageDescription</key>
<string>We use FaceID to secure your session authentication.</string>
```

> [!IMPORTANT]
> This plugin is not using CocoaPods on iOS. Ensure your Xcode project is configured to resolve packages using Swift Package Manager.

### Web Setup

Passkeys require a secure context (HTTPS) to function in browsers, except for `localhost` which is allowed for development. Ensure your server is served over HTTPS when deploying to production.

---

## Usage Guide

### 1. Initialize and Check Availability

Check if the device supports biometric hardware and has at least one fingerprint or face enrolled.

```dart
import 'package:biometric_auth_manager/biometric_auth_manager.dart';

final authManager = BiometricAuthManager();

bool available = await authManager.isBiometricAvailable();
BiometricType type = await authManager.getAvailableBiometricType();

print("Biometrics available: $available, Type: $type");
// type can be BiometricType.fingerprint, BiometricType.faceID, BiometricType.passkey, or BiometricType.none
```

### 2. Native OS Biometric Authentication

Show the OS native biometric prompt dialog.

```dart
bool success = await authManager.authenticate(
  reason: 'Please verify your identity to access your dashboard.',
  title: 'Secure Access',
  cancelTitle: 'Cancel',
);

if (success) {
  // Authentication succeeded, proceed
} else {
  // Authentication failed or was cancelled
}
```

### 3. WebAuthn Passkeys (Web Only)

#### Register a Passkey (Attestation)
Send credentials options returned by your backend authentication server to register a new Passkey credential:

```dart
final registrationOptions = {
  'publicKey': {
    'challenge': 'aGVsZG93b3JsZA', // Base64url encoded challenge string
    'rp': {
      'name': 'My Secure App',
      'id': 'localhost',
    },
    'user': {
      'id': 'dXNlcl9pZF8xMjM', // Base64url encoded user ID
      'name': 'user@example.com',
      'displayName': 'Jane Doe',
    },
    'pubKeyCredParams': [
      {'type': 'public-key', 'alg': -7},  // ES256
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

final result = await authManager.registerPasskey(options: registrationOptions);
if (result != null) {
  // Send the registered credential map back to your server for verification
}
```

#### Authenticate with a Passkey (Assertion)
Send the authentication challenge to verify an existing credential:

```dart
final loginOptions = {
  'publicKey': {
    'challenge': 'c29tZV9jaGFsbGVuZ2U', // Base64url encoded challenge string
    'timeout': 60000,
    'rpId': 'localhost',
    'userVerification': 'required',
  }
};

final result = await authManager.authenticatePasskey(options: loginOptions);
if (result != null) {
  // Send the login signature map back to your server to complete login session
}
```

---

## Native Architecture & Manual Compilations

To keep the codebase modular, biometric operations are decoupled into standalone native libraries:
* **Android:** Compiled as `biometric_core.aar` wrapping `androidx.biometric` APIs.
* **iOS:** Compiled as `BiometricCore.xcframework` wrapping `LocalAuthentication` APIs.

For local compilation on platforms where precompiled native libraries are not installed or generated, we provide a Python utility script `scripts/generate_placeholders.py` which populates dummy files to bypass linker errors.

```bash
# Generate placeholders locally (for initial offline mock testing)
python scripts/generate_placeholders.py
```

### Compiling Native Binaries
To build the native binary files manually, compile the source projects inside `native_src/`:

#### Compile Android (.aar)
```bash
cd native_src/android
# Run gradle build (requires Android SDK and Java)
gradle assembleRelease
# Copy output AAR to plugin folder:
cp build/outputs/aar/android-release.aar ../../android/libs/biometric_core.aar
```

#### Compile iOS (.xcframework)
```bash
cd native_src/ios/BiometricCore
# Archive for simulator and device (requires Xcode and macOS)
xcodebuild archive -packagePath . -scheme BiometricCore -destination "generic/platform=iOS" -archivePath "archives/BiometricCore-iOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -packagePath . -scheme BiometricCore -destination "generic/platform=iOS Simulator" -archivePath "archives/BiometricCore-iOS-Simulator.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create unified XCFramework
xcodebuild -create-xcframework \
  -framework archives/BiometricCore-iOS.xcarchive/Products/Library/Frameworks/BiometricCore.framework \
  -framework archives/BiometricCore-iOS-Simulator.xcarchive/Products/Library/Frameworks/BiometricCore.framework \
  -output ../../../ios/Frameworks/BiometricCore.xcframework
```
Alternatively, push your code changes to GitHub, and the Actions workflow (`build_native_libraries.yml`) will build these binaries automatically.
