package com.hunelco.cross_com_api.src.models

import com.hunelco.cross_com_api.src.managers.ble.GattServerManager

open class BleDevice(id: String, connection: GattServerManager.ServerConnection) :
    ConnectedDevice<GattServerManager.ServerConnection>(id, connection)