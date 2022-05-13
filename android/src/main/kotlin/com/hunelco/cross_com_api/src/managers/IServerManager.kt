package com.hunelco.cross_com_api.src.managers

import io.flutter.plugins.Pigeon

interface IServerManager {
    var config: Pigeon.ServerConfig?

    suspend fun startAdvertise()

    suspend fun stopAdvertise()

    suspend fun sendMessage(deviceId: String, data: String)
}
