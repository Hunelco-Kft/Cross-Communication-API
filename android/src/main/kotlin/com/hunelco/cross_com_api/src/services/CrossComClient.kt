package com.hunelco.cross_com_api.src.services

import android.content.Context
import androidx.lifecycle.Observer
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.nearby.NearbyClientManager
import com.hunelco.cross_com_api.src.models.DataPayload
import com.hunelco.cross_com_api.src.models.VerificationRequest
import com.hunelco.cross_com_api.src.models.VerificationResponse
import io.flutter.plugin.common.BinaryMessenger
import com.flutter.pigeon.Pigeon
import com.google.android.gms.common.api.ApiException
import kotlinx.coroutines.*
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean

class CrossComClient(context: Context, config: Pigeon.Config) :
    Pigeon.DiscoveryApi, Pigeon.CommunicationApi, Pigeon.DeviceVerificationApi {
    private val client = NearbyClientManager(context.applicationContext)

    private val gson = Gson()
    private val sessionManager = SessionManager.getInstance()

    //Coroutine Job and Coroutine Scope
    private val coroutineJob = Job()
    private val coroutineScope = CoroutineScope(Dispatchers.IO + coroutineJob)

    init {
        client.config = config
    }

    override fun startDiscoveryAsync(result: Pigeon.Result<Long>) {
        coroutineScope.launch {
            try {
                client.startDiscovery()
                result.success(0)
            } catch (ex: Exception) {
                result.error(ex)
                /*
                Timber.i("startDiscoveryAsync - Android - e: ${ex.javaClass.canonicalName}")
                if(ex is ApiException && ex.statusCode == 8002){
                    restartDiscoveryAsync(result)
                } else {
                    result.error(ex)
                }
                 */
            }
        }
    }

    override fun stopDiscoveryAsync(result: Pigeon.Result<Long>) {
        coroutineScope.launch {
            try {
                client.stopDiscovery()
                result.success(0)
            } catch (ex: Exception) {
                result.error(ex)
            }
        }
    }

    private fun restartDiscoveryAsync(result: Pigeon.Result<Long>) {
        coroutineScope.launch {
            try {
                client.stopDiscovery()
                startDiscoveryAsync(result)
            } catch (ex: Exception) {
                Timber.i("stopDiscoveryAsync - Android - e: ${ex}")
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
        val verifiedDeviceId = sessionManager.verifiedDevice.value?.id
            ?: return result.success(0)
        return sendMessage(verifiedDeviceId, endpoint, data, result)
    }

    override fun requestDeviceVerification(
        deviceId: String,
        request: Pigeon.DeviceVerificationRequest,
        result: Pigeon.Result<Map<String, String>>
    ) {
        coroutineScope.launch {
            val verificationRequest =
                VerificationRequest(request.verificationCode!!, request.args ?: emptyMap())
            val serializedRequest =
                gson.toJson(verificationRequest, VerificationRequest::class.java)
            val dataPayload = DataPayload(SessionManager.ENDPOINT_VERIFICATION, serializedRequest)
            val serializedPayload = gson.toJson(dataPayload, DataPayload::class.java)

            val observer = MessageObserver()
            withContext(Dispatchers.Main) {
                sessionManager.msgLiveData.observeForever(observer)
            }

            try {
                client.sendMessage(deviceId, serializedPayload)
                withTimeout(3000) { observer.wait() }
            } catch (e: TimeoutCancellationException) {
                observer.exception = e
            } finally {
                withContext(Dispatchers.Main) {
                    sessionManager.msgLiveData.removeObserver(observer)
                }
                if (observer.exception != null) result.error(observer.exception)
                else result.success(observer.response!!)
            }
        }
    }

    fun updateBinaryMessenger(messenger: BinaryMessenger, reset: Boolean = false) {
        if (reset) sessionManager.setVerifiedDevice(null)

        client.updateBinaryMessenger(messenger)
        Pigeon.DiscoveryApi.setup(messenger, this@CrossComClient)
        Pigeon.CommunicationApi.setup(messenger, this@CrossComClient)
        Pigeon.DeviceVerificationApi.setup(messenger, this@CrossComClient)
    }

    fun stopClient() = client.stopClient()

    inner class MessageObserver : Observer<Pigeon.DataMessage> {
        var response: Map<String, String>? = null
        var exception: Exception? = null

        override fun onChanged(t: Pigeon.DataMessage) {
            if (t.endpoint == SessionManager.ENDPOINT_VERIFICATION) {
                try {
                    response = gson.fromJson(t.data, VerificationResponse::class.java).args
                    sessionManager.setVerifiedDevice(t.deviceId!!)
                } catch (ex: Exception) {
                    exception = ex
                }
            }
        }

        suspend fun wait() {
            while (response == null && exception == null) {
                delay(10)
            }
        }
    }
}