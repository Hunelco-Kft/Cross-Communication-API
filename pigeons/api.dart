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

@HostApi()
abstract class ServerApi {
  // It starts the server if it is not started yet as a foreground service
  void startServer(Config config);

  void stopServer();
}

@HostApi()
abstract class ConnectionApi {
  @async
  ConnectedDevice connect(String endpointId, String displayName);

  @async
  void disconnect(String id);
}

@FlutterApi()
abstract class ConnectionCallbackApi {
  bool onDeviceConnected(ConnectedDevice device);

  void onDeviceDisconnected(ConnectedDevice device);
}

@HostApi()
abstract class DiscoveryApi {
  @async
  void startDiscovery();

  @async
  void stopDiscovery();
}

@HostApi()
abstract class AdvertiseApi {
  @async
  void startAdvertise();

  @async
  void stopAdvertise();
}

@HostApi()
abstract class CommunicationApi {
  @async
  void sendMessage(String toDeviceId, String endpoint, String payload);

  @async
  void sendMessageToVerifiedDevice(String endpoint, String data);
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
