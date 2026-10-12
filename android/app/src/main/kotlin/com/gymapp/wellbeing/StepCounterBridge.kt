package com.gymapp.wellbeing

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

/**
 * Step counting for timed walks and runs. Uses the phone's step counter
 * sensor, which reports a running total since the phone last started; the
 * app subtracts the starting total itself. The activity permission is asked
 * for only when a timed walk or run begins.
 */
class StepCounterBridge(private val activity: Activity) {

    private val sensorManager =
        activity.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private var pendingPermission: MethodChannel.Result? = null

    fun handle(method: String, result: MethodChannel.Result): Boolean {
        when (method) {
            "requestPermission" -> requestPermission(result)
            "readTotal" -> readTotal(result)
            else -> return false
        }
        return true
    }

    private fun hasPermission(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q ||
            activity.checkSelfPermission(Manifest.permission.ACTIVITY_RECOGNITION) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestPermission(result: MethodChannel.Result) {
        if (stepSensor == null) {
            result.success(false)
        } else if (hasPermission()) {
            result.success(true)
        } else if (pendingPermission != null) {
            result.success(false)
        } else {
            pendingPermission = result
            activity.requestPermissions(
                arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                REQUEST_CODE
            )
        }
    }

    fun onPermissionResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != REQUEST_CODE) return
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingPermission?.success(granted)
        pendingPermission = null
    }

    /** Waits briefly for one reading, then reports it (null when none). */
    private fun readTotal(result: MethodChannel.Result) {
        val sensor = stepSensor
        if (sensor == null || !hasPermission()) {
            result.success(null)
            return
        }
        val handler = Handler(Looper.getMainLooper())
        var done = false
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent) {
                if (done) return
                done = true
                sensorManager.unregisterListener(this)
                result.success(event.values[0].toLong())
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }
        sensorManager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        handler.postDelayed({
            if (!done) {
                done = true
                sensorManager.unregisterListener(listener)
                result.success(null)
            }
        }, 2500)
    }

    companion object {
        const val CHANNEL = "wellbeing/steps"
        private const val REQUEST_CODE = 4107
    }
}
