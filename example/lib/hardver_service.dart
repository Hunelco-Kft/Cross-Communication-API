import 'dart:async';
import 'dart:developer';

import 'package:cross_com_api/api.dart';
import 'package:cross_com_api/cross_com_api.dart';
import 'package:cross_com_api_example/endpoints.dart';

class HardverService {
  late CrossComServerApi comServerApi;

  StreamSubscription<DataMessage>? _onMessageSub;
  StreamSubscription<VerifiedDevice>? _onDeviceVerified;
  StreamSubscription<DeviceStateEvent>? _onDeviceDisconnected;

  final _onMsgStreamController = StreamController<String>.broadcast();
  Stream<String> get onMsg {
    return _onMsgStreamController.stream;
  }

  static const String serverName = 'server123';
  ConnectedDevice? _connectedDevice;

  HardverService() {
    comServerApi = CrossComServerApi();
  }

  Future<void> startAdvertise() async {
    try {
      if (comServerApi.isAdvertising) return;

      if (comServerApi.broadcastType == BroadcastType.none) {
        await comServerApi.startServer(name: serverName);
      }

      _onDeviceDisconnected = comServerApi.onDeviceStateStream.listen((state) async {
        log('state onDeviceStateStream: ${state} -- ${state.device.deviceId}');
        _connectedDevice = state.device;
        if (state.state == DeviceState.disconnected && state.device.deviceId == _connectedDevice?.deviceId) {
          await _onMessageSub?.cancel();
        }
      });

      _startListenMessage();

      await comServerApi.startAdvertise(serverName);
    } catch (ex, stack) {
      log("Cross communication server start failed. ex: $ex $stack");
    }
  }

  _startListenMessage() {
    _onMessageSub?.cancel();

    //message from client
    _onMessageSub = comServerApi.onMessage.listen((msg) async {
      String _msg = 'Message from client: endpoint: ${msg.endpoint} - data: ${msg.data}';
      _onMsgStreamController.add(_msg);
      log(_msg);

      try {
        switch (msg.endpoint?.toLowerCase()) {
          case Endpoints.com:
            //send msg to client
            await sendMessage(Endpoints.com, 'world');
            break;
          default:
            throw Exception("Illegal state exception. Endpoint unknown: ${msg.endpoint}");
        }
      } catch (ex, stack) {
        log('startListenMessage error: $ex $stack');
      }
    });
  }

  Future<void> close() async {
    try {
      await _onDeviceDisconnected?.cancel();
      if (_connectedDevice != null) await comServerApi.disconnect(_connectedDevice!.deviceId!);
    } catch (e) {
      log("Couldn't close connnection to device $e");
    }

    try {
      if (comServerApi.broadcastType == BroadcastType.server) {
        await comServerApi.stopServer();
      }
    } catch (e) {}

    try {
      await comServerApi.stopAdvertise();
    } catch (e) {
      log("Couldn't stop advertising: $e");
    }

    await _onMessageSub?.cancel();
    await _onDeviceVerified?.cancel();
  }

  Future<void> sendMessage(String endpoint, String msg) async {
    if (_connectedDevice != null && _connectedDevice!.deviceId != null) {
      await comServerApi.sendMessage(_connectedDevice!.deviceId!, endpoint, msg);
    }
  }
}
