import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static final DeviceHelper instance = DeviceHelper._internal();

  BaseDeviceInfo? deviceInfo;

  factory DeviceHelper() {
    return instance;
  }

  DeviceHelper._internal();
}
