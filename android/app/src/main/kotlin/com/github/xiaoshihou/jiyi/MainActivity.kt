package com.github.xiaoshihou.jiyi

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.github.xiaoshihou.jiyi/widget"
    private var methodChannel: MethodChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetStatus" -> {
                    val recorded = call.argument<Boolean>("recorded") ?: false
                    if (recorded) {
                        RecordingStatusHelper.markRecordedToday(this)
                    }
                    result.success(null)
                }
                "setStorageConfigured" -> {
                    val configured = call.argument<Boolean>("configured") ?: false
                    RecordingStatusHelper.setStorageConfigured(this, configured)
                    result.success(null)
                }
                "checkStorageConfigured" -> {
                    val configured = RecordingStatusHelper.isStorageConfigured(this)
                    result.success(configured)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent?.action == "com.github.xiaoshihou.jiyi.START_RECORDING") {
            // Signal to Flutter that we want to start recording
            methodChannel?.invokeMethod("startRecording", null)
        }
    }
}

