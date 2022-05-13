package com.hunelco.cross_com_api.src.utils

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

const val CHANNEL_ID_FOREGROUND = "com.hunelco.cross_com_api.foreground"

object NotificationUtils {

    fun createChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channels = mutableListOf(getForegroundServiceChannel())

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannels(channels)
    }

    fun getForegroundServiceNotification(context: Context) =
        NotificationCompat.Builder(context, CHANNEL_ID_FOREGROUND)
            .setContentTitle("Cross Communication API")
            .setContentText("Cross Communication API is running in foreground mode.")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .build()

    @SuppressLint("NewApi")
    private fun getForegroundServiceChannel(): NotificationChannel {
        val name = "Cross Communication API"
        val description = "Cross Communication API is running in foreground mode."
        val importance = NotificationManager.IMPORTANCE_HIGH

        val channel = NotificationChannel(CHANNEL_ID_FOREGROUND, name, importance)
        channel.description = description

        return channel
    }

    fun sendNotification(
        context: Context,
        msg: String,
        channel: String = CHANNEL_ID_FOREGROUND
    ) {
        val builder = NotificationCompat.Builder(context, channel)
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setContentTitle("System Notification")
            .setStyle(NotificationCompat.BigTextStyle().bigText(msg))
            .setAutoCancel(true)
            .setContentText(msg)

        val notification = builder.build()
            .apply {
                // TODO
                defaults = Notification.DEFAULT_ALL
            }

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify((Math.random() * 1000000).toInt(), notification)
    }
}