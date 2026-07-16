package com.example.biometric_core

import android.content.Context
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor

class BiometricCore(private val context: Context) {
    fun isBiometricAvailable(): Boolean {
        val biometricManager = BiometricManager.from(context)
        return biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS
    }

    fun getAvailableBiometricType(): String {
        val biometricManager = BiometricManager.from(context)
        val canAuth = biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
        return if (canAuth == BiometricManager.BIOMETRIC_SUCCESS) {
            "fingerprint"
        } else {
            "none"
        }
    }

    fun authenticate(
        activity: FragmentActivity,
        title: String,
        subtitle: String?,
        description: String?,
        negativeButtonText: String,
        callback: BiometricCallback
    ) {
        val executor: Executor = ContextCompat.getMainExecutor(activity)
        val biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    callback.onError(errorCode, errString.toString())
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    callback.onSuccess()
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    callback.onFailed()
                }
            })

        val promptInfoBuilder = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setNegativeButtonText(negativeButtonText)

        if (subtitle != null) {
            promptInfoBuilder.setSubtitle(subtitle)
        }
        if (description != null) {
            promptInfoBuilder.setDescription(description)
        }

        val promptInfo = promptInfoBuilder.build()
        biometricPrompt.authenticate(promptInfo)
    }

    interface BiometricCallback {
        fun onSuccess()
        fun onError(errorCode: Int, errorString: String)
        fun onFailed()
    }
}
