package com.hunelco.cross_com_api.src.managers

import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.models.BleDevice
import com.hunelco.cross_com_api.src.models.ConnectedDevice
import com.hunelco.cross_com_api.src.models.DataPayload
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber

class SessionManager private constructor(context: Context) {
    private val connections = mutableMapOf<String, ConnectedDevice<*>>()

    private var callback: Pigeon.CommunicationCallbackApi? = null

    private val _verifiedDevice = MutableLiveData<ConnectedDevice<*>?>()
    val verifiedDevice: LiveData<ConnectedDevice<*>?>
        get() = _verifiedDevice

    private val gson = Gson()

    fun updateBinaryMessenger(binaryMessenger: BinaryMessenger) {
        callback = Pigeon.CommunicationCallbackApi(binaryMessenger)
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

            callback?.onDeviceDisconnected(connectedDevice) {}
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
        connections[conn.id] = conn

        val connectedDevice = Pigeon.ConnectedDevice.Builder()
            .setDeviceId(conn.id)
            .setProvider(provider)
            .build()

        callback?.onDeviceConnected(connectedDevice) { isVerified ->
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

            callback?.onMessageReceived(dataMsg) {}
        } catch (ex: Exception) {
            Timber.w(ex, "Couldn't serialize message. Msg: $data")
            callback?.onRawMessageReceived(data) {}
        }
    }

    companion object {
        private lateinit var instance: SessionManager

        fun getInstance(context: Context): SessionManager {
            if (!::instance.isInitialized) {
                instance = SessionManager(context.applicationContext)
            }

            return instance
        }
    }
}