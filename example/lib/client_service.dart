import 'dart:async';
import 'dart:developer';

import 'package:cross_com_api/api.dart';
import 'package:cross_com_api/cross_com_api.dart';
import 'package:cross_com_api_example/endpoints.dart';
import 'package:cross_com_api_example/hardver_service.dart';
import 'package:flutter/services.dart';

enum DeviceStatus { none, connecting, connected }

class ClientService {
  late CrossComClientApi comClientApi;

  ClientService() {
    comClientApi = CrossComClientApi();
  }

  StreamSubscription<DeviceInfo>? _onDeviceDiscoverSub;
  StreamSubscription<DeviceStateEvent>? _onConnectedSub;
  StreamSubscription<DataMessage>? _onMessageSub;
  StreamSubscription<DeviceStateEvent>? _onDeviceDisconnectedSub;

  final _onMsgStreamController = StreamController<String>.broadcast();
  Stream<String> get onMsg {
    return _onMsgStreamController.stream;
  }

  String deviceName = '';
  Map<String, DeviceInfo> devices = {};
  DeviceStatus deviceStatus = DeviceStatus.none;

  DeviceInfo? deviceInfo;

  Future<void> startDiscovery({CommunicationMode mode = CommunicationMode.auto, required String deviceName}) async {
    try {
      this.deviceName = deviceName;
      if (comClientApi.broadcastType == BroadcastType.none) {
        await comClientApi.startClient(name: HardverService.serverName, mode: mode);
      }

      _onDeviceDisconnectedSub = comClientApi.onDeviceStateStream.listen((state) {
        log('state onDeviceStateStream: ${state} -- ${state.device.deviceId}');
        if (state.device.deviceId == deviceInfo?.id && state.state == DeviceState.disconnected) {}

        sendMessage(Endpoints.com, 'hello');
      });

      _onDeviceDiscoverSub = comClientApi.onDeviceDiscover.listen((device) async {
        log('devicesInfo - NAME: ${device.name} - $deviceStatus');
        devices[device.name] = device;
        await _connectToDevice();
      });

      devices.clear();
      await comClientApi.startDiscovery();
    } catch (e, stack) {
      if (e.runtimeType is PlatformException) {
        final es = e as PlatformException;
        log('es: ${es.code} -- ${es.message} -- ${es.details}');
      }
      try {
        //If nearby package is not available fallback BLE
        final es = e as PlatformException;
        if (es.code == 'ApiException' && es.message?.contains('com.google.android.gms.common.api.ApiException: 17') == true) {
          await close();
          startDiscovery(mode: CommunicationMode.ble, deviceName: deviceName);
          return;
        }
      } catch (e) {
        log('no covert');
      }
    }
  }

  Future<void> _connectToDevice() async {
    try {
      deviceInfo = devices[deviceName];
      if (deviceInfo == null || deviceStatus != DeviceStatus.none) {
        return;
      }

      deviceStatus = DeviceStatus.connecting;

      _onConnectedSub = comClientApi.onDeviceStateStream.listen((device) async {
        _onConnectedSub?.cancel();

        _startListenMessage();
      });

      await comClientApi.connect(deviceInfo!.id, HardverService.serverName);
      deviceStatus = DeviceStatus.connected;
    } catch (e, stack) {
      log("Couldn't connect to hardver: $e, $stack");
    }
  }

  _startListenMessage() {
    _onMessageSub?.cancel();

    //message from hardver
    _onMessageSub = comClientApi.onMessage.listen((msg) async {
      try {
        String _msg = 'Message from client: endpoint: ${msg.endpoint} - data: ${msg.data}';
        _onMsgStreamController.add(_msg);
        log(_msg);
        switch (msg.endpoint?.toLowerCase()) {
          case Endpoints.com:
            //send msg to hardver
            //await sendMessage(Endpoints.com, 'Whats app?');
            break;
          default:
            throw Exception("Illegal state exception. Endpoint unknown: ${msg.endpoint}");
        }
      } catch (ex, stack) {
        log('startListenMessage error: $ex $stack');
      }
    });
  }

  Future<void> _disconnectToDevice(String deviceId) async {
    try {
      await comClientApi.disconnect(deviceId);
      deviceStatus = DeviceStatus.none;
    } catch (e) {
      log('disconnectToDevice Error: $e');
    }
  }

  Future<void> sendMessage(String endpoint, String msg) async {
    await comClientApi.sendMessage(deviceInfo!.id, endpoint, msg);
  }

  Future<void> close() async {
    if (deviceInfo != null) await _disconnectToDevice(deviceInfo!.id);

    await _onDeviceDiscoverSub?.cancel();
    await _onMessageSub?.cancel();
    await _onConnectedSub?.cancel();
    await _onDeviceDisconnectedSub?.cancel();

    await comClientApi.stopClient();
    devices = {};
  }
}
