import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_com_api/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BaseApi {
  static const MethodChannel _channel = MethodChannel('cross_com_api');
}

// It only works on Android Server Side!
class CrossComServerApi extends BaseApi {
  final ServerApi _api = ServerApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final CommunicationApi _commApi = CommunicationApi(binaryMessenger: BaseApi._channel.binaryMessenger);

  Future<void> startServer(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) {
    final config = ServerConfig(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);
    return _api.startServer(config);
  }

  Future<void> stopServer() {
    return _api.stopServer();
  }

  Future<void> startAdvertise() {
    return _commApi.startAdvertise();
  }

  Future<void> stopAdvertise() {
    return _commApi.stopAdvertise();
  }

  Future<void> sendMessage(String toDeviceId, String endpoint, String payload) {
    return _commApi.sendMessage(toDeviceId, endpoint, payload);
  }

  Future<void> sendMessageToVerifiedDevice(String endpoint, String data) {
    return _commApi.sendMessageToVerifiedDevice(endpoint, data);
  }
}

class CrossComClientApi extends BaseApi with CommunicationCallbackApi {
   final characteristicUuid = Guid("00002222-0000-1000-8000-00805F9B34FB");
   final serviceUuid = Guid("00001111-0000-1000-8000-00805F9B34FB");

   final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
   final ClientApi _clientApi = ClientApi(binaryMessenger: BaseApi._channel.binaryMessenger);

   StreamSubscription<List<ScanResult>>? _subscription;
   Map<String, ConnectedDevice> _devices = {};

   List<BluetoothService>? _services;
  
   BluetoothCharacteristic? _generalCharacteristic;

  constructor() {
    CommunicationCallbackApi.setup(this, binaryMessenger: BaseApi._channel.binaryMessenger);
  }


   Future<void> startDiscovery({int timeoutInSeconds = 10000000}) async {
    _devices.clear();

    if (Platform.isAndroid) {
      await _clientApi.startDiscovery();
    } else {
      await _flutterBlue.startScan(
          scanMode: ScanMode.lowLatency, allowDuplicates: true, withServices: [serviceUuid], timeout: Duration(seconds: timeoutInSeconds));
      _subscription = _flutterBlue.scanResults.listen((results) { 
        for (ScanResult r in results) {
          _devices[r.device.id.id] = ConnectedDevice(deviceId: r.device.id.id, provider: Provider.gatt);

          // TODO: Stream adatfolyam behívása
        }
      });
    }
  }

   Future<void> stopDiscovery() async {
    if (Platform.isAndroid) {
      _subscription?.cancel();
      await _clientApi.stopDiscovery();
    } else {
      await _flutterBlue.stopScan();
    }
  }

   Future<void> connectToDevice(String connectToDeviceid) async {
    
  }

   Future<void> disconnectFromDevice(String id) async {

  }

   Future<void> sendMessage(String endpoint, String data) async {
    MessagePayload(endpoint: endpoint, data: data)
    await _generalCharacteristic?.write(jsonEncode(MessagePayload(deviceId: )))
  }

  @override
  bool onDeviceConnected(ConnectedDevice device) {
    _devices[device.deviceId!] = device;
  }

  @override
  void onDeviceDisconnected(ConnectedDevice device) {
    // TODO: implement onDeviceDisconnected
  }

  @override
  void onMessageReceived(DataMessage msg) {
    // TODO: implement onMessageReceived
  }

  @override
  void onRawMessageReceived(String msg) {
    // TODO: implement onRawMessageReceived
  }
}
