# Roadmap

This roadmap outlines the future direction and milestones for the `biometric_auth_manager` package.

---

## Milestone 1: Fallback & Recovery Flows
- [ ] **PIN/Pattern/Password Fallback:** Integrate system-level security credential inputs (device passcode) as alternative authentication when biometrics fail or are locked.
- [ ] **Custom Biometric Lockout Handling:** Expose specialized exception types and hooks to gracefully detect and handle temporary or permanent biometric lockouts in the application.

## Milestone 2: Cryptographic Secure Storage (Secure Enclave / KeyStore)
- [ ] **Hardware-backed Key Generation:** Add APIs to generate secure cryptographic keys (e.g., Elliptic Curve) within Android KeyStore or iOS Secure Enclave.
- [ ] **Biometric-bound Key Usage:** Require successful biometric authorization at runtime to release/sign with the generated private key, allowing end-to-end cryptographic trust verification.

## Milestone 3: Native Passkeys for Mobile Platforms
- [ ] **Native iOS Passkeys (ASAuthorizationController):** Integrate Swift-side native Passkey registration and login flows.
- [ ] **Native Android Passkeys (Credential Manager):** Integrate Kotlin-side Android 14+ Credential Manager APIs for seamless Passkey assertion and attestation.
- [ ] **Unified Multi-platform Passkey API:** Align the mobile Passkey calls with the existing Web API, creating a single Dart interface for passwordless authentication across Android, iOS, and Web.

## Milestone 4: Custom Branding & Localization
- [ ] **Rich Dialog Styling:** Support custom icon graphics, colors, and layout configurations inside the biometric prompt UI sheets where supported by the operating system.
- [ ] **Dynamic Language Customization:** Expand options to accept full localization maps for prompt strings, warning alerts, and button labels on all platforms.
