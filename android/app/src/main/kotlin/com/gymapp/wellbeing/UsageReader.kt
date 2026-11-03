package com.gymapp.wellbeing

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Build
import java.util.Calendar

/**
 * Reads how long apps were in the foreground between two instants, using
 * Android's usage events. Only totals leave this class: per-app detail stays
 * on the device (spec 8.1).
 */
class UsageReader(private val context: Context) {

    /** Result of [readDay]: minutes in total, per category, and per local hour. */
    class DayUsage(
        val totalMinutes: Int,
        val categories: Map<String, Int>,
        val hours: List<Int>,
    ) {
        fun toMap(): Map<String, Any> = mapOf(
            "totalMinutes" to totalMinutes,
            "categories" to categories,
            "hours" to hours,
        )
    }

    private val packageManager = context.packageManager

    private val ignoredPackages: Set<String> by lazy {
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        val launchers = packageManager.queryIntentActivities(home, 0)
            .map { it.activityInfo.packageName }
        (launchers + context.packageName).toSet()
    }

    fun readDay(startMillis: Long, endMillis: Long): DayUsage {
        val manager =
            context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = manager.queryEvents(startMillis, endMillis)
        val event = UsageEvents.Event()

        val msByCategory = HashMap<String, Long>()
        val msByHour = LongArray(24)
        var totalMs = 0L

        fun close(pkg: String, from: Long, to: Long) {
            if (to <= from || pkg in ignoredPackages) return
            val ms = to - from
            totalMs += ms
            val category = categoryOf(pkg)
            msByCategory[category] = (msByCategory[category] ?: 0L) + ms
            addToHours(msByHour, from, to)
        }

        // One app is in the foreground at a time, and nothing counts while the
        // screen is off or locked. Tracking every package separately let a
        // single lost "paused" event keep an app open for hours, and several
        // of them added up to more than a day.
        var current: String? = null
        var currentClass: String? = null
        var currentSince = 0L

        fun closeCurrent(at: Long) {
            current?.let { close(it, currentSince, at) }
            current = null
            currentClass = null
        }

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            @Suppress("DEPRECATION")
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                    val pkg = event.packageName ?: continue
                    if (pkg != current) {
                        // Another app took over: the earlier one has ended.
                        closeCurrent(event.timeStamp)
                        current = pkg
                        currentSince = event.timeStamp
                    }
                    // Moving between screens of the same app keeps it open.
                    currentClass = event.className
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND, EVENT_ACTIVITY_STOPPED ->
                    // Only the screen that is showing can end the session; a
                    // late "paused" from the screen just left must not.
                    if (event.packageName == current &&
                        (currentClass == null || event.className == currentClass)
                    ) {
                        closeCurrent(event.timeStamp)
                    }
                EVENT_SCREEN_NON_INTERACTIVE,
                EVENT_KEYGUARD_SHOWN,
                EVENT_DEVICE_SHUTDOWN -> closeCurrent(event.timeStamp)
            }
        }
        // The app still showing at the end of the window.
        closeCurrent(endMillis)

        // Usage can never exceed the time that has passed.
        totalMs = minOf(totalMs, endMillis - startMillis)

        return DayUsage(
            totalMinutes = (totalMs / 60_000).toInt(),
            categories = msByCategory.mapValues { (it.value / 60_000).toInt() },
            hours = msByHour.map { (it / 60_000).toInt() },
        )
    }

    /** Splits [from, to) across local hour boundaries. */
    private fun addToHours(msByHour: LongArray, from: Long, to: Long) {
        val cal = Calendar.getInstance()
        var cursor = from
        while (cursor < to) {
            cal.timeInMillis = cursor
            val hour = cal.get(Calendar.HOUR_OF_DAY)
            cal.set(Calendar.MINUTE, 0)
            cal.set(Calendar.SECOND, 0)
            cal.set(Calendar.MILLISECOND, 0)
            cal.add(Calendar.HOUR_OF_DAY, 1)
            val sliceEnd = minOf(cal.timeInMillis, to)
            msByHour[hour] += sliceEnd - cursor
            cursor = sliceEnd
        }
    }

    private fun categoryOf(pkg: String): String {
        if (pkg in BROWSERS) return "browser"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return "other"
        return try {
            when (packageManager.getApplicationInfo(pkg, 0).category) {
                ApplicationInfo.CATEGORY_SOCIAL -> "social"
                ApplicationInfo.CATEGORY_VIDEO -> "video"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
                ApplicationInfo.CATEGORY_GAME -> "games"
                else -> "other"
            }
        } catch (e: Exception) {
            "other"
        }
    }

    companion object {
        // Event types added after the API 21 constants; they simply never
        // occur on older Android versions.
        private const val EVENT_ACTIVITY_STOPPED = 23
        private const val EVENT_SCREEN_NON_INTERACTIVE = 16
        private const val EVENT_KEYGUARD_SHOWN = 17
        private const val EVENT_DEVICE_SHUTDOWN = 26

        // Android has no browser category, so common browsers are listed.
        private val BROWSERS = setOf(
            "com.android.chrome",
            "org.mozilla.firefox",
            "com.brave.browser",
            "com.microsoft.emmx",
            "com.opera.browser",
            "com.sec.android.app.sbrowser",
            "com.duckduckgo.mobile.android",
        )
    }
}
