import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static final DeviceHelper instance = DeviceHelper._internal();

  BaseDeviceInfo? deviceInfo;

  Future<bool> isSdkVersionUnder31() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfo ??= await deviceInfoPlugin.deviceInfo;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt == null) {
        return true;
      } else {
        return androidInfo.version.sdkInt! < 31;
      }
    } else {
      return true;
    }
  }

  factory DeviceHelper() {
    return instance;
  }

  DeviceHelper._internal();
}
