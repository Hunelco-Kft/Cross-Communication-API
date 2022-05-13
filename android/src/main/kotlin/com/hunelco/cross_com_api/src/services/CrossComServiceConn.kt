package com.hunelco.cross_com_api.src.services

import android.content.ComponentName
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon

interface CommunicationAPI {
    fun onSetup(
        config: Pigeon.ServerConfig,
        binaryMessenger: BinaryMessenger
    )
}

class CrossComServiceConn(
    var config: Pigeon.ServerConfig,
    private val binaryMessenger: BinaryMessenger
) : ServiceConnection {
    private var binding: CommunicationAPI? = null

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        binding = service as? CommunicationAPI
        binding?.onSetup(config, binaryMessenger)
    }

    override fun onServiceDisconnected(p0: ComponentName?) {
        binding = null
    }
}