package com.hunelco.cross_com_api.src.utils

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.LocationSettingsStatusCodes
import io.flutter.plugin.common.PluginRegistry
import timber.log.Timber

const val LOCATION_ENABLE_REQUEST = 100
const val REQUEST_LOCATION_PERMISSION = 1000

class PermissionHelper(private val activity: Activity, val fileTransferEnabled: Boolean = false) :
    PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener {

    private val requiredPermissions = getRequiredPermissions()

    private val locationSettingsRequest = LocationSettingsRequest.Builder()
        .addLocationRequest(LocationRequest.create())
        .setAlwaysShow(true)
        .build()

    fun hasAllPermissions(): Boolean {
        for (permission in requiredPermissions) {
            if (ActivityCompat.checkSelfPermission(activity, permission)
                != PackageManager.PERMISSION_GRANTED
            ) return false
        }

        return true
    }

    fun requestAllPermissions() {
        if (Build.VERSION.SDK_INT < 23) {
            ActivityCompat.requestPermissions(
                activity,
                requiredPermissions,
                REQUEST_LOCATION_PERMISSION
            )
        } else {
            activity.requestPermissions(requiredPermissions, REQUEST_LOCATION_PERMISSION)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return if (requestCode == LOCATION_ENABLE_REQUEST) {
            if (resultCode == Activity.RESULT_OK) requestLocationEnable()
            else requestAllPermissions()

            true
        } else {
            false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        return requestCode == REQUEST_LOCATION_PERMISSION && permissions.isNotEmpty()
    }

    private fun requestLocationEnable() {
        LocationServices.getSettingsClient(activity)
            .checkLocationSettings(locationSettingsRequest)
            .addOnCompleteListener { t ->
                try {
                    t.getResult(ApiException::class.java)
                } catch (ex: ApiException) {
                    when (ex.statusCode) {
                        LocationSettingsStatusCodes.SUCCESS -> {} // TODO
                        LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> try {
                            (ex as ResolvableApiException)
                                .startResolutionForResult(activity, LOCATION_ENABLE_REQUEST)
                        } catch (e: IntentSender.SendIntentException) {
                           // TODO
                        }
                        else -> {} // TODO
                    }
                }
            }
    }

    private fun getRequiredPermissions(): Array<String> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.CHANGE_WIFI_STATE,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.CHANGE_WIFI_STATE,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            return arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_WIFI_STATE,
                Manifest.permission.CHANGE_WIFI_STATE,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }
    }
}