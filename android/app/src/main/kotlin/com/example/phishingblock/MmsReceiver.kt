package com.example.phishingblock
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.util.Log

class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.WAP_PUSH_RECEIVED") {
            val bundle = intent.extras
            if (bundle != null) {
                try {
                    val uri = Uri.parse("content://mms")
                    val projection = arrayOf("_id")
                    context.contentResolver.query(uri, projection, null, null, "date DESC")?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val id = cursor.getString(cursor.getColumnIndexOrThrow("_id"))
                            val partUri = Uri.parse("content://mms/part")
                            val partCursor = context.contentResolver.query(partUri, null, "mid=$id", null, null)
                            if (partCursor != null) {
                                while (partCursor.moveToNext()) {
                                    val partId = partCursor.getString(partCursor.getColumnIndexOrThrow("_id"))
                                    val type = partCursor.getString(partCursor.getColumnIndexOrThrow("ct"))
                                    if ("text/plain" == type) {
                                        val data = partCursor.getString(partCursor.getColumnIndexOrThrow("_data"))
                                        val body: String
                                        body = if (data != null) {
                                            getMmsText(context, partId)
                                        } else {
                                            partCursor.getString(partCursor.getColumnIndexOrThrow("text"))
                                        }
                                        Log.d("MmsReceiver", "MMS Body: $body")
                                    }
                                }
                                partCursor.close()
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.e("MmsReceiver", "Exception in MmsReceiver", e)
                }
            }
        }
    }

    private fun getMmsText(context: Context, id: String): String {
        val partUri = Uri.parse("content://mms/part/$id")
        val sb = StringBuilder()
        context.contentResolver.openInputStream(partUri)?.use { inputStream ->
            val buffer = ByteArray(256)
            while (true) {
                val len = inputStream.read(buffer)
                if (len == -1) {
                    break
                }
                sb.append(String(buffer, 0, len))
            }
        }
        return sb.toString()
    }
}
