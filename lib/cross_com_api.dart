import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_com_api/api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceStatus { none, connecting, connected, disconnected }

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

  static BroadcastType _broadcastType = BroadcastType.none;
  BroadcastType get broadcastType {
    return _broadcastType;
  }

  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final _serviceUuid = Guid("00001111-0000-1000-8000-00805F9B34FB");
  final _characteristicUuid = Guid("00002222-0000-1000-8000-00805F9B34FB");
  final _eof = '<<<EOF>>>';

  final _onDeviceStateStreamController = StreamController<DeviceStateEvent>.broadcast();
  Stream<DeviceStateEvent> get onDeviceStateStream {
    return _onDeviceStateStreamController.stream;
  }

  Map<String, String> verifiedDeviceMeta = {};

  final Map<String, ConnectedDevice> _connectedDevices = {};
  Map<String, ConnectedDevice> get connectedDevices {
    return {..._connectedDevices};
  }

  final _onMessageStreamController = StreamController<DataMessage>.broadcast();
  Stream<DataMessage> get onMessage {
    return _onMessageStreamController.stream;
  }

  final _onRawMessageStreamController = StreamController<RawMessage>.broadcast();
  Stream<RawMessage> get onRawMessage {
    return _onRawMessageStreamController.stream;
  }

  final _onSignallerStateStreamController = StreamController<SignallerStateEvent>();
  Stream<SignallerStateEvent> get onSignallerState {
    return _onSignallerStateStreamController.stream;
  }

  final _onDeviceVerifiedStreamController = StreamController<VerifiedDevice>.broadcast();
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

  StreamSubscription<List<ScanResult>>? _scanStream;
  final Map<String, BluetoothDevice> _scannedDevices = {};
  BluetoothService? _bluetoothService;
  BluetoothCharacteristic? _bluetoothCharacteristic;
  StreamSubscription<List<int>>? _characeristicStream;

  Future<void> startClient(
      {required String name, bool allowMultipleVerifiedDevice = false, NearbyStrategy strategy = NearbyStrategy.p2pPointToPoint}) async {
    if (BaseApi._broadcastType != BroadcastType.none) {
      throw Exception("The client is in a bad state ${BaseApi._broadcastType}");
    }

    if (Platform.isAndroid) {
      final config = Config(name: name, allowMultipleVerifiedDevice: allowMultipleVerifiedDevice, strategy: strategy);
      await _api.startClient(config);
    }

    BaseApi._broadcastType = BroadcastType.client;
  }

  Future<void> stopClient() async {
    if (BaseApi._broadcastType != BroadcastType.client) {
      throw Exception("The client is in a bad state ${BaseApi._broadcastType}");
    }

    await stopDiscovery();

    await _characeristicStream?.cancel();

    _scanStream?.cancel();
    _connectedDevices.clear();

    _bluetoothService = null;
    _bluetoothCharacteristic = null;

    BaseApi._broadcastType = BroadcastType.none;
  }

  @override
  Future<void> connect(String toDeviceId, String displayName) async {
    if (Platform.isAndroid) {
      return super.connect(toDeviceId, displayName);
    } else {
      if (await _flutterBlue.isScanning.first) {
        await _flutterBlue.stopScan();
      }

      final device = _scannedDevices[toDeviceId];

      await device!.connect(timeout: const Duration(seconds: 10));
      List<BluetoothService> services = await device.discoverServices();
      _bluetoothService = services.firstWhere((service) => service.uuid.toString() == _serviceUuid.toString());
      _bluetoothCharacteristic = _bluetoothService!.characteristics
          .firstWhere((characteristicUuid) => characteristicUuid.uuid.toString() == _characteristicUuid.toString());

      _bluetoothCharacteristic!.setNotifyValue(true);

      await _characeristicStream?.cancel();
      _characeristicStream = _bluetoothCharacteristic!.value.listen((event) async {
        // Read characteristics...
        String dataCollector = '';

        print("NOTIFIED -- ${utf8.decode(event)}");
        while (true) {
          final chunk = await _bluetoothCharacteristic!.read();
          print("DATA $chunk - ${chunk.length}");
          if (chunk.isEmpty || dataCollector.endsWith(_eof)) break;

          dataCollector += utf8.decode(chunk);
          print("DATA Coll $dataCollector");
        }

        print("DATA Colleced $dataCollector");
        await _api.processBleMessage(toDeviceId, dataCollector.replaceFirst(_eof, ''));
      });

      onDeviceConnected(ConnectedDevice(deviceId: toDeviceId, provider: Provider.gatt));
    }
  }

  @override
  Future<void> disconnect(String toDeviceId) async {
    if (Platform.isAndroid) {
      return super.disconnect(toDeviceId);
    } else {
      final connectedDevice = (await _flutterBlue.connectedDevices).firstWhere((element) => element.id.id == toDeviceId);
      await _characeristicStream?.cancel();
      await connectedDevice.disconnect();
      onDeviceDisconnected(ConnectedDevice(deviceId: toDeviceId, provider: Provider.gatt));
    }
  }

  Future<void> startDiscovery({Duration duration = const Duration(minutes: 10)}) async {
    if (_isDiscovering) return;

    if (Platform.isAndroid) {
      await _discoveryApi.startDiscovery();
    } else {
      _scannedDevices.clear();
      if (await _flutterBlue.isScanning.first) {
        await _flutterBlue.stopScan();
      }

      _scanStream?.cancel();
      _scanStream = _flutterBlue.scanResults.listen((scanResult) {
        for (ScanResult r in scanResult) {
          _scannedDevices[r.device.id.id] = r.device;
          _onDeviceDiscoveredStreamController.add(DeviceInfo(id: r.device.id.id, name: r.device.name));
        }
      });
      _flutterBlue.startScan(scanMode: ScanMode.lowLatency, allowDuplicates: true, withServices: [_serviceUuid], timeout: duration);
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
  Future<Map<String?, String?>> requestDeviceVerification(String toDevice, String code, Map<String, String> args) async {
    if (Platform.isAndroid) {
      return super.requestDeviceVerification(toDevice, code, args);
    } else {
      final request = DeviceVerificationRequest(verificationCode: code, args: args);
      sendMessage(toDevice, '/verify', payload)
    }
   
    return await _deviceVerificationApi.requestDeviceVerification(toDevice, request);
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
