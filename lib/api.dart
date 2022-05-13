// Autogenerated from Pigeon (v1.0.19), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name
// @dart = 2.12
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

enum NearbyStrategy {
  p2pCluster,
  p2pStar,
  p2pPointToPoint,
}

enum Provider {
  gatt,
  nearby,
}

enum State {
  on,
  off,
  unknown,
}

class ServerConfig {
  ServerConfig({
    this.name,
    this.strategy,
    this.allowMultipleVerifiedDevice,
  });

  String? name;
  NearbyStrategy? strategy;
  bool? allowMultipleVerifiedDevice;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['name'] = name;
    pigeonMap['strategy'] = strategy == null ? null : strategy!.index;
    pigeonMap['allowMultipleVerifiedDevice'] = allowMultipleVerifiedDevice;
    return pigeonMap;
  }

  static ServerConfig decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return ServerConfig(
      name: pigeonMap['name'] as String?,
      strategy: pigeonMap['strategy'] != null
          ? NearbyStrategy.values[pigeonMap['strategy']! as int]
          : null,
      allowMultipleVerifiedDevice: pigeonMap['allowMultipleVerifiedDevice'] as bool?,
    );
  }
}

class DataMessage {
  DataMessage({
    this.deviceId,
    this.provider,
    this.endpoint,
    this.data,
  });

  String? deviceId;
  Provider? provider;
  String? endpoint;
  String? data;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['deviceId'] = deviceId;
    pigeonMap['provider'] = provider == null ? null : provider!.index;
    pigeonMap['endpoint'] = endpoint;
    pigeonMap['data'] = data;
    return pigeonMap;
  }

  static DataMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return DataMessage(
      deviceId: pigeonMap['deviceId'] as String?,
      provider: pigeonMap['provider'] != null
          ? Provider.values[pigeonMap['provider']! as int]
          : null,
      endpoint: pigeonMap['endpoint'] as String?,
      data: pigeonMap['data'] as String?,
    );
  }
}

class ConnectedDevice {
  ConnectedDevice({
    this.deviceId,
    this.provider,
  });

  String? deviceId;
  Provider? provider;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['deviceId'] = deviceId;
    pigeonMap['provider'] = provider == null ? null : provider!.index;
    return pigeonMap;
  }

  static ConnectedDevice decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return ConnectedDevice(
      deviceId: pigeonMap['deviceId'] as String?,
      provider: pigeonMap['provider'] != null
          ? Provider.values[pigeonMap['provider']! as int]
          : null,
    );
  }
}

class StateResponse {
  StateResponse({
    this.state,
  });

  State? state;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['state'] = state == null ? null : state!.index;
    return pigeonMap;
  }

  static StateResponse decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return StateResponse(
      state: pigeonMap['state'] != null
          ? State.values[pigeonMap['state']! as int]
          : null,
    );
  }
}

class _ServerApiCodec extends StandardMessageCodec {
  const _ServerApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is ServerConfig) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else 
{
      super.writeValue(buffer, value);
    }
  }
  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:       
        return ServerConfig.decode(readValue(buffer)!);
      
      default:      
        return super.readValueOfType(type, buffer);
      
    }
  }
}

class ServerApi {
  /// Constructor for [ServerApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  ServerApi({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _ServerApiCodec();

  Future<void> startServer(ServerConfig arg_config) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ServerApi.startServer', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[arg_config]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<void> stopServer() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ServerApi.stopServer', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }
}

class _ClientApiCodec extends StandardMessageCodec {
  const _ClientApiCodec();
}

class ClientApi {
  /// Constructor for [ClientApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  ClientApi({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _ClientApiCodec();

  Future<void> startDiscovery() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ClientApi.startDiscovery', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<void> stopDiscovery() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.ClientApi.stopDiscovery', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }
}

class _CommunicationApiCodec extends StandardMessageCodec {
  const _CommunicationApiCodec();
}

class CommunicationApi {
  /// Constructor for [CommunicationApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  CommunicationApi({BinaryMessenger? binaryMessenger}) : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _CommunicationApiCodec();

