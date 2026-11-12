package com.sikkim.slsa.nyaya_saathi

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SIM_CHANNEL = "com.sikkim.slsa.nyaya_saathi/sim_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SIM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSimCards" -> {
                    try {
                        val simList = getActiveSimCards()
                        result.success(simList)
                    } catch (e: Exception) {
                        result.success(emptyList<Map<String, Any?>>())
                    }
                }
                "requestPhoneHint" -> {
                    try {
                        val numbers = getDetectedPhoneNumbers()
                        result.success(numbers)
                    } catch (e: Exception) {
                        result.success(emptyList<String>())
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getActiveSimCards(): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        val context = applicationContext

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
            if (subscriptionManager != null) {
                try {
                    val activeSubscriptions = subscriptionManager.activeSubscriptionInfoList
                    if (activeSubscriptions != null) {
                        for (subInfo in activeSubscriptions) {
                            val slotIndex = subInfo.simSlotIndex
                            val carrierName = subInfo.carrierName?.toString() ?: subInfo.displayName?.toString() ?: ""
                            var number: String? = null
                            try {
                                number = subInfo.number
                            } catch (_: SecurityException) {
                                // Modern Android restricts number access without READ_PHONE_NUMBERS
                            }

                            list.add(mapOf(
                                "slotIndex" to slotIndex,
                                "carrierName" to carrierName,
                                "displayName" to "SIM ${slotIndex + 1}${if (carrierName.isNotBlank()) " ($carrierName)" else ""}",
                                "number" to number
                            ))
                        }
                    }
                } catch (e: SecurityException) {
                    // Telephony permission not granted, safe fallback
                } catch (e: Exception) {
                    // Safe fallback
                }
            }
        }

        // If no subscriptions found via SubscriptionManager, check basic TelephonyManager
        if (list.isEmpty()) {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
            if (telephonyManager != null) {
                val simState = telephonyManager.simState
                if (simState == TelephonyManager.SIM_STATE_READY) {
                    val operatorName = telephonyManager.simOperatorName ?: ""
                    list.add(mapOf(
                        "slotIndex" to 0,
                        "carrierName" to operatorName,
                        "displayName" to "SIM 1${if (operatorName.isNotBlank()) " ($operatorName)" else ""}",
                        "number" to null
                    ))
                }
            }
        }

        return list
    }

    private fun getDetectedPhoneNumbers(): List<String> {
        val numbers = mutableListOf<String>()
        val simCards = getActiveSimCards()
        for (sim in simCards) {
            val num = sim["number"] as? String
            if (!num.isNullOrBlank()) {
                numbers.add(num)
            }
        }
        return numbers
    }
}
