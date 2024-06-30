package com.example.phishingblock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val bundle = intent.extras
            val messages: Array<SmsMessage?>
            var strMessage = ""

            if (bundle != null) {
                // SMS 메시지를 추출합니다.
                val pdus = bundle["pdus"] as Array<*>
                messages = arrayOfNulls(pdus.size)

                for (i in pdus.indices) {
                    messages[i] = SmsMessage.createFromPdu(pdus[i] as ByteArray)
                    strMessage += "SMS from ${messages[i]?.originatingAddress}"
                    strMessage += " : ${messages[i]?.messageBody}"
                    strMessage += "\n"
                }

                Log.d("SmsReceiver", strMessage)

                // 추가 데이터 수집 예시: 수신 시간
                val receivedTime = System.currentTimeMillis()
                // WorkManager를 통해 백그라운드 작업을 실행합니다.
                try {
                    val data = Data.Builder()
                        .putString("smsMessage", strMessage) // SMS 메시지를 Data 객체에 담습니다.
                        .putLong("receivedTime", receivedTime) // 추가 데이터 (예: 수신 시간)를 Data 객체에 담습니다.
                        .build()

                    val workRequest = OneTimeWorkRequest.Builder(SmsWorker::class.java)
                        .setInputData(data) // Data 객체를 WorkRequest에 설정합니다.
                        .build()

                    WorkManager.getInstance(context).enqueue(workRequest) // WorkRequest를 큐에 추가하여 실행합니다.
                } catch (e: Exception) {
                    Log.e("SmsReceiver", "Error enqueuing work", e)
                }
            }
        }
    }
}
