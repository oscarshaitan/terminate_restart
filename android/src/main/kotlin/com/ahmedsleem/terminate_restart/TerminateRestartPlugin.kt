package com.ahmedsleem.terminate_restart

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.system.exitProcess

/** TerminateRestartPlugin */
class TerminateRestartPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private val TAG = "TerminateRestartPlugin"

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ahmedsleem.terminate_restart/restart")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "restartApp" -> {
                val terminate = call.argument<Boolean>("terminate") ?: true

                try {
                    // Restart the app
                    if (terminate) {
                        restartAppWithTerminate(result)
                    } else {
                        restartAppWithoutTerminate(result)
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error restarting app", e)
                    result.error("RESTART_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun restartAppWithTerminate(result: Result) {
        activity?.let { currentActivity ->
            try {
                Log.d(TAG, "Attempting to restart app with terminate")
                
                // Create the restart intent
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                }

                if (intent != null) {
                    Log.d(TAG, "Created restart intent with package: ${context.packageName}")
                    
                    // Schedule the app restart
                    intent.putExtra("restart_trigger", System.currentTimeMillis())
                    
                    // Return success before starting new activity
                    result.success(true)
                    
                    // Start the new activity and kill the current process
                    Thread {
                        try {
                            // Small delay to ensure the result is sent
                            Thread.sleep(100)
                            
                            // Start the new activity
                            context.startActivity(intent)
                            
                            // Force close all activities
                            currentActivity.finishAffinity()
                            
                            // Kill the current process
                            Log.d(TAG, "Terminating process")
                            Process.killProcess(Process.myPid())
                            exitProcess(0)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error in termination thread", e)
                        }
                    }.start()
                } else {
                    Log.e(TAG, "Could not create launch intent")
                    result.error("INTENT_ERROR", "Could not create launch intent", null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error restarting app", e)
                result.error("RESTART_FAILED", e.message, null)
            }
        }
    }

    private fun restartAppWithoutTerminate(result: Result) {
        activity?.let { currentActivity ->
            try {
                Log.d(TAG, "Attempting to restart app without terminate")
                currentActivity.runOnUiThread {
                    try {
                        currentActivity.recreate()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error during UI-only restart", e)
                        result.error("RESTART_ERROR", e.message, null)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error restarting app", e)
                result.error("RESTART_ERROR", e.message, null)
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
