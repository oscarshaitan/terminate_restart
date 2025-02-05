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
import java.io.File

/** TerminateRestartPlugin */
class TerminateRestartPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private val TAG = "TerminateRestartPlugin"
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ahmedsleem.terminate_restart/restart")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        this.flutterPluginBinding = flutterPluginBinding
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "restartApp" -> handleRestartApp(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleRestartApp(call: MethodCall, result: Result) {
        try {
            val options = call.arguments as? Map<String, Any>
            val terminate = options?.get("terminate") as? Boolean ?: false
            val clearData = options?.get("clearData") as? Boolean ?: false
            val preserveKeychain = options?.get("preserveKeychain") as? Boolean ?: false
            val preserveUserDefaults = options?.get("preserveUserDefaults") as? Boolean ?: false

            if (clearData) {
                clearAppData(preserveKeychain, preserveUserDefaults) { success, error ->
                    if (success) {
                        performRestart(terminate)
                        result.success(true)
                    } else {
                        result.error("CLEAR_ERROR", "Failed to clear app data", error?.message)
                    }
                }
            } else {
                performRestart(terminate)
                result.success(true)
            }
        } catch (e: Exception) {
            result.error("RESTART_ERROR", "Failed to restart app", e.message)
        }
    }

    private fun performRestart(terminate: Boolean) {
        val activity = activity ?: return
        
        if (terminate) {
            // Full app termination
            android.os.Process.killProcess(android.os.Process.myPid())
        } else {
            // UI-only restart with state reset
            activity.runOnUiThread {
                try {
                    // Create an internal channel to communicate with Flutter
                    val messenger = flutterPluginBinding?.binaryMessenger
                    if (messenger != null) {
                        val channel = MethodChannel(messenger, "com.ahmedsleem.terminate_restart/internal")
                        // Notify Flutter to reset navigation and state
                        channel.invokeMethod("resetToRoot", null)
                    }
                    
                    // Get the Flutter activity
                    val flutterActivity = activity as? FlutterActivity
                    if (flutterActivity != null) {
                        // Create new intent to restart the activity
                        val intent = activity.intent
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
                        intent.putExtra("uiRestart", true)
                        
                        // Start new activity instance while preserving the engine
                        activity.startActivity(intent)
                        activity.overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
                        
                        // Finish current activity
                        activity.finish()
                    } else {
                        // Fallback to simple recreate if not FlutterActivity
                        activity.recreate()
                    }
                } catch (e: Exception) {
                    Log.e("TerminateRestart", "Error during UI restart: ${e.message}")
                }
            }
        }
    }

    private fun clearAppData(preserveKeychain: Boolean, preserveUserDefaults: Boolean, callback: (Boolean, Throwable?) -> Unit) {
        try {
            Log.d(TAG, "Clearing app data (preserveKeychain: $preserveKeychain, preserveUserDefaults: $preserveUserDefaults)")
            
            // Clear SharedPreferences if not preserved
            if (!preserveUserDefaults) {
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                    .edit()
                    .clear()
                    .apply()
                Log.d(TAG, "Cleared SharedPreferences")
            }

            // Clear app cache
            context.cacheDir?.deleteRecursively()
            context.externalCacheDir?.deleteRecursively()
            Log.d(TAG, "Cleared cache directories")

            // Clear app files
            context.filesDir.listFiles()?.forEach { file ->
                if (file.name != "shared_prefs" || !preserveUserDefaults) {
                    file.deleteRecursively()
                }
            }
            Log.d(TAG, "Cleared files directory")

            // Clear external files
            context.getExternalFilesDir(null)?.deleteRecursively()
            Log.d(TAG, "Cleared external files")

            // Clear databases
            for (database in context.databaseList()) {
                context.deleteDatabase(database)
            }
            Log.d(TAG, "Cleared databases")

            // Clear WebView data
            context.deleteDatabase("webview.db")
            context.deleteDatabase("webviewCache.db")
            File(context.filesDir.parent, "app_webview").deleteRecursively()
            Log.d(TAG, "Cleared WebView data")

            callback(true, null)
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing app data", e)
            callback(false, e)
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
