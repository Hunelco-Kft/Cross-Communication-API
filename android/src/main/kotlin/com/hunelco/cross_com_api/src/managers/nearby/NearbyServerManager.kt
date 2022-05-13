package com.hunelco.cross_com_api.src.managers.nearby

import android.annotation.SuppressLint
import android.content.Context
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*
import com.hunelco.cross_com_api.src.managers.IServerManager
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.models.NearbyDevice
import io.flutter.plugins.Pigeon
import timber.log.Timber
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

class NearbyServerManager private constructor(private val context: Context) : IServerManager {
    override var config: Pigeon.ServerConfig? = null

    private val sessionManager = SessionManager.getInstance(context)

    private val connectionClient = Nearby.getConnectionsClient(context)

    private val internalDevices = mutableListOf<NearbyDevice>()

    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            val data = String(payload.asBytes() ?: byteArrayOf())
            Timber.d("Data received from $endpointId. Data: $data")

            sessionManager.onMessage(endpointId, Pigeon.Provider.nearby, data)
        }

        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {
            // Nothing to do here...
        }
    }

    private val connectionCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            if (!config!!.allowMultipleVerifiedDevice!! && sessionManager.hasVerifiedDevice())
                connectionClient.rejectConnection(endpointId)
            else {
                Timber.d("Device connected ${connectionInfo.endpointName} via Nearby Server.")
                internalDevices.add(NearbyDevice(endpointId, connectionInfo))
                connectionClient.acceptConnection(endpointId, payloadCallback)
            }
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            if (result.status.isSuccess) {
                val device = internalDevices.find { it.id == endpointId }
                if (device != null) sessionManager.addConnection(device, Pigeon.Provider.nearby)
            } else {
                val entity = internalDevices.find { it.id == endpointId }
                if (entity != null) internalDevices.remove(entity)
            }
        }

        override fun onDisconnected(endpointId: String) {
            val entity = internalDevices.find { it.id == endpointId }
            if (entity != null) internalDevices.remove(entity)

            sessionManager.removeCastedConnection<NearbyDevice>(endpointId)
        }
    }

    override suspend fun startAdvertise() {
        val settings = AdvertisingOptions.Builder()
            .setStrategy(getStrategy())
            .build()

        return suspendCoroutine { continuation ->
            val name = config!!.name!!
            connectionClient.startAdvertising(name, SERVICE_ID, connectionCallback, settings)
                .addOnSuccessListener {
                    Timber.i("Start advertising - NearbyServerManager")
                    continuation.resume(Unit)
                }
                .addOnFailureListener {
                    Timber.i("Start advertising failed - NearbyServerManager")
                    continuation.resumeWithException(it)
                }
        }
    }

    override suspend fun stopAdvertise() {
        connectionClient.stopAdvertising()
        Timber.i("Stop advertising - NearbyServerManager")
    }

    override suspend fun sendMessage(deviceId: String, data: String) {
        sessionManager.getCastedConnection<NearbyDevice>(deviceId) ?: return

        return suspendCoroutine { continuation ->
            connectionClient.sendPayload(deviceId, Payload.fromBytes(data.toByteArray()))
                .addOnSuccessListener {
                    Timber.i("Message sent - NearbyServerManager")
                    continuation.resume(Unit)
                }
                .addOnFailureListener {
                    Timber.i("Message send failed - NearbyServerManager")
                    continuation.resumeWithException(it)
                }
        }
    }

    private fun getStrategy(): Strategy {
        return when (config!!.strategy) {
            Pigeon.NearbyStrategy.p2pCluster -> Strategy.P2P_CLUSTER
            Pigeon.NearbyStrategy.p2pStar -> Strategy.P2P_STAR
            Pigeon.NearbyStrategy.p2pPointToPoint -> Strategy.P2P_POINT_TO_POINT
            else -> throw IllegalStateException("Strategy ${config!!.strategy} not supported.")
        }
    }

    companion object {
        const val SERVICE_ID = "com.hunelco.cross_com_api"

        @SuppressLint("StaticFieldLeak")
        private lateinit var instance: NearbyServerManager

        fun getInstance(context: Context): NearbyServerManager {
            if (!Companion::instance.isInitialized) {
                instance = NearbyServerManager(context.applicationContext)
            }

            return instance
        }
    }
}