package com.gymapp.wellbeing

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.plugin.common.MethodChannel

/**
 * Opens the system notification-sound picker and reports the chosen URI to
 * Flutter. An empty/null URI means the phone's default sound.
 */
class RingtonePicker(private val activity: Activity) {
    private var pending: MethodChannel.Result? = null

    fun pick(currentUri: String?, result: MethodChannel.Result) {
        if (pending != null) {
            result.error("busy", "The sound picker is already open", null)
            return
        }
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Reminder sound")
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            )
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                if (currentUri.isNullOrEmpty()) {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                } else {
                    Uri.parse(currentUri)
                }
            )
        }
        pending = result
        try {
            activity.startActivityForResult(intent, REQUEST_CODE)
        } catch (e: Exception) {
            pending = null
            result.error("unavailable", e.message, null)
        }
    }

    /** Returns true when the result belonged to the picker. */
    fun handleResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pending ?: return true
        pending = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(mapOf("cancelled" to true))
            return true
        }
        val uri: Uri? = if (Build.VERSION.SDK_INT >= 33) {
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        }
        val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        // The picker's "default" entry comes back as the default URI or null.
        if (uri == null || uri == defaultUri) {
            result.success(mapOf("uri" to "", "title" to "Phone default"))
        } else {
            result.success(mapOf("uri" to uri.toString(), "title" to titleOf(uri.toString())))
        }
        return true
    }

    fun titleOf(uri: String): String? = try {
        RingtoneManager.getRingtone(activity, Uri.parse(uri))?.getTitle(activity)
    } catch (e: Exception) {
        null
    }

    companion object {
        const val CHANNEL = "wellbeing/ringtone"
        const val REQUEST_CODE = 7410
    }
}
