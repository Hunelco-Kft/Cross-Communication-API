package com.hunelco.cross_com_api.src.managers

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.models.BleDevice
import com.hunelco.cross_com_api.src.models.ConnectedDevice
import com.hunelco.cross_com_api.src.models.DataPayload
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber

class SessionManager private constructor() {
    private val connections = mutableMapOf<String, ConnectedDevice<*>>()

    private var connectionCallback: Pigeon.ConnectionCallbackApi? = null
    private var communicationCallback: Pigeon.CommunicationCallbackApi? = null
    private var discoveryCallbackApi: Pigeon.DiscoveryCallbackApi? = null

    private val _verifiedDevice = MutableLiveData<ConnectedDevice<*>?>()
    val verifiedDevice: LiveData<ConnectedDevice<*>?>
        get() = _verifiedDevice

    private val gson = Gson()

    fun updateBinaryMessenger(binaryMessenger: BinaryMessenger?) {
        connectionCallback = Pigeon.ConnectionCallbackApi(binaryMessenger)
        communicationCallback = Pigeon.CommunicationCallbackApi(binaryMessenger)
        discoveryCallbackApi = Pigeon.DiscoveryCallbackApi(binaryMessenger)

        connectionCallback!!.onDeviceConnected(Pigeon.ConnectedDevice.Builder().build()) {
            Timber.i("OKSSSSS")
        }
    }

    fun getConnection(id: String): ConnectedDevice<*>? = connections[id]

    fun removeConnection(id: String): ConnectedDevice<*>? {
        if (_verifiedDevice.value?.id == id) _verifiedDevice.value = null

        val conn = connections.remove(id)
        if (conn != null) {
            val connectedDevice = Pigeon.ConnectedDevice.Builder()
                .setDeviceId(conn.id)
                .setProvider(if (conn is BleDevice) Pigeon.Provider.gatt else Pigeon.Provider.nearby)
                .build()

                connectionCallback?.onDeviceDisconnected(connectedDevice) {}
        }

        return conn
    }

    inline fun <reified T : ConnectedDevice<*>> getCastedConnection(id: String): T? {
        Timber.i("UNCASTED " + getConnection(id) )
        val entity = getConnection(id)
        if (entity != null && entity is T)
            return entity

        return null
    }

    fun <T : ConnectedDevice<*>> addConnection(conn: T, provider: Pigeon.Provider) {
        connections[conn.id] = conn

        val connectedDevice = Pigeon.ConnectedDevice.Builder()
            .setDeviceId(conn.id)
            .setProvider(provider)
            .build()

        connectionCallback?.onDeviceConnected(connectedDevice) { isVerified ->
            Timber.i("VerifiedDevice: ${isVerified} ${conn}");
            if (isVerified) _verifiedDevice.value = conn
        }
    }

    inline fun <reified T : ConnectedDevice<*>> removeCastedConnection(id: String): T? {
        if (getConnection(id) is T) return removeConnection(id) as T

        return null
    }

    fun hasVerifiedDevice() = _verifiedDevice.value != null

    fun onMessage(deviceId: String, provider: Pigeon.Provider, data: String) {
        // Try to convert data back from serialized json to object
        try {
            val dataPayload = gson.fromJson(data, DataPayload::class.java)
            val dataMsg = Pigeon.DataMessage.Builder().apply {
                setDeviceId(deviceId)
                setProvider(provider)
                setData(dataPayload.data)
                setEndpoint(dataPayload.endpoint)
            }.build()

            communicationCallback?.onMessageReceived(dataMsg) {}
        } catch (ex: Exception) {
            Timber.w(ex, "Couldn't serialize message. Msg: $data")
            communicationCallback?.onRawMessageReceived(deviceId, data) {}
        }
    }

    fun onDeviceDiscovered(deviceId: String) {
        Timber.i("Nerby Endpoint discovered -> SessionManager: $deviceId ${discoveryCallbackApi == null}")
        discoveryCallbackApi!!.onDeviceDiscovered(deviceId){
            Timber.i("Nearby - CSUMPA")
        }
    }

    fun onDeviceLost(deviceId: String) {
        discoveryCallbackApi?.onDeviceLost(deviceId){}
    }

    companion object {
        private lateinit var instance: SessionManager

        fun getInstance(): SessionManager {
            if (!::instance.isInitialized) {
                instance = SessionManager()
            }

            return instance
        }
    }
}