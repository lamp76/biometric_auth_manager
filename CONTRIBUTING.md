# Contributing to biometric_auth_manager

Thank you for your interest in contributing to `biometric_auth_manager`! We welcome all contributions, including bug fixes, new features, improvements to documentation, and bug reports.

This document outlines the guidelines and workflow to help you get started.

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful, welcoming, and collaborative environment.

---

## How to Contribute

### 1. Reporting Bugs & Suggesting Features
- Search the issue tracker to ensure your bug or feature request hasn't already been reported.
- If it hasn't, open a new issue with a clear description, reproduction steps (for bugs), and expected behavior.

### 2. Developing Changes
If you wish to make code modifications or add new features, follow these steps:

#### Prerequisites
- Flutter SDK (latest stable version recommended)
- Dart SDK
- Python (for running mock helper scripts)
- (Optional) Java JDK 17 & Android SDK (for Android native builds)
- (Optional) macOS & Xcode (for iOS native builds)

#### Setting up the Project
1. Fork and clone the repository:
   ```bash
   git clone https://github.com/lamp76/biometric_auth_manager.git
   cd biometric_auth_manager
   ```
2. Retrieve packages:
   ```bash
   flutter pub get
   ```
3. Generate native placeholders for local mock testing (if you don't intend to compile native binaries locally):
   ```bash
   python scripts/generate_placeholders.py
   ```

#### Compiling Native Binaries (Optional)
If your changes affect the native implementations:
- **Android (.aar):**
  Navigate to `native_src/android`, run `gradle assembleRelease`, and copy the compiled `.aar` to `android/libs/biometric_core.aar`.
- **iOS (.xcframework):**
  Navigate to `native_src/ios/BiometricCore`, build archives using `xcodebuild`, and assemble the `.xcframework` into `ios/Frameworks/BiometricCore.xcframework`.

Refer to the **README.md** for detailed compilation command lines.

### 3. Guidelines

#### Code Style & Formatting
We adhere strictly to the standard Dart style guidelines. Before submitting your pull request, run the formatter:
```bash
dart format .
```

#### Static Analysis
Ensure there are no analysis warnings or errors. Run the analyzer locally:
```bash
dart analyze
```

#### Testing
We require all new code to be tested. Run the existing test suite:
```bash
flutter test
```
If you introduce a new feature, please add corresponding unit tests in the `test/` directory.

---

## Submitting a Pull Request

1. Create a new branch for your changes:
   ```bash
   git checkout -b feature/my-amazing-feature
   ```
2. Commit your changes with clear, descriptive commit messages.
3. Push to your fork and submit a Pull Request (PR) to the `main` branch.
4. Ensure all CI status checks pass.

Thank you for helping to improve `biometric_auth_manager`!
