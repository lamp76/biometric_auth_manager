import Flutter
import UIKit
import BiometricCore

public class BiometricAuthManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "biometric_auth_manager", binaryMessenger: registrar.messenger())
    let instance = BiometricAuthManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isBiometricAvailable":
      result(BiometricCore.isBiometricAvailable())
    case "getAvailableBiometricType":
      result(BiometricCore.getAvailableBiometricType())
    case "authenticate":
      guard let args = call.arguments as? [String: Any],
            let reason = args["reason"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Reason is required", details: nil))
        return
      }
      let cancelTitle = args["cancelTitle"] as? String
      BiometricCore.authenticate(reason: reason, cancelTitle: cancelTitle) { success, errorMsg in
        if success {
          result(true)
        } else {
          result(false)
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
