package com.hunelco.cross_com_api.src.managers.ble


import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import com.hunelco.cross_com_api.src.utils.NotificationUtils
import timber.log.Timber
import java.util.*
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

object BleAdvertiser {
    class Callback(private val context: Context, var continuation: Continuation<Unit>?) :
        AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Timber.i("LE Advertise started.: ${settingsInEffect?.mode} ${settingsInEffect?.isConnectable}")
            continuation?.resume(Unit)
        }


        override fun onStartFailure(errorCode: Int) {
            NotificationUtils.sendNotification(context, "LE Advertise failed: $errorCode")
            Timber.i("LE Advertise failed: $errorCode")
            continuation?.resumeWithException(IllegalStateException("LE Advertise couldn't start $errorCode"))
        }
    }

    fun settings(): AdvertiseSettings {
        return AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()
    }

    fun advertiseData(serviceUUIDs: List<UUID>): AdvertiseData {
        val builder = AdvertiseData.Builder()
            .setIncludeDeviceName(true)//TODO false???
            .setIncludeTxPowerLevel(false)

        for (serviceUUID in serviceUUIDs)
            builder.addServiceUuid(ParcelUuid(serviceUUID))

        return builder.build()
    }
}