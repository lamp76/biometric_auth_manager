package com.example.biometric_auth_manager

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Import the precompiled AAR core class
import com.example.biometric_core.BiometricCore

class BiometricAuthManagerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private var context: Context? = null
  private var activity: Activity? = null
  private var biometricCore: BiometricCore? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "biometric_auth_manager")
    channel.setMethodCallHandler(this)
    biometricCore = BiometricCore(flutterPluginBinding.applicationContext)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
    biometricCore = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "isBiometricAvailable" -> {
        val available = biometricCore?.isBiometricAvailable() ?: false
        result.success(available)
      }
      "getAvailableBiometricType" -> {
        val type = biometricCore?.getAvailableBiometricType() ?: "none"
        result.success(type)
      }
      "authenticate" -> {
        val reason = call.argument<String>("reason") ?: "Authenticate"
        val title = call.argument<String>("title") ?: "Biometric Authentication"
        val cancelTitle = call.argument<String>("cancelTitle") ?: "Cancel"
        
        val currentActivity = activity
        if (currentActivity == null) {
          result.error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
          return
        }
        
        if (currentActivity !is FragmentActivity) {
          result.error("INVALID_ACTIVITY", "Activity is not a FragmentActivity. Ensure your MainActivity extends FlutterFragmentActivity.", null)
          return
        }

        biometricCore?.authenticate(
          currentActivity,
          title,
          null, // subtitle
          reason, // description
          cancelTitle,
          object : BiometricCore.BiometricCallback {
            override fun onSuccess() {
              activity?.runOnUiThread {
                result.success(true)
              }
            }

            override fun onError(errorCode: Int, errorString: String) {
              activity?.runOnUiThread {
                result.success(false)
              }
            }

            override fun onFailed() {
              activity?.runOnUiThread {
                result.success(false)
              }
            }
          }
        )
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  // ActivityAware Interface implementation
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = null
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
