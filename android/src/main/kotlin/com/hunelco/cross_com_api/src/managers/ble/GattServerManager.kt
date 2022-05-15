package com.hunelco.cross_com_api.src.managers.ble

import android.annotation.SuppressLint
import android.bluetooth.*
import android.bluetooth.BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
import android.content.Context
import com.hunelco.cross_com_api.src.managers.SessionManager
import com.hunelco.cross_com_api.src.managers.ble.profiles.GeneralProfile
import com.hunelco.cross_com_api.src.models.BleDevice
import io.flutter.plugins.Pigeon
import no.nordicsemi.android.ble.BleManager
import no.nordicsemi.android.ble.BleServerManager
import no.nordicsemi.android.ble.ConnectionPriorityRequest
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

    private val generalGattCharacteristic = characteristic(
        GeneralProfile.CHARACTERISTIC,
        BluetoothGattCharacteristic.PROPERTY_READ or
                BluetoothGattCharacteristic.PROPERTY_WRITE or
                BluetoothGattCharacteristic.PROPERTY_NOTIFY or
                BluetoothGattCharacteristic.PROPERTY_INDICATE,
        BluetoothGattCharacteristic.PERMISSION_READ or BluetoothGattCharacteristic.PERMISSION_WRITE,
        description("General communication characteristic.", false)
    )
    private val generalGattService = service(GeneralProfile.SERVICE, generalGattCharacteristic)

    private val gattServices = mutableListOf(generalGattService)

    private val advertisingUUIDs = listOf(GeneralProfile.SERVICE)
    private val reqAdvData = BleAdvertiser.advertiseData(advertisingUUIDs)
    private val reqAdvSettings = BleAdvertiser.settings()

    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter
    private val bleAdvertiser = bluetoothAdapter.bluetoothLeAdvertiser

    private val bleAdvertiseCallback = BleAdvertiser.Callback(context)

    override fun initializeServer(): MutableList<BluetoothGattService> {
        bluetoothAdapter.name = config!!.name

        setServerObserver(this)
        return gattServices
    }

    override fun log(priority: Int, message: String) = Timber.log(priority, message)

    override fun onServerReady() = Timber.i("Gatt server ready.")

    override fun onDeviceConnectedToServer(device: BluetoothDevice) {
        val bleConn = BleDevice(
            device.address,
            ServerConnection().apply { useServer(this@GattServerManager) })

        if (!config!!.allowMultipleVerifiedDevice!! && sessionManager.hasVerifiedDevice())
            bleConn.device.disconnect().enqueue()
        else {
            Timber.i("Device connected ${device.address} via GATT Server.")
            sessionManager.addConnection(bleConn, Pigeon.Provider.gatt)
        }
    }

    override fun onDeviceDisconnectedFromServer(device: BluetoothDevice) {
        Timber.i("Device disconnected ${device.address}")

        // The device has disconnected. Forget it and disconnect.
        val removedConn = sessionManager.removeCastedConnection<BleDevice>(device.address)
        removedConn?.device?.disconnect()?.enqueue()
    }

    fun startAdvertise() {
        bleAdvertiser.startAdvertising(reqAdvSettings, reqAdvData, bleAdvertiseCallback)
        Timber.i("Start advertising - GattServerManager")
    }

    fun stopAdvertise() {
        bleAdvertiser.stopAdvertising(bleAdvertiseCallback)
        Timber.i("Stop advertising - GattServerManager")
    }

    suspend fun sendMessage(deviceId: String, data: String) {
        val device = sessionManager.getCastedConnection<BleDevice>(deviceId) ?: return
        device.device.sendMessage(data)
    }

    inner class ServerConnection : BleManager(context) {
        init {
            setWriteCallback(generalGattCharacteristic)
                .merge(LargeDataMerger(GeneralProfile.MAX_MSG_SIZE, this))
                .with { device, data ->
                    sessionManager.onMessage(
                        device.address, Pigeon.Provider.gatt, data.getStringValue(0) ?: ""
                    )
                }

            requestConnectionPriority(ConnectionPriorityRequest.CONNECTION_PRIORITY_HIGH)
        }


        override fun getGattCallback() = GattCallback()

        override fun log(priority: Int, message: String) = Timber.log(priority, message)

        suspend fun sendMessage(data: String) {
            return suspendCoroutine { continuation ->
                beginAtomicRequestQueue().apply {
                    add(
                        writeCharacteristic(
                            generalGattCharacteristic, data.toByteArray(),
                            WRITE_TYPE_DEFAULT
                        ).split()
                    )
                    done {
                        Timber.d("Data ($data) sent successfully to device: ${it.address}")
                        continuation.resume(Unit)
                    }
                    fail { device, _ ->
                        Timber.e("Data ($data) sent failed to device ${device.address}")
                        continuation.resumeWithException(Exception("Data ($data) sent failed to device ${device.address}"))
                    }
                }
            }
        }



        protected inner class GattCallback() : BleManager.BleManagerGattCallback() {

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