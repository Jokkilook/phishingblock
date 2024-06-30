package com.example.phishingblock

import android.content.ContentResolver;
import android.database.Cursor
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONException;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.jjj.phishingblock/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
             when (call.method) {
                "getSms" -> {
                    val smsList = getSmsMessages()
                    if (smsList != null) {
                        result.success(smsList)
                    } else {
                        result.error("UNAVAILABLE", "SMS not available.", null)
                    }
                }
                "getSmsBySender" -> {
                    val sender = call.argument<String>("sender")
                    val smsList = getSmsMessagesBySender(sender!!)
                    if (smsList != null) {
                        result.success(smsList)
                    } else {
                        result.error("UNAVAILABLE", "SMS not available.", null)
                    }
                }
                "getSentSms" -> {
                    val smsList = getSentSmsMessages()
                    result.success(smsList)
                }
                "getSentSmsByRecipient" -> {
                    val recipient = call.argument<String>("recipient")
                    val smsList = getSentSmsMessagesByRecipient(recipient)
                    result.success(smsList)
                }
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    if (phoneNumber != null && message != null) {
                        sendSms(phoneNumber, message)
                        result.success(null)
                    } else {
                        result.error("UNAVAILABLE", "Phone number or message not available.", null)
                    }
                }
                "callPhoneNumber" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (phoneNumber != null) {
                        callPhoneNumber(phoneNumber)
                        result.success(null)
                    } else {
                        result.error("UNAVAILABLE", "Phone number not available.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    //전화 걸기
    private fun callPhoneNumber(phoneNumber: String) {
        val intent = Intent(Intent.ACTION_CALL)
        intent.data = Uri.parse("tel:$phoneNumber")
        startActivity(intent)
    }

    //메세지 보내기
    private fun sendSms(phoneNumber: String, message: String) {
        val smsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }

    //전체 받은 메세지 가져오기
    private fun getSmsMessages(): String {
        val smsList = JSONArray()
        val cursor: Cursor? = contentResolver.query(Uri.parse("content://sms/inbox"), null, null, null, null)
        cursor?.use {
            while (cursor.moveToNext()) {
                val smsObject = JSONObject()
                smsObject.put("sender", cursor.getString(cursor.getColumnIndexOrThrow("address")))
                smsObject.put("message", cursor.getString(cursor.getColumnIndexOrThrow("body")))
                smsObject.put("date", cursor.getLong(cursor.getColumnIndexOrThrow("date")))
                smsObject.put("isMine", false)
                smsList.put(smsObject)
            }
        }
        return smsList.toString()
    }

    //특정 연락처에게 받은 메세지 가져오기
    private fun getSmsMessagesBySender(sender: String): String {
        val smsList = JSONArray()
        val cursor: Cursor? = contentResolver.query(
            Uri.parse("content://sms/inbox"),
            null,
            "address = ?",
            arrayOf(sender),
            null
        )
        cursor?.use {
            while (cursor.moveToNext()) {
                val smsObject = JSONObject()
                smsObject.put("sender", cursor.getString(cursor.getColumnIndexOrThrow("address")))
                smsObject.put("message", cursor.getString(cursor.getColumnIndexOrThrow("body")))
                smsObject.put("date", cursor.getLong(cursor.getColumnIndexOrThrow("date")))
                smsObject.put("isMine", false)
                smsList.put(smsObject)
            }
        }
        return smsList.toString()
    }

    //내가 보낸 전체 메세지 가져오기
    private fun getSentSmsMessages(): String {
        val smsList = JSONArray()
        val contentResolver: ContentResolver = applicationContext.contentResolver
        val uri = Uri.parse("content://sms/sent")
        val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)

        cursor?.use { c ->
            while (c.moveToNext()) {
                val smsObject = JSONObject()
                smsObject.put("sender", c.getString(c.getColumnIndexOrThrow("address")))
                smsObject.put("message", c.getString(c.getColumnIndexOrThrow("body")))
                smsObject.put("date", c.getLong(c.getColumnIndexOrThrow("date")))
                smsObject.put("isMine", true)
                smsList.put(smsObject)
            }
        }

        return smsList.toString()
    }

    //특정 연락처에 내가 보낸 문자 내역 가져오기
     private fun getSentSmsMessagesByRecipient(recipient: String?): String {
        val smsList = JSONArray()
        val contentResolver: ContentResolver = applicationContext.contentResolver
        val uri = Uri.parse("content://sms/sent")
        val selection = "address = ?"
        val selectionArgs = arrayOf(recipient)
        val cursor: Cursor? = contentResolver.query(uri, null, selection, selectionArgs, null)

        cursor?.use { c ->
            while (c.moveToNext()) {
                val smsObject = JSONObject()
                smsObject.put("sender", c.getString(c.getColumnIndexOrThrow("address")))
                smsObject.put("message", c.getString(c.getColumnIndexOrThrow("body")))
                smsObject.put("date", c.getLong(c.getColumnIndexOrThrow("date")))
                smsObject.put("isMine", true)
                smsList.put(smsObject)
            }
        }

        return smsList.toString()
    }


}
