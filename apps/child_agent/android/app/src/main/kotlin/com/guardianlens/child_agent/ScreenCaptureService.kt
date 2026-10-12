package com.guardianlens.child_agent

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import java.io.ByteArrayOutputStream

/**
 * Foreground service that owns a MediaProjection session and exposes the latest
 * screen frame as JPEG bytes via [captureJpeg].
 *
 * A foreground service with type mediaProjection is required (Android 10+ and
 * mandatory on Android 14+) because GuardianLens captures frames while the child
 * is using another app, i.e. while our own app is in the background.
 */
class ScreenCaptureService : Service() {

    companion object {
        const val EXTRA_RESULT_CODE = "resultCode"
        const val EXTRA_RESULT_DATA = "resultData"

        private const val CHANNEL_ID = "guardianlens_capture"
        private const val NOTIFICATION_ID = 7311

        @Volatile
        var isRunning = false
            private set

        @Volatile
        private var instance: ScreenCaptureService? = null

        /** Returns the most recent frame as JPEG bytes, or null if not ready. */
        fun captureJpeg(): ByteArray? = instance?.capture()
    }

    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var width = 0
    private var height = 0
    private var density = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundNotification()
        val resultCode = intent?.getIntExtra(EXTRA_RESULT_CODE, 0) ?: 0
        val resultData = intent?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.getParcelableExtra(EXTRA_RESULT_DATA, Intent::class.java)
            } else {
                @Suppress("DEPRECATION") it.getParcelableExtra(EXTRA_RESULT_DATA)
            }
        }
        if (resultData != null && mediaProjection == null) {
            startProjection(resultCode, resultData)
        }
        return START_NOT_STICKY
    }

    private fun startForegroundNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Screen protection",
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("GuardianLens is protecting this device")
            .setContentText("Monitoring on-screen content on the device")
            .setSmallIcon(android.R.drawable.ic_menu_view)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun startProjection(resultCode: Int, data: Intent) {
        val manager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val projection = try {
            manager.getMediaProjection(resultCode, data)
        } catch (error: Exception) {
            stopSelf()
            return
        }
        projection.registerCallback(
            object : MediaProjection.Callback() {
                override fun onStop() {
                    stopSelf()
                }
            },
            Handler(Looper.getMainLooper()),
        )
        mediaProjection = projection

        // Capture at half the screen resolution: enough detail for the 128x128
        // classifier while keeping memory and per-frame cost low.
        val metrics = resources.displayMetrics
        width = (metrics.widthPixels / 2).coerceAtLeast(2)
        height = (metrics.heightPixels / 2).coerceAtLeast(2)
        density = metrics.densityDpi

        imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
        virtualDisplay = projection.createVirtualDisplay(
            "guardianlens-capture",
            width,
            height,
            density,
            0,
            imageReader!!.surface,
            null,
            Handler(Looper.getMainLooper()),
        )

        instance = this
        isRunning = true
    }

    private fun capture(): ByteArray? {
        val reader = imageReader ?: return null
        val image = try {
            reader.acquireLatestImage()
        } catch (error: Exception) {
            null
        } ?: return null
        return try {
            val plane = image.planes[0]
            val buffer = plane.buffer
            val pixelStride = plane.pixelStride
            val rowStride = plane.rowStride
            val rowPadding = rowStride - pixelStride * width
            val padded =
                Bitmap.createBitmap(width + rowPadding / pixelStride, height, Bitmap.Config.ARGB_8888)
            padded.copyPixelsFromBuffer(buffer)
            val frame = if (padded.width == width) {
                padded
            } else {
                Bitmap.createBitmap(padded, 0, 0, width, height).also { padded.recycle() }
            }
            val out = ByteArrayOutputStream()
            frame.compress(Bitmap.CompressFormat.JPEG, 85, out)
            frame.recycle()
            out.toByteArray()
        } catch (error: Exception) {
            null
        } finally {
            image.close()
        }
    }

    override fun onDestroy() {
        isRunning = false
        instance = null
        virtualDisplay?.release()
        imageReader?.close()
        mediaProjection?.stop()
        virtualDisplay = null
        imageReader = null
        mediaProjection = null
        super.onDestroy()
    }
}
