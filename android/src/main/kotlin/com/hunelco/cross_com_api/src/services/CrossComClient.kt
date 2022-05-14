package com.hunelco.cross_com_api.src.services

import android.content.Context
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.nearby.NearbyClientManager
import com.hunelco.cross_com_api.src.models.DataPayload
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
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

    override fun startDiscovery(result: Pigeon.Result<Void>) {
        if (isDiscovering.get()) return result.success(v())

        coroutineScope.launch {
            try {
                client.startDiscovery()
                result.success(v())
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun stopDiscovery(result: Pigeon.Result<Void>) {
        if (!isDiscovering.get()) return result.success(v())

        coroutineScope.launch {
            try {
                client.stopDiscovery()
                result.success(v())
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun sendMessage(
        id: String, endpoint: String, payload: String,
        result: Pigeon.Result<Void>
    ) {
        val dataPayload = DataPayload(endpoint, payload)
        val serializedPayload = gson.toJson(dataPayload, DataPayload::class.java)

        coroutineScope.launch {
            try {
                client.sendMessage(id, serializedPayload)
                result.success(v())
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    override fun sendMessageToVerifiedDevice(
        endpoint: String,
        data: String,
        result: Pigeon.Result<Void>
    ) {
        val verifiedDeviceId = sessionManager.verifiedDevice.value?.id
            ?: return result.success(v())
        return sendMessage(verifiedDeviceId, endpoint, data, result)
    }

    fun updateBinaryMessenger(messenger: BinaryMessenger) {
        client.updateBinaryMessenger(messenger)
        Pigeon.DiscoveryApi.setup(messenger, this)
        Pigeon.CommunicationApi.setup(messenger, this)
    }

    fun stopClient() = client.stopClient()

    private fun v() = Void.TYPE.newInstance()
}