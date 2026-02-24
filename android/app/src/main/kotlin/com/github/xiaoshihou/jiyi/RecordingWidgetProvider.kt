package com.github.xiaoshihou.jiyi

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.time.LocalDate

class RecordingWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget first created - schedule daily reset
        RecordingStatusHelper.scheduleDailyReset(context)
    }

    override fun onDisabled(context: Context) {
        // Last widget removed - cancel scheduled work
        RecordingStatusHelper.cancelDailyReset(context)
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            
            // Check recording status
            val hasRecordedToday = RecordingStatusHelper.hasRecordedToday(context)
            val isConfigured = RecordingStatusHelper.isStorageConfigured(context)
            
            // Update icon and text based on status
            if (!isConfigured) {
                views.setImageViewResource(R.id.status_icon, R.drawable.ic_widget_not_recorded)
                views.setTextViewText(R.id.status_text, context.getString(R.string.widget_not_configured))
            } else if (hasRecordedToday) {
                views.setImageViewResource(R.id.status_icon, R.drawable.ic_widget_recorded)
                views.setTextViewText(R.id.status_text, context.getString(R.string.widget_recorded))
            } else {
                views.setImageViewResource(R.id.status_icon, R.drawable.ic_widget_not_recorded)
                views.setTextViewText(R.id.status_text, context.getString(R.string.widget_not_recorded))
            }
            
            // Set up click intent
            val intent = Intent(context, MainActivity::class.java).apply {
                action = "com.github.xiaoshihou.jiyi.START_RECORDING"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            
            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
        
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, RecordingWidgetProvider::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }
}
