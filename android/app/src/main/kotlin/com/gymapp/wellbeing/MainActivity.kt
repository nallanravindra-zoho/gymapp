package com.gymapp.wellbeing

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var linkChannel: MethodChannel? = null
    private var initialLinkTaken = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Opening the phone's own settings pages, and reading the battery
        // setting that decides whether reminders may run in the background.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" -> {
                        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(power.isIgnoringBatteryOptimizations(packageName))
                    }
                    "openBatterySettings" -> {
                        openSettings(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        result.success(null)
                    }
                    "openNotificationSettings" -> {
                        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        openIntent(intent)
                        result.success(null)
                    }
                    "openAppSettings" -> {
                        openSettings(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.fromParts("package", packageName, null)
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Invite links (wellbeing://join/CODE) that open the app. A link that
        // started the app is read once by Dart; links that arrive while it is
        // running are pushed to Dart.
        linkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LINK_CHANNEL).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialLink" -> {
                        if (initialLinkTaken) {
                            result.success(null)
                        } else {
                            initialLinkTaken = true
                            result.success(inviteLinkIn(intent))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAccess" -> result.success(hasUsageAccess())

                    "openSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        )
                        result.success(null)
                    }

                    "queryDay" -> {
                        val start = call.argument<Number>("start")?.toLong()
                        val end = call.argument<Number>("end")?.toLong()
                        if (start == null || end == null) {
                            result.error("bad_args", "start and end are required", null)
                            return@setMethodCallHandler
                        }
                        // Reading events can take a moment: keep it off the UI thread.
                        Thread {
                            try {
                                val data = UsageReader(this).readDay(start, end).toMap()
                                runOnUiThread { result.success(data) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("usage_error", e.message, null) }
                            }
                        }.start()
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        inviteLinkIn(intent)?.let { linkChannel?.invokeMethod("link", it) }
    }

    /** The wellbeing:// link this intent carries, if it carries one. */
    private fun inviteLinkIn(intent: Intent?): String? {
        val data = intent?.data ?: return null
        return if (Intent.ACTION_VIEW == intent.action && data.scheme == "wellbeing") {
            data.toString()
        } else {
            null
        }
    }

    private fun openSettings(action: String, data: Uri? = null) {
        val intent = Intent(action)
        if (data != null) intent.data = data
        openIntent(intent)
    }

    /** Opens a settings page; if this phone has no such page, app details. */
    private fun openIntent(intent: Intent) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.fromParts("package", packageName, null)
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            )
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        @Suppress("DEPRECATION")
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    companion object {
        private const val USAGE_CHANNEL = "wellbeing/usage"
        private const val SYSTEM_CHANNEL = "wellbeing/system"
        private const val LINK_CHANNEL = "wellbeing/links"
    }
}
