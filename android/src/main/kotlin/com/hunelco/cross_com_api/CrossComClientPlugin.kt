package com.hunelco.cross_com_api

import com.hunelco.cross_com_api.src.services.CrossComClient
import com.hunelco.cross_com_api.src.utils.PermissionHelper
import io.flutter.BuildConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber
import kotlin.system.exitProcess

/** CrossComClientPlugin */
class CrossComClientPlugin : FlutterPlugin, ActivityAware, Pigeon.ClientApi {
    private var binding: ActivityPluginBinding? = null
    private var binaryMessenger: BinaryMessenger? = null

    private var permissionHelper: PermissionHelper? = null

    private var crossComClient: CrossComClient? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (BuildConfig.DEBUG) Timber.plant(Timber.DebugTree())

        binaryMessenger = binding.binaryMessenger
        Pigeon.ClientApi.setup(binaryMessenger, this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding

        permissionHelper = PermissionHelper(binding.activity)
        permissionHelper!!.let {
            binding.addActivityResultListener(it)
            binding.addRequestPermissionsResultListener(it)
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromActivity() {
        stopServer()

        permissionHelper?.let {
            binding?.removeRequestPermissionsResultListener(it)
            binding?.removeActivityResultListener(it)
        }
        binding = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        permissionHelper = null
        exitProcess(0)
    }

    override fun startServer(config: Pigeon.Config) {
//        if (permissionHelper?.hasAllPermissions() != true) {
//            permissionHelper?.requestAllPermissions()
//            return
//        }
//
//        val activity = binding!!.activity
//        stopServer()
//
//        crossComClient = CrossComClient(activity, config)
//        crossComClient!!.updateBinaryMessenger(binaryMessenger!!)
    }

    fun stopServer() {
        crossComClient?.stopClient()
        crossComClient = null
    }
}