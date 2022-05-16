import 'dart:async';
import 'dart:io';

import 'package:cross_com_api/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BaseApi {
  static const MethodChannel _channel = MethodChannel('cross_com_api', JSONMethodCodec());
}

// It only works on Android Server Side!
class CrossComServerApi extends BaseApi with ConnectionCallbackApi, CommunicationCallbackApi {
  static final CrossComServerApi _instance = CrossComServerApi._internal();

  factory CrossComServerApi() {
    ConnectionCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    CommunicationCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    return _instance;
  }

  CrossComServerApi._internal();

  final ServerApi _api = ServerApi(binaryMessenger: const MethodChannel('server_api').binaryMessenger);
  final AdvertiseApi _advertiseApi = AdvertiseApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final CommunicationApi _commApi = CommunicationApi(binaryMessenger: BaseApi._channel.binaryMessenger);

  Future<void> startServer(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) {
    final config = Config(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);
    return _api.startServer(config);
  }

  Future<void> stopServer() {
    return _api.stopServer();
  }

  Future<void> startAdvertise() {
    return _advertiseApi.startAdvertise();
  }

  Future<void> stopAdvertise() {
    return _advertiseApi.stopAdvertise();
  }

  Future<void> sendMessage(String toDeviceId, String endpoint, String payload) {
    return _commApi.sendMessage(toDeviceId, endpoint, payload);
  }

  Future<void> sendMessageToVerifiedDevice(String endpoint, String data) {
    return _commApi.sendMessageToVerifiedDevice(endpoint, data);
  }

  @override
  void onMessageReceived(DataMessage msg) {
    print("RECEIVED" + msg.toString());
    // TODO: implement onMessageReceived
  }

  @override
  void onRawMessageReceived(String deviceId, String msg) {
    print("RECEIVED RAW" + msg.toString());
    // TODO: implement onRawMessageReceived
  }

  @override
  bool onDeviceConnected(ConnectedDevice device) {
    print("NearbyClientManager - CONNECTED");
    return true;
  }

  @override
  void onDeviceDisconnected(ConnectedDevice device) {
    // TODO: implement onDeviceDisconnected
  }
}

class CrossComClientApi extends BaseApi with ConnectionCallbackApi, CommunicationCallbackApi, StateCallbackApi, DiscoveryCallbackApi {
  static final CrossComClientApi _instance = CrossComClientApi._internal();

  factory CrossComClientApi() {
    ConnectionCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    CommunicationCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    StateCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    DiscoveryCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);

    return _instance;
  }

  CrossComClientApi._internal();

  final characteristicUuid = Guid("00002222-0000-1000-8000-00805F9B34FB");
  final serviceUuid = Guid("00001111-0000-1000-8000-00805F9B34FB");

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;

  final ClientApi _api = ClientApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final ConnectionApi _connectionApi = ConnectionApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final DiscoveryApi _discoveryApi = DiscoveryApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final CommunicationApi _communicationApi = CommunicationApi(binaryMessenger: BaseApi._channel.binaryMessenger);

  StreamSubscription<List<ScanResult>>? _subscription;
  Map<String, ConnectedDevice> _devices = {};

  List<BluetoothService>? _services;

  BluetoothCharacteristic? _generalCharacteristic;

  StreamController<String>? _onDeviceStreamController;
  Stream<String>? _onDeviceStream;

  StreamController<DataMessage>? _onMessageStreamController;
  Stream<DataMessage>? _onMessageStream;

  Future<void> startServer(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) {
    final config = Config(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);
    return _api.startClient(config);
  }

  Future<void> startDiscovery({int timeoutInSeconds = 10000000}) async {
    _devices.clear();

    _onDeviceStreamController = StreamController<String>();
    _onDeviceStream = _onDeviceStreamController?.stream;
    if (Platform.isAndroid) {
      await _discoveryApi.startDiscovery();
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
    _onDeviceStreamController?.close(); // TODO

    if (Platform.isAndroid) {
      _subscription?.cancel();
      await _discoveryApi.stopDiscovery();
    } else {
      await _flutterBlue.stopScan();
    }
  }

  Future<void> connectToDevice(String connectToDeviceid) async {
    print('connectToDevice $connectToDeviceid');
    if (Platform.isAndroid) {
      await _connectionApi.connect(connectToDeviceid, "DEVICE");
      _onMessageStreamController = StreamController<DataMessage>();
      _onMessageStream = _onMessageStreamController?.stream;
    } else {
      await _flutterBlue.stopScan();
    }
  }

  Future<void> disconnectFromDevice(String id) async {
    if (Platform.isAndroid) {
      await _connectionApi.disconnect(id);
    } else {
      await _flutterBlue.stopScan();
    }
  }

  Future<void> sendMessage(String endpoint, String data) async {
    final result = await _communicationApi.sendMessageToVerifiedDevice(endpoint, data);
    print("SIKERES ÍRÁS? " + result.toString());
    // final message = MessagePayload(endpoint: endpoint, data: data);
    // await _generalCharacteristic?.write(jsonEncode(message));
  }

  Stream<String>? getOnDeviceStream() {
    return _onDeviceStream;
  }

  Stream<DataMessage>? getOnMessageStream() {
    return _onMessageStream;
  }

  @override
  void onBluetoothStateChanged(StateResponse state) {
    // TODO: implement onBluetoothStateChanged
  }

  @override
  bool onDeviceConnected(ConnectedDevice device) {
    // TODO: implement onDeviceConnected
    return true;
  }

  @override
  void onDeviceDisconnected(ConnectedDevice device) {
    // TODO: implement onDeviceDisconnected
  }

  @override
  void onMessageReceived(DataMessage msg) {
    _onMessageStreamController?.add(msg);
  }

  @override
  void onRawMessageReceived(String deviceId, String msg) {
    // TODO: implement onRawMessageReceived
  }

  @override
  void onWifiStateChanged(StateResponse state) {
    // TODO: implement onWifiStateChanged
  }

  @override
  void onDeviceDiscovered(String deviceId) {
    print("Nerby Endpoint discovered -> CrossApi: $deviceId");
    _onDeviceStreamController?.add(deviceId);
  }

  @override
  void onDeviceLost(String deviceId) {
    // TODO: implement onDeviceLost
  }
}
