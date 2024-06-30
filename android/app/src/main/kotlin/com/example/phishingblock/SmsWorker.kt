package com.example.phishingblock

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class SmsWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    companion object {
        private const val CHANNEL = "com.jjj.phishingblock/sms"
    }

    private lateinit var flutterEngine: FlutterEngine

    override fun doWork(): Result {
        val smsMessage = inputData.getString("smsMessage")
        val receivedTime = inputData.getLong("receivedTime", -1L)
        if (smsMessage != null) {
            Log.d("SmsWorker", "Received SMS: $smsMessage")
            Log.d("SmsWorker", "Received Time: $receivedTime")
            // UI 스레드에서 FlutterEngine을 초기화하고 메시지를 보냅니다.
            Handler(Looper.getMainLooper()).post {
                try {
                    initializeFlutterEngine(applicationContext)
                    sendSmsToFlutter(smsMessage, receivedTime)
                } catch (e: Exception) {
                    Log.e("SmsWorker", "Error in doWork", e)
                    Result.failure()
                }
            }
        }
        return Result.success()
    }

    private fun initializeFlutterEngine(context: Context) {
        try {
            // FlutterEngine을 초기화합니다.
            flutterEngine = FlutterEngine(context)
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                // Flutter에서 호출되는 메서드를 처리합니다.
            }
        } catch (e: Exception) {
            Log.e("SmsWorker", "Error initializing FlutterEngine", e)
        }
    }

    private fun sendSmsToFlutter(message: String,receivedTime: Long) {
        try {
            val data = mapOf("smsMessage" to message, "receivedTime" to receivedTime)
            // MethodChannel을 사용하여 Flutter로 메시지를 보냅니다.
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("refresh", message)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("smsReceived", data)

        } catch (e: Exception) {
            Log.e("SmsWorker", "Error sending SMS to Flutter", e)
        }
    }
}
