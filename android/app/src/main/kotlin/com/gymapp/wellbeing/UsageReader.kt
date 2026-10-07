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

        val openSince = HashMap<String, Long>()
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

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName ?: continue
            @Suppress("DEPRECATION")
            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND ->
                    // A second resume without a pause keeps the earlier start.
                    if (!openSince.containsKey(pkg)) openSince[pkg] = event.timeStamp
                UsageEvents.Event.MOVE_TO_BACKGROUND ->
                    openSince.remove(pkg)?.let { close(pkg, it, event.timeStamp) }
            }
        }
        // Apps still in the foreground at the end of the window.
        for ((pkg, since) in openSince) close(pkg, since, endMillis)

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
