import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;
import 'biometric_auth_manager_platform_interface.dart';

@JS('window._biometricAuthWebHelper.isAvailable')
external JSPromise _isAvailableJS();

@JS('window._biometricAuthWebHelper.create')
external JSPromise _createJS(JSObject options);

@JS('window._biometricAuthWebHelper.get')
external JSPromise _getJS(JSObject options);

@JS('JSON.parse')
external JSObject _parseJson(JSString jsonStr);

@JS('JSON.stringify')
external JSString _stringifyJson(JSObject jsObj);

class BiometricAuthManagerWeb extends BiometricAuthManagerPlatform {
  static void registerWith(Registrar registrar) {
    _injectJsHelper();
    BiometricAuthManagerPlatform.instance = BiometricAuthManagerWeb();
  }

  static void _injectJsHelper() {
    if (web.document.getElementById('biometric-auth-web-helper') != null) {
      return;
    }
    final script =
        web.document.createElement('script') as web.HTMLScriptElement;
    script.id = 'biometric-auth-web-helper';
    script.text = r'''
      window._biometricAuthWebHelper = {
        isAvailable: function() {
          if (window.PublicKeyCredential && window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable) {
            return window.PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
          }
          return Promise.resolve(false);
        },
        
        _base64ToArrayBuffer: function(base64) {
          var binary_string = window.atob(base64.replace(/-/g, '+').replace(/_/g, '/'));
          var len = binary_string.length;
          var bytes = new Uint8Array(len);
          for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
          }
          return bytes.buffer;
        },
        
        _arrayBufferToBase64: function(buffer) {
          var binary = '';
          var bytes = new Uint8Array(buffer);
          var len = bytes.byteLength;
          for (var i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
          }
          return window.btoa(binary).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
        },

        create: function(options) {
          try {
            if (!options.publicKey) {
              return Promise.reject(new Error("publicKey options are required."));
            }
            var challenge = this._base64ToArrayBuffer(options.publicKey.challenge);
            var userId = this._base64ToArrayBuffer(options.publicKey.user.id);
            
            var excludeCredentials = [];
            if (options.publicKey.excludeCredentials) {
              for (var i = 0; i < options.publicKey.excludeCredentials.length; i++) {
                var item = options.publicKey.excludeCredentials[i];
                excludeCredentials.push({
                  type: item.type,
                  id: this._base64ToArrayBuffer(item.id),
                  transports: item.transports
                });
              }
            }
            
            var pkOptions = Object.assign({}, options.publicKey, {
              challenge: challenge,
              user: Object.assign({}, options.publicKey.user, { id: userId }),
              excludeCredentials: excludeCredentials
            });
            
            return navigator.credentials.create({ publicKey: pkOptions }).then((credential) => {
              if (!credential) return null;
              var response = credential.response;
              return {
                id: credential.id,
                rawId: this._arrayBufferToBase64(credential.rawId),
                type: credential.type,
                authenticatorAttachment: credential.authenticatorAttachment,
                response: {
                  clientDataJSON: this._arrayBufferToBase64(response.clientDataJSON),
                  attestationObject: this._arrayBufferToBase64(response.attestationObject),
                  transports: response.getTransports ? response.getTransports() : []
                }
              };
            });
          } catch (e) {
            return Promise.reject(e);
          }
        },

        get: function(options) {
          try {
            if (!options.publicKey) {
              return Promise.reject(new Error("publicKey options are required."));
            }
            var challenge = this._base64ToArrayBuffer(options.publicKey.challenge);
            
            var allowCredentials = [];
            if (options.publicKey.allowCredentials) {
              for (var i = 0; i < options.publicKey.allowCredentials.length; i++) {
                var item = options.publicKey.allowCredentials[i];
                allowCredentials.push({
                  type: item.type,
                  id: this._base64ToArrayBuffer(item.id),
                  transports: item.transports
                });
              }
            }
            
            var pkOptions = Object.assign({}, options.publicKey, {
              challenge: challenge,
              allowCredentials: allowCredentials
            });
            
            return navigator.credentials.get({ publicKey: pkOptions }).then((credential) => {
              if (!credential) return null;
              var response = credential.response;
              return {
                id: credential.id,
                rawId: this._arrayBufferToBase64(credential.rawId),
                type: credential.type,
                authenticatorAttachment: credential.authenticatorAttachment,
                response: {
                  clientDataJSON: this._arrayBufferToBase64(response.clientDataJSON),
                  authenticatorData: this._arrayBufferToBase64(response.authenticatorData),
                  signature: this._arrayBufferToBase64(response.signature),
                  userHandle: response.userHandle ? this._arrayBufferToBase64(response.userHandle) : null
                }
              };
            });
          } catch (e) {
            return Promise.reject(e);
          }
        }
      };
    ''';
    web.document.head?.appendChild(script);
  }

  JSObject _mapToJSObject(Map<String, dynamic> map) {
    final jsonString = json.encode(map);
    return _parseJson(jsonString.toJS);
  }

  Map<String, dynamic>? _jsObjectToMap(JSObject? jsObj) {
    if (jsObj == null || jsObj.isUndefinedOrNull) return null;
    final jsonString = _stringifyJson(jsObj).toDart;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final jsVal = await _isAvailableJS().toDart;
      if (jsVal != null && jsVal.isA<JSBoolean>()) {
        return (jsVal as JSBoolean).toDart;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<BiometricType> getAvailableBiometricType() async {
    final available = await isBiometricAvailable();
    return available ? BiometricType.passkey : BiometricType.none;
  }

  @override
  Future<bool> authenticate({
    required String reason,
    String? title,
    String? cancelTitle,
  }) async {
    return isBiometricAvailable();
  }

  @override
  Future<Map<String, dynamic>?> registerPasskey({
    required Map<String, dynamic> options,
  }) async {
    try {
      final jsOptions = _mapToJSObject(options);
      final jsRes = await _createJS(jsOptions).toDart;
      return _jsObjectToMap(jsRes as JSObject?);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> authenticatePasskey({
    required Map<String, dynamic> options,
  }) async {
    try {
      final jsOptions = _mapToJSObject(options);
      final jsRes = await _getJS(jsOptions).toDart;
      return _jsObjectToMap(jsRes as JSObject?);
    } catch (e) {
      return null;
    }
  }
}
