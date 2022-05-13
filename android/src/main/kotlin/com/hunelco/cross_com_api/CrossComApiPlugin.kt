package com.hunelco.cross_com_api

import android.content.Context
import android.content.Intent
import android.view.WindowManager
import com.hunelco.cross_com_api.src.services.CrossComService
import com.hunelco.cross_com_api.src.services.CrossComServiceConn
import com.hunelco.cross_com_api.src.utils.NotificationUtils
import com.hunelco.cross_com_api.src.utils.PermissionHelper
import io.flutter.BuildConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.Pigeon
import timber.log.Timber
import kotlin.system.exitProcess

/** CrossComApiPlugin */
class CrossComApiPlugin : FlutterPlugin, ActivityAware, Pigeon.ServerApi {
    private var binding: ActivityPluginBinding? = null
    private var binaryMessenger: BinaryMessenger? = null

    private var permissionHelper: PermissionHelper? = null

    private var serviceConnection: CrossComServiceConn? = null

    private lateinit var intent: Intent

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (BuildConfig.DEBUG) Timber.plant(Timber.DebugTree())

        Pigeon.ServerApi.setup(binding.binaryMessenger, this)
        binaryMessenger = binding.binaryMessenger
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        NotificationUtils.createChannels(binding.activity)
        intent = Intent(binding.activity, CrossComService::class.java)

        permissionHelper = PermissionHelper(binding.activity)
        permissionHelper!!.let {
            binding.addActivityResultListener(it)
            binding.addRequestPermissionsResultListener(it)
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onDetachedFromActivity() {
        permissionHelper?.let {
            binding?.removeRequestPermissionsResultListener(it)
            binding?.removeActivityResultListener(it)
        }

        binding = null
    }

    override fun onDetachedFromEngine(pluginBinding: FlutterPlugin.FlutterPluginBinding) {
        if (serviceConnection != null) binding?.activity?.unbindService(serviceConnection!!)

        permissionHelper = null
        exitProcess(0)
    }

    override fun startServer(config: Pigeon.ServerConfig) {
        if (permissionHelper?.hasAllPermissions() != true) {
            permissionHelper?.requestAllPermissions()
            return
        }

        val activity = binding!!.activity
        activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        val serviceConn = CrossComServiceConn(config, binaryMessenger!!)
        serviceConn.config = config

        if (binding?.activity?.bindService(intent, serviceConn, Context.BIND_AUTO_CREATE) == true)
            serviceConnection = serviceConn
    }

    override fun stopServer() {
        binding?.activity?.let { activity ->
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            activity.stopService(intent)
        }

        serviceConnection = null
    }
}
