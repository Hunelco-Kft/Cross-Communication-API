import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cross_com_api/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceInfo {
  String id;

  String name;

  DeviceInfo({required this.id, required this.name});
}

class RawMessage {
  String deviceId;

  String data;

  RawMessage({required this.deviceId, required this.data});
}

enum DeviceState { connected, disconnected }

class DeviceStateEvent {
  ConnectedDevice device;

  DeviceState state;

  DeviceStateEvent({required this.device, required this.state});
}

enum Signaller { wifi, bluetooth }

class SignallerStateEvent {
  Signaller signaller;

  StateResponse state;

  SignallerStateEvent({required this.signaller, required this.state});
}

class VerifiedDevice {
  ConnectedDevice device;

  DeviceVerificationRequest request;

  VerifiedDevice({required this.device, required this.request});
}

enum BroadcastType { none, server, client }

abstract class BaseApi with ConnectionCallbackApi, CommunicationCallbackApi, StateCallbackApi, DeviceVerificationCallbackApi {
  static const MethodChannel _channel = MethodChannel('cross_com_api', JSONMethodCodec());
  static const String _verifyDeviceEndpoint = '/verifyDevice';

  static BroadcastType _broadcastType = BroadcastType.none;
  BroadcastType get broadcastType {
    return _broadcastType;
  }

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final _characteristicUuid = Guid("00002222-0000-1000-8000-00805F9B34FB");
  final _serviceUuid = Guid("00001111-0000-1000-8000-00805F9B34FB");

  final _onDeviceStateStreamController = StreamController<DeviceStateEvent>();
  Stream<DeviceStateEvent> get onDeviceStateStream {
    return _onDeviceStateStreamController.stream;
  }

  Map<String, String> verifiedDeviceMeta = {};

  final Map<String, ConnectedDevice> _connectedDevices = {};
  Map<String, ConnectedDevice> get connectedDevices {
    return {..._connectedDevices};
  }

  final _onMessageStreamController = StreamController<DataMessage>();
  Stream<DataMessage> get onMessage {
    return _onMessageStreamController.stream;
  }

  final _onRawMessageStreamController = StreamController<RawMessage>();
  Stream<RawMessage> get onRawMessage {
    return _onRawMessageStreamController.stream;
  }

  final _onSignallerStateStreamController = StreamController<SignallerStateEvent>();
  Stream<SignallerStateEvent> get onSignallerState {
    return _onSignallerStateStreamController.stream;
  }

  final _onDeviceVerifiedStreamController = StreamController<VerifiedDevice>();
  Stream<VerifiedDevice> get onVerifiedDevice {
    return _onDeviceVerifiedStreamController.stream;
  }

  final ConnectionApi _connectionApi = ConnectionApi(binaryMessenger: _channel.binaryMessenger);
  final CommunicationApi _commApi = CommunicationApi(binaryMessenger: _channel.binaryMessenger);
  final DeviceVerificationApi _deviceVerificationApi = DeviceVerificationApi(binaryMessenger: _channel.binaryMessenger);

  BaseApi() {
    ConnectionCallbackApi.setup(this, binaryMessenger: _channel.binaryMessenger);
    CommunicationCallbackApi.setup(this, binaryMessenger: _channel.binaryMessenger);
    StateCallbackApi.setup(this, binaryMessenger: _channel.binaryMessenger);
    DeviceVerificationCallbackApi.setup(this, binaryMessenger: _channel.binaryMessenger);
  }

  ConnectedDevice? getConnectedDevice(String deviceId) {
    return _connectedDevices[deviceId];
  }

  Future<void> connect(String toDeviceId, String displayName) {
    return _connectionApi.connect(toDeviceId, displayName);
  }

  Future<void> disconnect(String toDeviceId) {
    if (!_connectedDevices.containsKey(toDeviceId)) return Future.value();
    return _connectionApi.disconnect(toDeviceId);
  }

  Future<void> sendMessage(String toDeviceId, String endpoint, String payload) {
    return _commApi.sendMessage(toDeviceId, endpoint, payload);
  }

  Future<void> sendMessageToVerifiedDevice(String endpoint, String data) {
    return _commApi.sendMessageToVerifiedDevice(endpoint, data);
  }

  Future<Map<String?, String?>> requestDeviceVerification(String toDevice, String code, Map<String, String> args) async {
    final request = DeviceVerificationRequest(verificationCode: code, args: args);
    return await _deviceVerificationApi.requestDeviceVerification(toDevice, request);
  }

  @override
  void onDeviceConnected(ConnectedDevice device) {
    _connectedDevices[device.deviceId!] = device;
    _onDeviceStateStreamController.add(DeviceStateEvent(device: device, state: DeviceState.connected));
  }

  @override
  void onDeviceDisconnected(ConnectedDevice device) {
    _connectedDevices.remove(device.deviceId!);
    _onDeviceStateStreamController.add(DeviceStateEvent(device: device, state: DeviceState.disconnected));
  }

  @override
  void onMessageReceived(DataMessage msg) {
    _onMessageStreamController.add(msg);
  }

  @override
  void onRawMessageReceived(String deviceId, String msg) {
    _onRawMessageStreamController.add(RawMessage(deviceId: deviceId, data: msg));
  }

  @override
  void onBluetoothStateChanged(StateResponse state) {
    _onSignallerStateStreamController.add(SignallerStateEvent(signaller: Signaller.bluetooth, state: state));
  }

  @override
  void onWifiStateChanged(StateResponse state) {
    _onSignallerStateStreamController.add(SignallerStateEvent(signaller: Signaller.wifi, state: state));
  }

