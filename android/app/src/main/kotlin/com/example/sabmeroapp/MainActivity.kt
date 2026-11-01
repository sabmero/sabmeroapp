package com.ecommerce.sabmeroapp

import android.content.ClipData
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Opens Android's own share sheet (WhatsApp, Messenger, SMS, ...).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sabmero/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText", "shareProduct" -> {
                        try {
                            share(
                                call.argument<String>("text") ?: "",
                                call.argument<String>("subject"),
                                call.argument<ByteArray>("image")
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("share_failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun share(text: String, subject: String?, image: ByteArray?) {
        val send = Intent(Intent.ACTION_SEND)
        send.putExtra(Intent.EXTRA_TEXT, text)
        if (subject != null) send.putExtra(Intent.EXTRA_SUBJECT, subject)

        if (image != null && image.isNotEmpty()) {
            // Save the photo in the app cache and share it as a real picture.
            val dir = File(cacheDir, "shared")
            dir.mkdirs()
            val file = File(dir, "product.jpg")
            file.writeBytes(image)
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            send.type = "image/*"
            send.putExtra(Intent.EXTRA_STREAM, uri)
            send.clipData = ClipData.newRawUri("", uri)
            send.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } else {
            send.type = "text/plain"
        }
        startActivity(Intent.createChooser(send, null))
    }
}
