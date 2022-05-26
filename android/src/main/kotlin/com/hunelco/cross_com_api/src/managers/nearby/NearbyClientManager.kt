package com.hunelco.cross_com_api.src.managers.nearby

import android.content.Context
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*
import com.hunelco.cross_com_api.src.managers.DeviceNotFoundException
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.nearby.profiles.GeneralNearbyProfile
import com.hunelco.cross_com_api.src.models.NearbyDevice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

open class NearbyClientManager(context: Context) : Pigeon.ConnectionApi {
    lateinit var config: Pigeon.Config

    protected val sessionManager = SessionManager.getInstance()
    protected val connectionsClient = Nearby.getConnectionsClient(context)

    private val internalDevices = mutableListOf<NearbyDevice>()
    private val isDiscovering = AtomicBoolean(false)

    protected val connectionCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            if (!config.allowMultipleVerifiedDevice!! && sessionManager.hasVerifiedDevice()) {
                Timber.i("Device connection rejeceted ${connectionInfo.endpointName} via Nearby Server.")
                connectionsClient.rejectConnection(endpointId)
            } else {
                Timber.d("Device connecting ${connectionInfo.endpointName} via Nearby Server.")
                internalDevices.add(NearbyDevice(endpointId, connectionInfo))
                connectionsClient.acceptConnection(endpointId, payloadCallback)
            }
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            Timber.i("Device (${endpointId}) - ${result.status.isSuccess} - ${result.status.statusCode}.")
            if (result.status.isSuccess) {
                val device = internalDevices.find { it.id == endpointId } ?: return
                sessionManager.addConnection(device, Pigeon.Provider.nearby)
                Timber.i("Device (${device.id}) connected via Nearby Server.")
            } else {
                val entity = internalDevices.find { it.id == endpointId }
                if (entity != null) internalDevices.remove(entity)
            }
        }

        override fun onDisconnected(endpointId: String) {
            val device = internalDevices.find { it.id == endpointId } ?: return
            internalDevices.remove(device)
            sessionManager.removeCastedConnection<NearbyDevice>(endpointId)
            Timber.i("Device (${device.id}) disconnected from Nearby Server.")
        }
    }
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

    private val discoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: DiscoveredEndpointInfo) {
            Timber.i("Nearby Endpoint discovered: $endpointId")
            sessionManager.onDeviceDiscovered(endpointId, info.endpointName)
        }

        override fun onEndpointLost(endpointId: String) {
            Timber.i("Nearby Endpoint lost: $endpointId")
            sessionManager.onDeviceLost(endpointId)
        }
    }

    override fun connect(
        endpointId: String,
        name: String,
        result: Pigeon.Result<Pigeon.ConnectedDevice>
    ) {
        connectionsClient.requestConnection(name, endpointId, connectionCallback)
            .addOnSuccessListener {
                Timber.i("Connected to $endpointId")
                val device = Pigeon.ConnectedDevice.Builder()
                    .setDeviceId(endpointId)
                    .setProvider(Pigeon.Provider.nearby)
                    .build()

                result.success(device)
            }
            .addOnFailureListener {
                Timber.i("Connection failed to $endpointId")
                result.error(it)
            }
    }

    override fun disconnect(endpointId: String, result: Pigeon.Result<Long>) {
        connectionsClient.disconnectFromEndpoint(endpointId)
        Timber.i("Disconnected from $endpointId")
        result.success(0)
    }

    fun reset() {
        stopClient()
    }

    suspend fun startDiscovery() {
        if (isDiscovering.get()) return

        val settings = DiscoveryOptions.Builder()
            .setStrategy(getStrategy(config.strategy!!))
            .build()

        return suspendCoroutine { continuation ->
            connectionsClient
                .startDiscovery(GeneralNearbyProfile.SERVICE_ID, discoveryCallback, settings)
                .addOnSuccessListener {
                    Timber.i("Nearby discovery started successfully.")
                    isDiscovering.set(true)
                    continuation.resume(Unit)
                }
                .addOnFailureListener {
                    Timber.e("Nearby discovery start failed.")
                    isDiscovering.set(false)
                    continuation.resumeWithException(it)
                }
        }
    }

    fun stopDiscovery() {
        if (!isDiscovering.get()) return

        connectionsClient.stopDiscovery()
        connectionsClient.stopAllEndpoints()
        isDiscovering.set(false)
    }

    suspend fun sendMessage(deviceId: String, data: String) {
        sessionManager.getCastedConnection<NearbyDevice>(deviceId)
            ?: throw DeviceNotFoundException(deviceId, Pigeon.Provider.nearby)

        return suspendCoroutine { continuation ->
            connectionsClient.sendPayload(deviceId, Payload.fromBytes(data.toByteArray()))
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

    fun updateBinaryMessenger(messenger: BinaryMessenger?) {
        sessionManager.updateBinaryMessenger(messenger)
        Pigeon.ConnectionApi.setup(messenger, this)
    }

    fun stopClient() {
        connectionsClient.stopDiscovery()
        connectionsClient.stopAllEndpoints()
    }

    companion object {
        fun getStrategy(strategy: Pigeon.NearbyStrategy): Strategy {
            return when (strategy) {
                Pigeon.NearbyStrategy.p2pCluster -> Strategy.P2P_CLUSTER
                Pigeon.NearbyStrategy.p2pStar -> Strategy.P2P_STAR
                Pigeon.NearbyStrategy.p2pPointToPoint -> Strategy.P2P_POINT_TO_POINT
            }
        }
    }
}