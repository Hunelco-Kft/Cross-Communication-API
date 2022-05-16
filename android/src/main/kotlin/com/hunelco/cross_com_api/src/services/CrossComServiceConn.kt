package com.hunelco.cross_com_api.src.services

import android.content.ComponentName
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon

interface CommunicationAPI {
    fun onSetup(
        config: Pigeon.Config,
        binaryMessenger: BinaryMessenger
    )
}

class CrossComServiceConn(
    var config: Pigeon.Config,
    private val binaryMessenger: BinaryMessenger,
    private val result: Pigeon.Result<Long>? = null
) : ServiceConnection {
    private var binding: CommunicationAPI? = null

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        binding = service as? CommunicationAPI
        binding?.onSetup(config, binaryMessenger)
        result?.success(0)
    }

    override fun onServiceDisconnected(p0: ComponentName?) {
        binding = null
    }
}