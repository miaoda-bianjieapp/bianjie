package com.bianjie.ai.bianjie_ai_app

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "com.bianjie.ai.bianjie_ai_app/artifacts"
    private val writeStorageRequestCode = 4107
    private var pendingSave: PendingSave? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImageToGallery" -> {
                    val name = call.argument<String>("name") ?: "bianjie_image.png"
                    val mimeType = call.argument<String>("mimeType") ?: "image/png"
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null || bytes.isEmpty()) {
                        result.error("EMPTY_BYTES", "Image bytes are empty.", null)
                    } else {
                        saveImageWithPermission(name, mimeType, bytes, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun saveImageWithPermission(
        name: String,
        mimeType: String,
        bytes: ByteArray,
        result: MethodChannel.Result
    ) {
        val needsLegacyPermission = Build.VERSION.SDK_INT <= Build.VERSION_CODES.P &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED

        if (needsLegacyPermission) {
            if (pendingSave != null) {
                result.error("SAVE_IN_PROGRESS", "Another image is being saved.", null)
                return
            }
            pendingSave = PendingSave(name, mimeType, bytes, result)
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                writeStorageRequestCode
            )
            return
        }
        completeSave(name, mimeType, bytes, result)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != writeStorageRequestCode) {
            return
        }
        val save = pendingSave ?: return
        pendingSave = null
        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            completeSave(save.name, save.mimeType, save.bytes, save.result)
        } else {
            save.result.error("PERMISSION_DENIED", "Storage permission was denied.", null)
        }
    }

    private fun completeSave(
        name: String,
        mimeType: String,
        bytes: ByteArray,
        result: MethodChannel.Result
    ) {
        try {
            result.success(saveImageToGallery(name, mimeType, bytes))
        } catch (error: Exception) {
            result.error("SAVE_FAILED", error.message, null)
        }
    }

    private fun saveImageToGallery(name: String, mimeType: String, bytes: ByteArray): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, name)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/BianjieAI")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Cannot create image in MediaStore.")
        resolver.openOutputStream(uri)?.use { output ->
            output.write(bytes)
        } ?: throw IllegalStateException("Cannot open image output stream.")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }
        return uri.toString()
    }

    private data class PendingSave(
        val name: String,
        val mimeType: String,
        val bytes: ByteArray,
        val result: MethodChannel.Result
    )
}
