import 'package:pigeon/pigeon.dart';

enum NearbyStrategy { p2pCluster, p2pStar, p2pPointToPoint }

enum Provider { gatt, nearby }

enum State { on, off, unknown }

class Config {
  String? name;

  NearbyStrategy? strategy;

  bool? allowMultipleVerifiedDevice;
}

class DataMessage {
  String? deviceId;

  Provider? provider;

  String? endpoint;

  String? data;
}

class ConnectedDevice {
  String? deviceId;

  Provider? provider;
}

class StateResponse {
  State? state;
}

class DeviceVerificationRequest {
  String? verificationCode;

  Map<String?, String?>? args;
}

@HostApi()
abstract class ServerApi {
  // It starts the server if it is not started yet as a foreground service
  @async
  int startServer(Config config);

  void stopServer();

  @async
  int reset();
}

@HostApi()
abstract class ClientApi {
  void startClient(Config config);

  @async
  int reset();
}

@HostApi()
abstract class ConnectionApi {
  @async
  ConnectedDevice connect(String toDeviceId, String displayName);

  @async
  int disconnect(String id);
}

@FlutterApi()
abstract class ConnectionCallbackApi {
  void onDeviceConnected(ConnectedDevice device);

  void onDeviceDisconnected(ConnectedDevice device);
}

@HostApi()
abstract class DeviceVerificationApi {
  @async
  Map<String, String> requestDeviceVerification(String toDeviceId, DeviceVerificationRequest request);
}

@FlutterApi()
abstract class DeviceVerificationCallbackApi {
  Map<String, String> onDeviceVerified(ConnectedDevice device, DeviceVerificationRequest request);
}

@HostApi()
abstract class DiscoveryApi {
  @async
  int startDiscovery();

  @async
  int stopDiscovery();
}

@FlutterApi()
abstract class DiscoveryCallbackApi {
  void onDeviceDiscovered(String deviceId, String deviceName);

  void onDeviceLost(String deviceId);
}

@HostApi()
abstract class AdvertiseApi {
  @async
  int startAdvertise(String verificationCode);

  @async
  int stopAdvertise();
}

@HostApi()
abstract class CommunicationApi {
  @async
  int sendMessage(String toDeviceId, String endpoint, String payload);

  @async
  int sendMessageToVerifiedDevice(String endpoint, String data);
}

@FlutterApi()
abstract class CommunicationCallbackApi {
  void onMessageReceived(DataMessage msg);

  void onRawMessageReceived(String deviceId, String msg);
}

@FlutterApi()
abstract class StateCallbackApi {
  void onBluetoothStateChanged(StateResponse state);

  void onWifiStateChanged(StateResponse state);
}