  Future<void> startAdvertise() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.CommunicationApi.startAdvertise', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<void> stopAdvertise() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.CommunicationApi.stopAdvertise', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<void> sendMessage(String arg_toDeviceId, String arg_endpoint, String arg_payload) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.CommunicationApi.sendMessage', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[arg_toDeviceId, arg_endpoint, arg_payload]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<void> sendMessageToVerifiedDevice(String arg_endpoint, String arg_data) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.CommunicationApi.sendMessageToVerifiedDevice', codec, binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[arg_endpoint, arg_data]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error = (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }
}

class _CommunicationCallbackApiCodec extends StandardMessageCodec {
  const _CommunicationCallbackApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is ConnectedDevice) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else 
    if (value is DataMessage) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else 
{
      super.writeValue(buffer, value);
    }
  }
  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:       
        return ConnectedDevice.decode(readValue(buffer)!);
      
      case 129:       
        return DataMessage.decode(readValue(buffer)!);
      
      default:      
        return super.readValueOfType(type, buffer);
      
    }
  }
}
abstract class CommunicationCallbackApi {
  static const MessageCodec<Object?> codec = _CommunicationCallbackApiCodec();

  bool onDeviceConnected(ConnectedDevice device);
  void onDeviceDisconnected(ConnectedDevice device);
  void onMessageReceived(DataMessage msg);
  void onRawMessageReceived(String deviceId, String msg);
  static void setup(CommunicationCallbackApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CommunicationCallbackApi.onDeviceConnected', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onDeviceConnected was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final ConnectedDevice? arg_device = (args[0] as ConnectedDevice?);
          assert(arg_device != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onDeviceConnected was null, expected non-null ConnectedDevice.');
          final bool output = api.onDeviceConnected(arg_device!);
          return output;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CommunicationCallbackApi.onDeviceDisconnected', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onDeviceDisconnected was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final ConnectedDevice? arg_device = (args[0] as ConnectedDevice?);
          assert(arg_device != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onDeviceDisconnected was null, expected non-null ConnectedDevice.');
          api.onDeviceDisconnected(arg_device!);
          return;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CommunicationCallbackApi.onMessageReceived', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onMessageReceived was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final DataMessage? arg_msg = (args[0] as DataMessage?);
          assert(arg_msg != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onMessageReceived was null, expected non-null DataMessage.');
          api.onMessageReceived(arg_msg!);
          return;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_deviceId = (args[0] as String?);
          assert(arg_deviceId != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived was null, expected non-null String.');
          final String? arg_msg = (args[1] as String?);
          assert(arg_msg != null, 'Argument for dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived was null, expected non-null String.');
          api.onRawMessageReceived(arg_deviceId!, arg_msg!);
          return;
        });
      }
    }
  }
}

class _StateCallbackApiCodec extends StandardMessageCodec {
  const _StateCallbackApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is StateResponse) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else 
{
      super.writeValue(buffer, value);
    }
  }
  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:       
        return StateResponse.decode(readValue(buffer)!);
      
      default:      
        return super.readValueOfType(type, buffer);
      
    }
  }
}
abstract class StateCallbackApi {
  static const MessageCodec<Object?> codec = _StateCallbackApiCodec();

  void onBluetoothStateChanged(StateResponse state);
  void onWifiStateChanged(StateResponse state);
  static void setup(StateCallbackApi? api, {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.StateCallbackApi.onBluetoothStateChanged', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.StateCallbackApi.onBluetoothStateChanged was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final StateResponse? arg_state = (args[0] as StateResponse?);
          assert(arg_state != null, 'Argument for dev.flutter.pigeon.StateCallbackApi.onBluetoothStateChanged was null, expected non-null StateResponse.');
          api.onBluetoothStateChanged(arg_state!);
          return;
        });
      }
    }
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.StateCallbackApi.onWifiStateChanged', codec, binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null, 'Argument for dev.flutter.pigeon.StateCallbackApi.onWifiStateChanged was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final StateResponse? arg_state = (args[0] as StateResponse?);
          assert(arg_state != null, 'Argument for dev.flutter.pigeon.StateCallbackApi.onWifiStateChanged was null, expected non-null StateResponse.');
          api.onWifiStateChanged(arg_state!);
          return;
        });
      }
    }
  }
}
