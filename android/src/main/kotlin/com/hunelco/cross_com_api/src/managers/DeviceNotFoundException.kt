package com.hunelco.cross_com_api.src.managers

import io.flutter.plugins.Pigeon

class DeviceNotFoundException(deviceId: String, provider: Pigeon.Provider) :
    Exception("Device (id: $deviceId) not found by provider $provider")