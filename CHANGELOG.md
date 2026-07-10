# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-10

### Added
- Official stable release of `biometric_auth_manager`.
- Full native library linkage for Android via local `.aar` import.
- iOS support using Swift Package Manager with binary target linking `BiometricCore.xcframework` directly (no CocoaPods).
- Browser support for WebAuthn Passkeys (Attestation and Assertion) with automatic Base64url and TypedArray marshalling.
- Micro-projects for Android (`native_src/android`) and iOS (`native_src/ios/BiometricCore`) frameworks.
- Automated pipeline workflow using GitHub Actions (`build_native_libraries.yml`) to compile and test native binaries.
- Example application featuring beautiful premium design aesthetics and full feature test UI.

## [0.1.0] - 2026-07-10

### Added
- Initial pre-release of the package framework.
- Core Dart interface APIs and federated plugin definitions.
- Basic platform method channel interfaces.
