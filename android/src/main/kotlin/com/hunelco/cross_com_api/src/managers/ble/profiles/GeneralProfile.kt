package com.hunelco.cross_com_api.src.managers.ble.profiles

import java.util.*

object GeneralProfile {
    val NOTIF_CHARACTERISTIC: UUID = UUID.fromString("00002222-0000-1000-8000-00805F9B34FA")
    val READ_CHARACTERISTIC: UUID = UUID.fromString("00002222-0000-1000-8000-00805F9B34FB")
    val WRITE_CHARACTERISTIC: UUID = UUID.fromString("00002222-0000-1000-8000-00805F9B34FC")

    val SERVICE: UUID = UUID.fromString("00001111-0000-1000-8000-00805F9B34FB")

    const val MAX_MSG_SIZE = 500 * 1024 * 1024 // Max 500 MB
}