import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cross_com_api/api.dart';
import 'package:cross_com_api/models/data_payload_model.dart';
import 'package:cross_com_api/models/verification_body.dart';
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

  final _notifCharUuid = Guid("00002222-0000-1000-8000-00805F9B34FA");
  final _readCharUuid = Guid("00002222-0000-1000-8000-00805F9B34FB");
  final _writeCharUuid = Guid("00002222-0000-1000-8000-00805F9B34FC");
  final _eof = '<<<EOF>>>';
  final _endpointVerifyDevice = '/verifyDevice';

  final _onDeviceStateStreamController = StreamController<DeviceStateEvent>.broadcast();
  Stream<DeviceStateEvent> get onDeviceStateStream {
    return _onDeviceStateStreamController.stream;
  }

  ConnectedDevice? _verifiedDevice;

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
    if (device.deviceId == _verifiedDevice?.deviceId) {
      _verifiedDevice = null;
    }

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
  void onDeviceVerified(ConnectedDevice device, DeviceVerificationRequest request) {
    _onDeviceVerifiedStreamController.add(VerifiedDevice(device: device, request: request));
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
    await _api.stopServerSync();

    _connectedDevices.clear();
    BaseApi._broadcastType = BroadcastType.none;
  }

  Future<void> reset() {
    return _advertiseApi.resetAsync();
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

  int? mtuSize;

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

      await device!.connect(autoConnect: false, timeout: const Duration(seconds: 10)).timeout(const Duration(seconds: 10));

      StreamSubscription<int>? _mtuSub;
      if (Platform.isAndroid) {
        _mtuSub = device.mtu.listen((newMtu) {
          mtuSize = newMtu;
          if (mtuSize == 512) {
            setupNotifyAndListenCharacteristic(toDeviceId, device);
            _mtuSub?.cancel();
          }
        }, onError: (e) {
          setupNotifyAndListenCharacteristic(toDeviceId, device);
        });
        await device.requestMtu(512);
      } else {
        setupNotifyAndListenCharacteristic(toDeviceId, device);
      }
    }
  }

  Future<void> setupNotifyAndListenCharacteristic(String toDeviceId, BluetoothDevice device) async {
    await device.discoverServices();

    final _notifChar = await _getCharacteristic(_notifCharUuid, toDeviceId);
    await _notifChar.setNotifyValue(true);

    await _characeristicStream?.cancel();
    _characeristicStream = _notifChar.value.listen((List<int> event) async {
      if (event.isNotEmpty && utf8.decode(event) == 'R') {
        // Read characteristics...
        String dataCollector = '';

        try {
          final characteristic = await _getCharacteristic(_readCharUuid, toDeviceId);
          while (true) {
            final chunk = await characteristic.read();
            dataCollector += utf8.decode(chunk);

            if (chunk.isEmpty || dataCollector.endsWith(_eof)) {
              _processMessage(device.id.id, dataCollector.replaceAll(_eof, ''));
              break;
            }
          }
        } catch (ex) {
          // TODO
        }
      }
    });

    onDeviceConnected(ConnectedDevice(deviceId: toDeviceId, provider: Provider.gatt));
  }

  @override
  Future<void> disconnect(String toDeviceId) async {
    if (Platform.isAndroid) {
      return super.disconnect(toDeviceId);
    } else {
      final connectedDevice = (await _flutterBlue.connectedDevices).firstWhere((element) => element.id.id == toDeviceId);
      await _characeristicStream?.cancel();
      await connectedDevice.disconnect();
      mtuSize = null;
      onDeviceDisconnected(ConnectedDevice(deviceId: toDeviceId, provider: Provider.gatt));
    }
  }

  Future<void> startDiscovery({Duration duration = const Duration(minutes: 10)}) async {
    if (_isDiscovering) return;

    if (Platform.isAndroid) {
      await _discoveryApi.startDiscoveryAsync();
    } else {
      _scannedDevices.clear();
      await _flutterBlue.stopScan();

      await _scanStream?.cancel();

      // A flutterBlue.scanResults egy BehaviorSubject(feliratkozás pillanatában már megkapjuk azt az állapotot amiről legutoljára tud) így amint elkezdjük hallgatni a streamet mindig megkapjuk a legutolsó állapotot.
      // A flutter.startScan ezt üríti, de mivel a stream async így mindenféleképpen megkapjuk a legutolsó állapotot és csak utána az ürítettet.
      // Az új feliratkozók mindig megkapják legelsőnek a kezdetleges/legutolsó állapotot és csak utána kapják az események
      bool ignoreFirst = true;
      _scanStream = _flutterBlue.scanResults.listen((scanResult) {
        log('result: $scanResult');
        if (!ignoreFirst) {
          for (ScanResult r in scanResult) {
            _scannedDevices[r.device.id.id] = r.device;
            _onDeviceDiscoveredStreamController.add(DeviceInfo(id: r.device.id.id, name: r.device.name));
          }
        } else {
          ignoreFirst = false;
        }
      });
      _flutterBlue.startScan(scanMode: ScanMode.lowLatency, allowDuplicates: true, withServices: [_serviceUuid], timeout: duration);
    }
    _isDiscovering = true;
  }

  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    if (Platform.isAndroid) {
      await _discoveryApi.stopDiscoveryAsync();
    } else {
      await _flutterBlue.stopScan();
      _scannedDevices.clear();
    }

    _isDiscovering = false;
  }

  @override
  Future<void> sendMessage(String toDeviceId, String endpoint, String payload) async {
    if (Platform.isAndroid) {
      await _commApi.sendMessage(toDeviceId, endpoint, payload);
    } else {
      final device = _scannedDevices[toDeviceId]!;
      final mtu = mtuSize ?? await device.mtu.first;
      final request = jsonEncode(DataPayloadModel(endpoint: endpoint, data: payload).toJson());
      await _writeWithEof(request, mtu, toDeviceId);
    }
  }

  @override
  Future<void> sendMessageToVerifiedDevice(String endpoint, String data) async {
    if (Platform.isAndroid) {
      await _commApi.sendMessageToVerifiedDevice(endpoint, data);
    } else {
      if (_verifiedDevice == null) {
        throw Exception("No verified device found.");
      }
      final device = (await _flutterBlue.connectedDevices).firstWhere((device) => device.id.id == _verifiedDevice!.deviceId);
      await sendMessage(device.id.id, endpoint, data);
    }
  }

  @override
  Future<Map<String?, String?>> requestDeviceVerification(String toDevice, String code, Map<String, String> args) async {
    if (Platform.isAndroid) {
      return super.requestDeviceVerification(toDevice, code, args);
    } else {
      final verificationRequest = VerificationBody(code: code, args: args);
      final msg = jsonEncode(verificationRequest.toJson());
      await sendMessage(toDevice, _endpointVerifyDevice, msg);
      return {};
    }
  }

  @override
  void onDeviceDiscovered(String deviceId, String deviceName) {
    _onDeviceDiscoveredStreamController.add(DeviceInfo(id: deviceId, name: deviceName));
  }

  @override
  void onDeviceLost(String deviceId) {
    // Nothing todo here...
  }

  Future<void> _writeWithEof(String text, int mtu, String toDeviceId) async {
    final writeChar = await _getCharacteristic(_writeCharUuid, toDeviceId);

    List<int> encodedList = utf8.encode('$text$_eof').toList(growable: true);
    while (encodedList.isNotEmpty) {
      List<int> subList = encodedList.getRange(0, encodedList.length > mtu ? mtu : encodedList.length).toList();
      encodedList.removeRange(0, subList.length);
      int successWriteCount = 0;
      while (successWriteCount != 3) {
        try {
          await writeChar.write(subList, withoutResponse: false);
          break;
        } catch (e, stack) {
          print('write error: $e\n$stack');
        }
        successWriteCount++;
        if (successWriteCount == 3) {
          throw Exception("Couldn't write data ($text) to characteristic ($writeChar)");
        }
      }
    }
  }

  Future<BluetoothCharacteristic> _getCharacteristic(Guid char, String deviceId) async {
    final device = _scannedDevices[deviceId]!;

    final _bluetoothService = (await device.services.first).firstWhere((service) => service.uuid.toString() == _serviceUuid.toString());
    return _bluetoothService.characteristics.firstWhere((characteristicUuid) => characteristicUuid.uuid.toString() == char.toString());
  }

  void _processMessage(String deviceId, String msg) {
    try {
      final dataPayload = DataPayloadModel.fromJson(jsonDecode(msg));
      final dataMsg = DataMessage(deviceId: deviceId, provider: Provider.gatt, endpoint: dataPayload.endpoint, data: dataPayload.data);

      if (dataMsg.endpoint == _endpointVerifyDevice) {
        _verifiedDevice = ConnectedDevice(deviceId: deviceId, provider: Provider.gatt);
        // TODO: onDeviceVerififed()
      } else {
        onMessageReceived(dataMsg);
      }
    } catch (ex) {
      // Couldn't parse message...
      onRawMessageReceived(deviceId, msg);
    }
  }
}
