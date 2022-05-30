package com.hunelco.cross_com_api.src.managers

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.models.BleDevice
import com.hunelco.cross_com_api.src.models.ConnectedDevice
import com.hunelco.cross_com_api.src.models.DataPayload
import com.hunelco.cross_com_api.src.models.VerificationRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class SessionManager private constructor() {
    private val _connections = mutableMapOf<String, ConnectedDevice<*>>()
    val connections: Map<String, ConnectedDevice<*>>
        get() = _connections

    private var connectionCallback: Pigeon.ConnectionCallbackApi? = null
    private var communicationCallback: Pigeon.CommunicationCallbackApi? = null
    private var discoveryCallbackApi: Pigeon.DiscoveryCallbackApi? = null
    private var verificationCallbackApi: Pigeon.DeviceVerificationCallbackApi? = null

    val verificationCode = MutableLiveData<String>()

    private val _verifiedDevice = MutableLiveData<ConnectedDevice<*>?>()
    val verifiedDevice: LiveData<ConnectedDevice<*>?>
        get() = _verifiedDevice

    private val _verificationFailed = MutableLiveData<ConnectedDevice<*>?>()
    val verificationFailed: LiveData<ConnectedDevice<*>?>
        get() = _verificationFailed

    fun setVerifiedDevice(deviceId: String?) {
        _verifiedDevice.value = getConnection(deviceId ?: "")
    }

    private val _msgLiveData = MutableLiveData<Pigeon.DataMessage>()
    val msgLiveData: LiveData<Pigeon.DataMessage>
        get() = _msgLiveData


    private val gson = Gson()

    fun updateBinaryMessenger(binaryMessenger: BinaryMessenger?) {
        connectionCallback = Pigeon.ConnectionCallbackApi(binaryMessenger)
        communicationCallback = Pigeon.CommunicationCallbackApi(binaryMessenger)
        discoveryCallbackApi = Pigeon.DiscoveryCallbackApi(binaryMessenger)
        verificationCallbackApi = Pigeon.DeviceVerificationCallbackApi(binaryMessenger)
    }

    fun getConnection(id: String): ConnectedDevice<*>? = _connections[id]

    inline fun <reified T : ConnectedDevice<*>> getConnections(): List<T> {
        val castedConnections = mutableListOf<T>()
        for (conn in connections) {
            if (conn.value is T)
                castedConnections.add(conn.value as T)
        }

        return castedConnections
    }

    fun removeConnection(id: String): ConnectedDevice<*>? {
        Timber.i("REMOVE CONN - ${_verifiedDevice.value?.id} - $id")
        if (_verifiedDevice.value?.id == id) _verifiedDevice.value = null

        val conn = _connections.remove(id)
        if (conn != null) {
            if (id == _verifiedDevice.value?.id)
                _verifiedDevice.value = null

            val connectedDevice = Pigeon.ConnectedDevice.Builder()
                .setDeviceId(conn.id)
                .setProvider(if (conn is BleDevice) Pigeon.Provider.gatt else Pigeon.Provider.nearby)
                .build()

            connectionCallback?.onDeviceDisconnected(connectedDevice) {}
        }

        return conn
    }

    inline fun <reified T : ConnectedDevice<*>> getCastedConnection(id: String): T? {
        val entity = getConnection(id)
        if (entity != null && entity is T)
            return entity

        return null
    }

    fun <T : ConnectedDevice<*>> addConnection(conn: T, provider: Pigeon.Provider) {
        _connections[conn.id] = conn

        val connectedDevice = Pigeon.ConnectedDevice.Builder()
            .setDeviceId(conn.id)
            .setProvider(provider)
            .build()

        connectionCallback?.onDeviceConnected(connectedDevice) { }
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

            _msgLiveData.value = dataMsg
            if (dataPayload.endpoint == ENDPOINT_VERIFICATION) {
                verifyDevice(deviceId, provider, dataPayload)
                return
            }

            communicationCallback?.onMessageReceived(dataMsg) {}
        } catch (ex: Exception) {
            Timber.w(ex, "Couldn't serialize message. Msg: $data")
            communicationCallback?.onRawMessageReceived(deviceId, data) {}
        }
    }

    fun onDeviceDiscovered(deviceId: String, deviceName: String) {
        Timber.i("Nerby Endpoint discovered -> SessionManager: $deviceId ${discoveryCallbackApi == null}")
        discoveryCallbackApi!!.onDeviceDiscovered(deviceId, deviceName) { }
    }

    fun onDeviceLost(deviceId: String) {
        discoveryCallbackApi?.onDeviceLost(deviceId) {}
    }

    private fun verifyDevice(deviceId: String, provider: Pigeon.Provider, payload: DataPayload)
            : Boolean {
        try {
            val request = gson.fromJson(payload.data, VerificationRequest::class.java)
            if (request.code == verificationCode.value) {
                val verifiedConnection = Pigeon.ConnectedDevice.Builder()
                    .setDeviceId(deviceId)
                    .setProvider(provider)
                    .build()

                val devRequest = Pigeon.DeviceVerificationRequest.Builder()
                    .setVerificationCode(request.code)
                    .setArgs(request.args)
                    .build()

                _verifiedDevice.value = getConnection(deviceId)
                verificationCallbackApi?.onDeviceVerified(verifiedConnection, devRequest) {}
                return true
            }
        } catch (ex: Exception) {
            Timber.e(ex, "Verification process failed.")
        }

        _verificationFailed.value = getConnection(deviceId)
        return false
    }

    companion object {
        const val ENDPOINT_VERIFICATION = "/verifyDevice"
        const val ENDPOINT_CLS = "/cls"

        private lateinit var instance: SessionManager

        fun getInstance(): SessionManager {
            if (!::instance.isInitialized) {
                instance = SessionManager()
            }

            return instance
        }
    }
}