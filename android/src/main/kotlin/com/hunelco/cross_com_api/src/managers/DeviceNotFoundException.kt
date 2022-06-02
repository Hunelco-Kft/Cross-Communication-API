package com.hunelco.cross_com_api.src.managers

import com.flutter.pigeon.Pigeon

class DeviceNotFoundException(deviceId: String, provider: Pigeon.Provider) :
    Exception("Device (id: $deviceId) not found by provider $provider")

class NoVerifiedDeviceFoundException: Exception("There were no any verified device found.")