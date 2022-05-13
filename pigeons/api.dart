import 'package:pigeon/pigeon.dart';

enum NearbyStrategy { p2pCluster, p2pStar, p2pPointToPoint }

enum Provider { gatt, nearby }

enum State { on, off, unknown }

class ServerConfig {
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
  void startServer(ServerConfig config);

  void stopServer();
}

@HostApi()
abstract class ClientApi {
  void startDiscovery();

  void stopDiscovery();
}

@HostApi()
abstract class CommunicationApi {
  @async
  void startAdvertise();

  @async
  void stopAdvertise();

  @async
  void sendMessage(String toDeviceId, String endpoint, String payload);

  @async
  void sendMessageToVerifiedDevice(String endpoint, String data);
}

@FlutterApi()
abstract class CommunicationCallbackApi {
  bool onDeviceConnected(ConnectedDevice device);

  void onDeviceDisconnected(ConnectedDevice device);

  void onMessageReceived(DataMessage msg);

  void onRawMessageReceived(String deviceId, String msg);
}

@FlutterApi()
abstract class StateCallbackApi {
  void onBluetoothStateChanged(StateResponse state);

  void onWifiStateChanged(StateResponse state);
}