  @override
  Map<String, String> onDeviceVerified(ConnectedDevice device, DeviceVerificationRequest request) {
    log("ONVERIFIED DEVICE....");
    _onDeviceVerifiedStreamController.add(VerifiedDevice(device: device, request: request));
    return verifiedDeviceMeta;
  }
}

// It only works on Android Server Side!
class CrossComServerApi extends BaseApi {
  static final CrossComServerApi _instance = CrossComServerApi._internal();

  factory CrossComServerApi() {
    return _instance;
  }

  CrossComServerApi._internal();

  bool _isAdvertising = false;
  get isAdvertising {
    return _isAdvertising;
  }

  final ServerApi _api = ServerApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final AdvertiseApi _advertiseApi = AdvertiseApi(binaryMessenger: BaseApi._channel.binaryMessenger);

  Future<void> startServer(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) async {
    if (BaseApi._broadcastType != BroadcastType.none) {
      throw Exception("The server is in a bad state ${BaseApi._broadcastType}");
    }

    final config = Config(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);

    await _api.startServer(config);
    BaseApi._broadcastType = BroadcastType.server;
  }

  Future<void> stopServer() async {
    if (BaseApi._broadcastType != BroadcastType.server) {
      throw Exception("The server is in a bad state ${BaseApi._broadcastType}");
    }

    await stopAdvertise();
    await _api.stopServer();

    _connectedDevices.clear();
    BaseApi._broadcastType = BroadcastType.none;
  }

  Future<void> reset() {
    return _advertiseApi.reset();
  }

  Future<void> startAdvertise(String verificationCode) async {
    if (_isAdvertising) return;

    await _advertiseApi.startAdvertise(verificationCode);
    _isAdvertising = true;
  }

  Future<void> stopAdvertise() async {
    if (!_isAdvertising) return;

    await _advertiseApi.stopAdvertise();
    _isAdvertising = false;
  }
}

class CrossComClientApi extends BaseApi with DiscoveryCallbackApi {
  static final CrossComClientApi _instance = CrossComClientApi._internal();

  factory CrossComClientApi() {
    DiscoveryCallbackApi.setup(_instance, binaryMessenger: BaseApi._channel.binaryMessenger);
    return _instance;
  }

  CrossComClientApi._internal();

  bool _isDiscovering = false;
  get isDiscovering {
    return _isDiscovering;
  }

  final _onDeviceDiscoveredStreamController = StreamController<DeviceInfo>.broadcast();
  Stream<DeviceInfo> get onDeviceDiscover {
    return _onDeviceDiscoveredStreamController.stream;
  }

  final ClientApi _api = ClientApi(binaryMessenger: BaseApi._channel.binaryMessenger);
  final DiscoveryApi _discoveryApi = DiscoveryApi(binaryMessenger: BaseApi._channel.binaryMessenger);

  late StreamSubscription<List<ScanResult>> _scanStream;
  final Map<String, BluetoothDevice> _scannedDevices = {};

  Future<void> startClient(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) async {
    if (BaseApi._broadcastType != BroadcastType.none) {
      throw Exception("The client is in a bad state ${BaseApi._broadcastType}");
    }

    final config = Config(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);

    _scanStream = _flutterBlue.scanResults.listen((scanResult) {
      for (ScanResult r in scanResult) {
        _scannedDevices[r.device.id.id] = r.device;
        _onDeviceDiscoveredStreamController.add(DeviceInfo(id: r.device.id.id, name: r.device.name));
      }
    });

    await _api.startClient(config);
    BaseApi._broadcastType = BroadcastType.client;
  }

  void stopClient() {
    if (BaseApi._broadcastType != BroadcastType.client) {
      throw Exception("The client is in a bad state ${BaseApi._broadcastType}");
    }

    stopDiscovery();

    _scanStream.cancel();
    _connectedDevices.clear();
    BaseApi._broadcastType = BroadcastType.none;
  }

  @override
  Future<void> connect(String toDeviceId, String displayName) {
    if (Platform.isAndroid) {
      return super.connect(toDeviceId, displayName);
    } else {
      return _scannedDevices[toDeviceId]!.connect(timeout: const Duration(seconds: 10));
    }
  }

  @override
  Future<void> disconnect(String toDeviceId) async {
    if (Platform.isAndroid) {
      return super.disconnect(toDeviceId);
    } else {
      final connectedDevice = (await _flutterBlue.connectedDevices).firstWhere((element) => element.id.id == toDeviceId);
      return connectedDevice.disconnect();
    }
  }

  Future<void> startDiscovery({int timeoutInSeconds = 10000000}) async {
    if (_isDiscovering) return;

    if (Platform.isAndroid) {
      await _discoveryApi.startDiscovery();
    } else {
      _scannedDevices.clear();
      await _flutterBlue.startScan(
          scanMode: ScanMode.lowLatency, allowDuplicates: true, withServices: [_serviceUuid], timeout: Duration(seconds: timeoutInSeconds));
    }
    _isDiscovering = true;
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    if (Platform.isAndroid) {
      await _discoveryApi.stopDiscovery();
    } else {
      await _flutterBlue.stopScan();
      _scannedDevices.clear();
    }

    _isDiscovering = false;
  }

  @override
  void onDeviceDiscovered(String deviceId, String deviceName) {
    _onDeviceDiscoveredStreamController.add(DeviceInfo(id: deviceId, name: deviceName));
  }

  @override
  void onDeviceLost(String deviceId) {
    // Nothing todo here...
  }
}
