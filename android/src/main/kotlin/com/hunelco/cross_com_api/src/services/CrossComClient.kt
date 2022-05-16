package com.hunelco.cross_com_api.src.services

import android.content.Context
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.nearby.NearbyClientManager
import com.hunelco.cross_com_api.src.models.DataPayload
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import kotlinx.coroutines.*
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean

class CrossComClient(context: Context, config: Pigeon.Config) :
    Pigeon.DiscoveryApi, Pigeon.CommunicationApi {
    private val client = NearbyClientManager(context.applicationContext)

    private val gson = Gson()
    private val sessionManager = SessionManager.getInstance()

    private val isDiscovering = AtomicBoolean(false)

    //Coroutine Job and Coroutine Scope
    private val coroutineJob = Job()
    private val coroutineScope = CoroutineScope(Dispatchers.IO + coroutineJob)

    init {
        client.config = config
    }

    override fun startDiscovery(result: Pigeon.Result<Long>) {
        if (isDiscovering.get()) return result.success(0)

        coroutineScope.launch {
            try {
                client.startDiscovery()
                isDiscovering.set(true)
                result.success(0)
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun stopDiscovery(result: Pigeon.Result<Long>) {
        if (!isDiscovering.get()) return result.success(0)

        coroutineScope.launch {
            try {
                client.stopDiscovery()
                isDiscovering.set(false)
                result.success(0)
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun sendMessage(
        id: String, endpoint: String, payload: String,
        result: Pigeon.Result<Long>
    ) {
        val dataPayload = DataPayload(endpoint, payload)
        val serializedPayload = gson.toJson(dataPayload, DataPayload::class.java)

        coroutineScope.launch {
            try {
                client.sendMessage(id, serializedPayload)
                result.success(0)
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun sendMessageToVerifiedDevice(
        endpoint: String,
        data: String,
        result: Pigeon.Result<Long>
    ) {
        Timber.d("VERIFIED DEVICE ${sessionManager.verifiedDevice.value}")
        val verifiedDeviceId = sessionManager.verifiedDevice.value?.id
            ?: return result.success(0)
        return sendMessage(verifiedDeviceId, endpoint, data, result)
    }

    fun updateBinaryMessenger(messenger: BinaryMessenger) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                    client.updateBinaryMessenger(messenger)
                    Pigeon.DiscoveryApi.setup(messenger, this@CrossComClient)
                    Pigeon.CommunicationApi.setup(messenger, this@CrossComClient)
                }
            }
    }

    fun stopClient() = client.stopClient()
}