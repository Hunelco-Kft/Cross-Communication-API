package com.hunelco.cross_com_api.src.managers.ble

import android.annotation.SuppressLint
import android.bluetooth.*
import android.bluetooth.BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
import android.content.Context
import com.hunelco.cross_com_api.src.managers.DeviceNotFoundException
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.ble.profiles.GeneralProfile
import com.hunelco.cross_com_api.src.models.BleDevice
import com.hunelco.cross_com_api.src.utils.MessageUtils
import io.flutter.plugins.Pigeon
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import no.nordicsemi.android.ble.BleManager
import no.nordicsemi.android.ble.BleServerManager
import no.nordicsemi.android.ble.ConnectionPriorityRequest
import no.nordicsemi.android.ble.MtuRequest
import no.nordicsemi.android.ble.observer.ServerObserver
import timber.log.Timber
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

/*
 * Manages the entire GATT service, declaring the services and characteristics on offer
 */
@SuppressLint("MissingPermission")
class GattServerManager private constructor(private val context: Context) :
    BleServerManager(context), ServerObserver {
    var config: Pigeon.Config? = null

    private val sessionManager = SessionManager.getInstance()

    private val notifCharacteristic = characteristic(
        GeneralProfile.NOTIF_CHARACTERISTIC,
        BluetoothGattCharacteristic.PROPERTY_NOTIFY or
                BluetoothGattCharacteristic.PROPERTY_INDICATE,
        BluetoothGattCharacteristic.PERMISSION_READ,
        description("Notifications", false)
    )

    private val readCharacteristic = characteristic(
        GeneralProfile.READ_CHARACTERISTIC,
        BluetoothGattCharacteristic.PROPERTY_READ,
        BluetoothGattCharacteristic.PERMISSION_READ,
        description("Reads", false)
    )
    private val writeCharacteristic = characteristic(
        GeneralProfile.WRITE_CHARACTERISTIC,
        BluetoothGattCharacteristic.PROPERTY_WRITE,
        BluetoothGattCharacteristic.PERMISSION_WRITE,
        description("Writes", false)
    )
    private val generalGattService = service(
        GeneralProfile.SERVICE, notifCharacteristic,
        readCharacteristic, writeCharacteristic
    )

    private val gattServices = mutableListOf(generalGattService)

    private val advertisingUUIDs = listOf(GeneralProfile.SERVICE)
    private val reqAdvData = BleAdvertiser.advertiseData(advertisingUUIDs)
    private val reqAdvSettings = BleAdvertiser.settings()

    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val bleAdvertiser = bluetoothAdapter.bluetoothLeAdvertiser

    private val bleAdvertiseCallback = BleAdvertiser.Callback(context, null)

    //Coroutine Job and Coroutine Scope
    private val coroutineJob = Job()
    private val coroutineScope = CoroutineScope(Dispatchers.Main + coroutineJob)

    init {
        sessionManager.verifiedDevice.observeForever { verifiedDevice ->
            if (verifiedDevice != null && config!!.allowMultipleVerifiedDevice == false) {
                val connections = sessionManager.getConnections<BleDevice>()
                for (connection in connections) {
                    if (connection.id != verifiedDevice.id) {
                        try {
                            Timber.i("Disconnecting connection (${connection.id}) because it is not verified...")
                            connection.device.disconnect().enqueue()

                            coroutineScope.launch { sessionManager.removeConnection(connection.id) }
                        } catch (ex: Exception) {
                            Timber.e(ex, "Couldn't disconnect from device: ${connection.id}")
                        }
                    }
                }
            }
        }
    }

    override fun initializeServer(): MutableList<BluetoothGattService> {
        bluetoothAdapter.name = config!!.name

        setServerObserver(this)
        return gattServices
    }

    override fun log(priority: Int, message: String) = Timber.log(priority, message)

    override fun onServerReady() = Timber.i("Gatt server ready.")

    override fun onDeviceConnectedToServer(device: BluetoothDevice) {
        val conn = ServerConnection().apply {
            useServer(this@GattServerManager)
        }
        val bleConn = BleDevice(device.address, conn)

        if (!config!!.allowMultipleVerifiedDevice!! && sessionManager.hasVerifiedDevice()) {
            Timber.i("Device (${device.name}) not allowed to connect.")
            bleConn.device.disconnect().enqueue()
        } else {
            conn.connect(device).enqueue()
            coroutineScope.launch {
                sessionManager.addConnection(bleConn, Pigeon.Provider.gatt)
                Timber.i("Device connected ${device.address} via GATT Server.")
            }
        }
    }

    override fun onDeviceDisconnectedFromServer(device: BluetoothDevice) {
        // The device has disconnected. Forget it and disconnect.
        coroutineScope.launch {
            Timber
            val removedConn = sessionManager.removeCastedConnection<BleDevice>(device.address)
            removedConn?.device?.disconnect()?.enqueue()
            Timber.i("Device disconnected ${device.address}")
        }
    }

    suspend fun startAdvertise() {
        return suspendCoroutine { continuation ->
            bleAdvertiseCallback.continuation = continuation
            bleAdvertiser.startAdvertising(reqAdvSettings, reqAdvData, bleAdvertiseCallback)
            Timber.i("Start advertising - GattServerManager")
        }
    }

    fun stopAdvertise() {
        bleAdvertiser.stopAdvertising(bleAdvertiseCallback)
        Timber.i("Stop advertising - GattServerManager")
    }

    suspend fun sendMessage(deviceId: String, data: String) {
        val device = sessionManager.getCastedConnection<BleDevice>(deviceId)
            ?: throw DeviceNotFoundException(deviceId, Pigeon.Provider.gatt)

        device.device.sendMessage(MessageUtils.addEOF(data))
    }

    inner class ServerConnection : BleManager(context) {
        init {
            setWriteCallback(writeCharacteristic)
                .merge(LargeDataMerger(GeneralProfile.MAX_MSG_SIZE, this))
                .with { device, data ->
                    coroutineScope.launch {
                        sessionManager.onMessage(
                            device.address, Pigeon.Provider.gatt, data.getStringValue(0) ?: ""
                        )
                    }
                }

            requestConnectionPriority(ConnectionPriorityRequest.CONNECTION_PRIORITY_HIGH).enqueue()
        }

        override fun getGattCallback() = GattCallback()

        override fun log(priority: Int, message: String) = Timber.log(priority, message)

        suspend fun sendMessage(data: String) {
            return suspendCoroutine { continuation ->
                beginAtomicRequestQueue().apply {
                    add(sendIndication(notifCharacteristic, "".toByteArray()))
                    add(waitForRead(readCharacteristic, data.toByteArray()).split())
                    done {
                        Timber.i("SEND MESSAGE - OKKKK 2")
                        Timber.d("Data ($data) sent successfully to device: ${it.address}")
                        continuation.resume(Unit)
                    }
                    fail { device, _ ->
                        Timber.i("SEND MESSAGE - NOKKKK 2")
                        Timber.e("Data ($data) sent failed to device ${device.address}")
                        continuation.resumeWithException(Exception("Data ($data) sent failed to device ${device.address}"))
                    }
                }.enqueue()
            }
        }

        protected inner class GattCallback : BleManager.BleManagerGattCallback() {

            override fun isRequiredServiceSupported(gatt: BluetoothGatt) = true

            override fun onServicesInvalidated() {}
        }
    }

    companion object {
        @SuppressLint("StaticFieldLeak")
        private lateinit var instance: GattServerManager

        fun getInstance(context: Context): GattServerManager {
            if (!Companion::instance.isInitialized) {
                instance = GattServerManager(context.applicationContext)
            }

            return instance
        }
    }
}