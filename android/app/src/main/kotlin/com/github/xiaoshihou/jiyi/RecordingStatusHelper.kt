package com.github.xiaoshihou.jiyi

import android.content.Context
import android.content.SharedPreferences
import androidx.work.*
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit
import java.util.concurrent.TimeUnit

object RecordingStatusHelper {
    private const val PREFS_NAME = "jiyi_widget_prefs"
    private const val KEY_LAST_RECORDING_DATE = "last_recording_date"
    private const val KEY_STORAGE_CONFIGURED = "storage_configured"
    private const val WORK_TAG = "widget_daily_reset"
    
    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    fun hasRecordedToday(context: Context): Boolean {
        val prefs = getPrefs(context)
        val lastRecordingDate = prefs.getString(KEY_LAST_RECORDING_DATE, null)
        val today = LocalDate.now().toString()
        return lastRecordingDate == today
    }
    
    fun markRecordedToday(context: Context) {
        val prefs = getPrefs(context)
        val today = LocalDate.now().toString()
        prefs.edit().putString(KEY_LAST_RECORDING_DATE, today).apply()
        
        // Update all widgets
        RecordingWidgetProvider.updateAllWidgets(context)
    }
    
    fun isStorageConfigured(context: Context): Boolean {
        val prefs = getPrefs(context)
        return prefs.getBoolean(KEY_STORAGE_CONFIGURED, false)
    }
    
    fun setStorageConfigured(context: Context, configured: Boolean) {
        val prefs = getPrefs(context)
        prefs.edit().putBoolean(KEY_STORAGE_CONFIGURED, configured).apply()
        
        // Update all widgets
        RecordingWidgetProvider.updateAllWidgets(context)
    }
    
    fun scheduleDailyReset(context: Context) {
        val currentTime = java.time.LocalDateTime.now()
        val nextMidnight = currentTime.toLocalDate().plusDays(1).atStartOfDay()
        val delayMillis = ChronoUnit.MILLIS.between(currentTime, nextMidnight)
        
        val dailyWorkRequest = PeriodicWorkRequestBuilder<ResetWidgetWorker>(
            1, TimeUnit.DAYS
        )
            .setInitialDelay(delayMillis, TimeUnit.MILLISECONDS)
            .addTag(WORK_TAG)
            .build()
        
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            WORK_TAG,
            ExistingPeriodicWorkPolicy.KEEP,
            dailyWorkRequest
        )
    }
    
    fun cancelDailyReset(context: Context) {
        WorkManager.getInstance(context).cancelAllWorkByTag(WORK_TAG)
    }
}

class ResetWidgetWorker(
    context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {
    
    override fun doWork(): Result {
        // Update all widgets for the new day
        RecordingWidgetProvider.updateAllWidgets(applicationContext)
        return Result.success()
    }
}
