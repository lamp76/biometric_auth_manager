import Foundation
import LocalAuthentication

@objc public class BiometricCore: NSObject {
    @objc public static func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    @objc public static func getAvailableBiometricType() -> String {
        let context = LAContext()
        var error: NSError?
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        switch context.biometryType {
        case .faceID:
            return "faceID"
        case .touchID:
            return "fingerprint"
        case .none:
            return "none"
        @unknown default:
            return "none"
        }
    }
    
    @objc public static func authenticate(
        reason: String,
        cancelTitle: String?,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let context = LAContext()
        if let cancel = cancelTitle {
            context.localizedCancelTitle = cancel
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    completion(false, error?.localizedDescription ?? "Authentication failed")
                }
            }
        }
    }
}
