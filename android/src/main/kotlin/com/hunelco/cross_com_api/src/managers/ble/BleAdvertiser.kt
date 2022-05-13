package com.hunelco.cross_com_api.src.managers.ble


import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import com.hunelco.cross_com_api.src.utils.NotificationUtils
import timber.log.Timber
import java.util.*

object BleAdvertiser {
    class Callback(private val context: Context) : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) =
            Timber.i("LE Advertise started.")

        override fun onStartFailure(errorCode: Int) {
            Timber.i("LE Advertise failed: $errorCode")
            NotificationUtils.sendNotification(context, "LE Advertise failed: $errorCode")
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
            .setIncludeDeviceName(true)
            .setIncludeTxPowerLevel(false)

        for (serviceUUID in serviceUUIDs)
            builder.addServiceUuid(ParcelUuid(serviceUUID))

        return builder.build()
    }
}