package com.hunelco.cross_com_api.src.services

import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Binder
import android.os.Build
import android.os.IBinder
import com.google.gson.Gson
import com.hunelco.cross_com_api.src.managers.DeviceNotFoundException
import com.hunelco.cross_com_api.src.managers.NoVerifiedDeviceFoundException
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.ble.GattServerManager
import com.hunelco.cross_com_api.src.managers.nearby.NearbyServerManager
import com.hunelco.cross_com_api.src.models.*
import com.hunelco.cross_com_api.src.utils.AlreadyAdvertisingException
import com.hunelco.cross_com_api.src.utils.MessageUtils
import com.hunelco.cross_com_api.src.utils.NotificationUtils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import kotlinx.coroutines.*
import timber.log.Timber
import java.util.concurrent.atomic.AtomicBoolean

const val NOTIFICATION_ID = 101

class CrossComService : Service(), Pigeon.CommunicationApi, Pigeon.AdvertiseApi {
    private var sessionManager = SessionManager.getInstance()

    private var gattManager: GattServerManager? = null
    private var nearbyManager: NearbyServerManager? = null

    private val isAdvertising = AtomicBoolean(false)

    private val gson = Gson()

    private var stateCallbackApi: Pigeon.StateCallbackApi? = null
    private val bluetoothStateObserver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothAdapter.ACTION_STATE_CHANGED) {
                val response = Pigeon.StateResponse.Builder()
                when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)) {
                    BluetoothAdapter.STATE_ON -> {
                        response.setState(Pigeon.State.on)
                        startAdvertise(null, null)
                    }
                    BluetoothAdapter.STATE_OFF -> {
                        stopAdvertise(null)
                        response.setState(Pigeon.State.off)
                    }
                    else -> response.setState(Pigeon.State.unknown)
                }
                stateCallbackApi?.onBluetoothStateChanged(response.build()) {}
            }
        }
    }

    private val connectivityObserver = object : ConnectivityManager.NetworkCallback() {
        private var hasP2PCapability = false

        override fun onCapabilitiesChanged(
            network: Network,
            networkCapabilities: NetworkCapabilities
        ) {
            val connected =
                networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_WIFI_P2P)
            if (connected == hasP2PCapability) return

            hasP2PCapability = connected
            val response = Pigeon.StateResponse.Builder()
            if (connected) {
                startAdvertise(null, null)
                response.setState(Pigeon.State.on)
            } else {
                stopAdvertise(null)
                response.setState(Pigeon.State.off)
            }

            stateCallbackApi?.onWifiStateChanged(response.build()) {}
        }
    }

    //Coroutine Job and Coroutine Scope
    private val coroutineJob = Job()
    private val coroutineScope = CoroutineScope(Dispatchers.IO + coroutineJob)

    init {
        sessionManager.verifiedDevice.observeForever { verifiedDevice ->
            if (verifiedDevice != null) {
                val res = VerificationResponse(verifiedDevice.args ?: emptyMap())
                val serializedResponse = gson.toJson(res, VerificationResponse::class.java)
                sendMessageToVerifiedDevice(
                    SessionManager.ENDPOINT_VERIFICATION, serializedResponse, null
                )
            }
        }

        sessionManager.verificationFailed.observeForever { unverifiedDevice ->
            if (unverifiedDevice != null) {
                val res = CloseResponse(CloseErrorCodes.VERIFICATION_FAILED)
                val serializedResponse = gson.toJson(res, CloseResponse::class.java)
                sendMessageToVerifiedDevice(
                    SessionManager.ENDPOINT_CLS, serializedResponse, null
                )
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notification = NotificationUtils.getForegroundServiceNotification(this)
            startForeground(NOTIFICATION_ID, notification)
        }

        gattManager = GattServerManager.getInstance(this)
        nearbyManager = NearbyServerManager.getInstance(this)

        val blFilter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        registerReceiver(bluetoothStateObserver, blFilter)

        val cm = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
            cm.registerDefaultNetworkCallback(connectivityObserver)
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int) = START_STICKY

    override fun onBind(p0: Intent): IBinder = DataPlane()

    override fun onDestroy() {
        stopAdvertise(null)
        unregisterReceiver(bluetoothStateObserver)

        val cm = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        cm.unregisterNetworkCallback(connectivityObserver)

        super.onDestroy()
    }

    override fun startAdvertise(verificationCode: String?, result: Pigeon.Result<Long>?) {
        if (isAdvertising.get()) {
            result?.error(AlreadyAdvertisingException())
            return
        }

        sessionManager.setVerifiedDevice(null)
        gattManager?.open()
        coroutineScope.launch {
            try {
                gattManager?.startAdvertise()
                nearbyManager?.startAdvertise()

                isAdvertising.set(true)

                withContext(Dispatchers.Main) {
                    if (verificationCode?.isNotEmpty() == true)
                        sessionManager.verificationCode.value = verificationCode

                    Timber.d("Server started, verification code: $verificationCode")
                    result?.success(0)
                }
            } catch (ex: Exception) {
                Timber.e(ex, "Couldn't start Advertising")
                withContext(Dispatchers.Main) {
                    result?.error(ex)
                }
            }
        }
    }

    override fun stopAdvertise(result: Pigeon.Result<Long>?) {
        if (!isAdvertising.get()) {
            result?.success(0)
            return
        }

        coroutineScope.launch {
            try {
                gattManager?.stopAdvertise()
                gattManager?.close()

                nearbyManager?.stopAdvertise()

                isAdvertising.set(false)
                result?.success(0)
            } catch (ex: Exception) {
                result?.error(ex)
            }
        }
    }

    override fun reset(result: Pigeon.Result<Long>?) {
        // TODO
        stopAdvertise(result)
    }

    override fun sendMessage(
        id: String, endpoint: String, payload: String,
        result: Pigeon.Result<Long>?
    ) {
        val dataPayload = DataPayload(endpoint, payload)
        val serializedPayload = gson.toJson(dataPayload, DataPayload::class.java)

        coroutineScope.launch {
            try {
                if (sessionManager.getCastedConnection<BleDevice>(id) != null)
                    gattManager?.sendMessage(id, serializedPayload)

                if (sessionManager.getCastedConnection<NearbyDevice>(id) != null)
                    nearbyManager?.sendMessage(id, serializedPayload)

                result?.success(0)
            } catch (ex: Exception) {
                Timber.e(ex, "Couldn't send message properly")
                result?.error(ex)
            }
        }
    }

    override fun sendMessageToVerifiedDevice(
        endpoint: String,
        data: String,
        result: Pigeon.Result<Long>?
    ) {
        Timber.d("VERIFIED DEVICE ${sessionManager.verifiedDevice.value}")
        val verifiedDeviceId = sessionManager.verifiedDevice.value?.id
            ?: return result?.error(NoVerifiedDeviceFoundException()) ?: Unit
        return sendMessage(verifiedDeviceId, endpoint, data, result)
    }

    /**
     * Functionality available to clients
     */
    private inner class DataPlane : Binder(), CommunicationAPI {
        override fun onSetup(config: Pigeon.Config, binaryMessenger: BinaryMessenger, result: Pigeon.Result<Long>?) {
            gattManager!!.config = config
            nearbyManager!!.config = config
            sessionManager.setVerifiedDevice(null)

            coroutineScope.launch {
                withContext(Dispatchers.Main) {
                    sessionManager.updateBinaryMessenger(binaryMessenger)
                    stateCallbackApi = Pigeon.StateCallbackApi(binaryMessenger)

                    Pigeon.CommunicationApi.setup(binaryMessenger, this@CrossComService)
                    Pigeon.AdvertiseApi.setup(binaryMessenger, this@CrossComService)
                    result?.success(0)
                }
            }
        }
    }
}