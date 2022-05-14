package com.hunelco.cross_com_api.src.managers.nearby

import android.annotation.SuppressLint
import android.content.Context
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.hunelco.cross_com_api.src.managers.nearby.profiles.GeneralNearbyProfile
import timber.log.Timber
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class NearbyServerManager private constructor(context: Context) : NearbyClientManager(context) {
    suspend fun startAdvertise() {
        val settings = AdvertisingOptions.Builder()
            .setStrategy(getStrategy(config.strategy!!))
            .build()

        return suspendCoroutine { continuation ->
            val name = config.name!!
            connectionsClient.startAdvertising(
                name, GeneralNearbyProfile.SERVICE_ID,
                connectionCallback, settings
            ).addOnSuccessListener {
                Timber.i("Start advertising - NearbyServerManager")
                continuation.resume(Unit)
            }.addOnFailureListener {
                Timber.i("Start advertising failed - NearbyServerManager")
                continuation.resumeWithException(it)
            }
        }
    }

    fun stopAdvertise() {
        connectionsClient.stopAdvertising()
        Timber.i("Stop advertising - NearbyServerManager")
    }

    companion object {
        @SuppressLint("StaticFieldLeak")
        private lateinit var instance: NearbyServerManager

        fun getInstance(context: Context): NearbyServerManager {
            if (!::instance.isInitialized)
                instance = NearbyServerManager(context.applicationContext)

            return instance
        }
    }
}