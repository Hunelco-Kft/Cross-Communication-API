// Autogenerated from Pigeon (v1.0.19), do not edit directly.
// See also: https://pub.dev/packages/pigeon

package io.flutter.plugins;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/** Generated class from Pigeon. */
@SuppressWarnings({"unused", "unchecked", "CodeBlock2Expr", "RedundantSuppression"})
public class Pigeon {

  public enum NearbyStrategy {
    p2pCluster(0),
    p2pStar(1),
    p2pPointToPoint(2);

    private int index;
    private NearbyStrategy(final int index) {
      this.index = index;
    }
  }

  public enum Provider {
    gatt(0),
    nearby(1);

    private int index;
    private Provider(final int index) {
      this.index = index;
    }
  }

  public enum State {
    on(0),
    off(1),
    unknown(2);

    private int index;
    private State(final int index) {
      this.index = index;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class Config {
    private @Nullable String name;
    public @Nullable String getName() { return name; }
    public void setName(@Nullable String setterArg) {
      this.name = setterArg;
    }

    private @Nullable NearbyStrategy strategy;
    public @Nullable NearbyStrategy getStrategy() { return strategy; }
    public void setStrategy(@Nullable NearbyStrategy setterArg) {
      this.strategy = setterArg;
    }

    private @Nullable Boolean allowMultipleVerifiedDevice;
    public @Nullable Boolean getAllowMultipleVerifiedDevice() { return allowMultipleVerifiedDevice; }
    public void setAllowMultipleVerifiedDevice(@Nullable Boolean setterArg) {
      this.allowMultipleVerifiedDevice = setterArg;
    }

    public static class Builder {
      private @Nullable String name;
      public @NonNull Builder setName(@Nullable String setterArg) {
        this.name = setterArg;
        return this;
      }
      private @Nullable NearbyStrategy strategy;
      public @NonNull Builder setStrategy(@Nullable NearbyStrategy setterArg) {
        this.strategy = setterArg;
        return this;
      }
      private @Nullable Boolean allowMultipleVerifiedDevice;
      public @NonNull Builder setAllowMultipleVerifiedDevice(@Nullable Boolean setterArg) {
        this.allowMultipleVerifiedDevice = setterArg;
        return this;
      }
      public @NonNull Config build() {
        Config pigeonReturn = new Config();
        pigeonReturn.setName(name);
        pigeonReturn.setStrategy(strategy);
        pigeonReturn.setAllowMultipleVerifiedDevice(allowMultipleVerifiedDevice);
        return pigeonReturn;
      }
    }
    @NonNull Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("name", name);
      toMapResult.put("strategy", strategy == null ? null : strategy.index);
      toMapResult.put("allowMultipleVerifiedDevice", allowMultipleVerifiedDevice);
      return toMapResult;
    }
    static @NonNull Config fromMap(@NonNull Map<String, Object> map) {
      Config pigeonResult = new Config();
      Object name = map.get("name");
      pigeonResult.setName((String)name);
      Object strategy = map.get("strategy");
      pigeonResult.setStrategy(strategy == null ? null : NearbyStrategy.values()[(int)strategy]);
      Object allowMultipleVerifiedDevice = map.get("allowMultipleVerifiedDevice");
      pigeonResult.setAllowMultipleVerifiedDevice((Boolean)allowMultipleVerifiedDevice);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class DataMessage {
    private @Nullable String deviceId;
    public @Nullable String getDeviceId() { return deviceId; }
    public void setDeviceId(@Nullable String setterArg) {
      this.deviceId = setterArg;
    }

    private @Nullable Provider provider;
    public @Nullable Provider getProvider() { return provider; }
    public void setProvider(@Nullable Provider setterArg) {
      this.provider = setterArg;
    }

    private @Nullable String endpoint;
    public @Nullable String getEndpoint() { return endpoint; }
    public void setEndpoint(@Nullable String setterArg) {
      this.endpoint = setterArg;
    }

    private @Nullable String data;
    public @Nullable String getData() { return data; }
    public void setData(@Nullable String setterArg) {
      this.data = setterArg;
    }

    public static class Builder {
      private @Nullable String deviceId;
      public @NonNull Builder setDeviceId(@Nullable String setterArg) {
        this.deviceId = setterArg;
        return this;
      }
      private @Nullable Provider provider;
      public @NonNull Builder setProvider(@Nullable Provider setterArg) {
        this.provider = setterArg;
        return this;
      }
      private @Nullable String endpoint;
      public @NonNull Builder setEndpoint(@Nullable String setterArg) {
        this.endpoint = setterArg;
        return this;
      }
      private @Nullable String data;
      public @NonNull Builder setData(@Nullable String setterArg) {
        this.data = setterArg;
        return this;
      }
      public @NonNull DataMessage build() {
        DataMessage pigeonReturn = new DataMessage();
        pigeonReturn.setDeviceId(deviceId);
        pigeonReturn.setProvider(provider);
        pigeonReturn.setEndpoint(endpoint);
        pigeonReturn.setData(data);
        return pigeonReturn;
      }
    }
    @NonNull Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("deviceId", deviceId);
      toMapResult.put("provider", provider == null ? null : provider.index);
      toMapResult.put("endpoint", endpoint);
      toMapResult.put("data", data);
      return toMapResult;
    }
    static @NonNull DataMessage fromMap(@NonNull Map<String, Object> map) {
      DataMessage pigeonResult = new DataMessage();
      Object deviceId = map.get("deviceId");
      pigeonResult.setDeviceId((String)deviceId);
      Object provider = map.get("provider");
      pigeonResult.setProvider(provider == null ? null : Provider.values()[(int)provider]);
      Object endpoint = map.get("endpoint");
      pigeonResult.setEndpoint((String)endpoint);
      Object data = map.get("data");
      pigeonResult.setData((String)data);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class ConnectedDevice {
    private @Nullable String deviceId;
    public @Nullable String getDeviceId() { return deviceId; }
    public void setDeviceId(@Nullable String setterArg) {
      this.deviceId = setterArg;
    }

    private @Nullable Provider provider;
    public @Nullable Provider getProvider() { return provider; }
    public void setProvider(@Nullable Provider setterArg) {
      this.provider = setterArg;
    }

    public static class Builder {
      private @Nullable String deviceId;
      public @NonNull Builder setDeviceId(@Nullable String setterArg) {
        this.deviceId = setterArg;
        return this;
      }
      private @Nullable Provider provider;
      public @NonNull Builder setProvider(@Nullable Provider setterArg) {
        this.provider = setterArg;
        return this;
      }
      public @NonNull ConnectedDevice build() {
        ConnectedDevice pigeonReturn = new ConnectedDevice();
        pigeonReturn.setDeviceId(deviceId);
        pigeonReturn.setProvider(provider);
        return pigeonReturn;
      }
    }
    @NonNull Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("deviceId", deviceId);
      toMapResult.put("provider", provider == null ? null : provider.index);
      return toMapResult;
    }
    static @NonNull ConnectedDevice fromMap(@NonNull Map<String, Object> map) {
      ConnectedDevice pigeonResult = new ConnectedDevice();
      Object deviceId = map.get("deviceId");
      pigeonResult.setDeviceId((String)deviceId);
      Object provider = map.get("provider");
      pigeonResult.setProvider(provider == null ? null : Provider.values()[(int)provider]);
      return pigeonResult;
    }
  }

  /** Generated class from Pigeon that represents data sent in messages. */
  public static class StateResponse {
    private @Nullable State state;
    public @Nullable State getState() { return state; }
    public void setState(@Nullable State setterArg) {
      this.state = setterArg;
    }

    public static class Builder {
      private @Nullable State state;
      public @NonNull Builder setState(@Nullable State setterArg) {
        this.state = setterArg;
        return this;
      }
      public @NonNull StateResponse build() {
        StateResponse pigeonReturn = new StateResponse();
        pigeonReturn.setState(state);
        return pigeonReturn;
      }
    }
    @NonNull Map<String, Object> toMap() {
      Map<String, Object> toMapResult = new HashMap<>();
      toMapResult.put("state", state == null ? null : state.index);
      return toMapResult;
    }
    static @NonNull StateResponse fromMap(@NonNull Map<String, Object> map) {
      StateResponse pigeonResult = new StateResponse();
      Object state = map.get("state");
      pigeonResult.setState(state == null ? null : State.values()[(int)state]);
      return pigeonResult;
    }
  }

  public interface Result<T> {
    void success(T result);
    void error(Throwable error);
  }
  private static class ServerApiCodec extends StandardMessageCodec {
    public static final ServerApiCodec INSTANCE = new ServerApiCodec();
    private ServerApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return Config.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof Config) {
        stream.write(128);
        writeValue(stream, ((Config) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface ServerApi {
    @NonNull void startServer(Config config);
    @NonNull void stopServer();

    /** The codec used by ServerApi. */
    static MessageCodec<Object> getCodec() {
      return ServerApiCodec.INSTANCE;
    }

    /** Sets up an instance of `ServerApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, ServerApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ServerApi.startServer", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              Config configArg = (Config)args.get(0);
              if (configArg == null) {
                throw new NullPointerException("configArg unexpectedly null.");
              }
              api.startServer(configArg);
              wrapped.put("result", null);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ServerApi.stopServer", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              api.stopServer();
              wrapped.put("result", null);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class ClientApiCodec extends StandardMessageCodec {
    public static final ClientApiCodec INSTANCE = new ClientApiCodec();
    private ClientApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return Config.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof Config) {
        stream.write(128);
        writeValue(stream, ((Config) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface ClientApi {
    @NonNull void startServer(Config config);

    /** The codec used by ClientApi. */
    static MessageCodec<Object> getCodec() {
      return ClientApiCodec.INSTANCE;
    }

    /** Sets up an instance of `ClientApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, ClientApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ClientApi.startServer", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              Config configArg = (Config)args.get(0);
              if (configArg == null) {
                throw new NullPointerException("configArg unexpectedly null.");
              }
              api.startServer(configArg);
              wrapped.put("result", null);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
            }
            reply.reply(wrapped);
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class ConnectionApiCodec extends StandardMessageCodec {
    public static final ConnectionApiCodec INSTANCE = new ConnectionApiCodec();
    private ConnectionApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return ConnectedDevice.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof ConnectedDevice) {
        stream.write(128);
        writeValue(stream, ((ConnectedDevice) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface ConnectionApi {
    void connect(String endpointId, String displayName, Result<ConnectedDevice> result);
    void disconnect(String id, Result<Long> result);

    /** The codec used by ConnectionApi. */
    static MessageCodec<Object> getCodec() {
      return ConnectionApiCodec.INSTANCE;
    }

    /** Sets up an instance of `ConnectionApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, ConnectionApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ConnectionApi.connect", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              String endpointIdArg = (String)args.get(0);
              if (endpointIdArg == null) {
                throw new NullPointerException("endpointIdArg unexpectedly null.");
              }
              String displayNameArg = (String)args.get(1);
              if (displayNameArg == null) {
                throw new NullPointerException("displayNameArg unexpectedly null.");
              }
              Result<ConnectedDevice> resultCallback = new Result<ConnectedDevice>() {
                public void success(ConnectedDevice result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.connect(endpointIdArg, displayNameArg, resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ConnectionApi.disconnect", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              String idArg = (String)args.get(0);
              if (idArg == null) {
                throw new NullPointerException("idArg unexpectedly null.");
              }
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.disconnect(idArg, resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class ConnectionCallbackApiCodec extends StandardMessageCodec {
    public static final ConnectionCallbackApiCodec INSTANCE = new ConnectionCallbackApiCodec();
    private ConnectionCallbackApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return ConnectedDevice.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof ConnectedDevice) {
        stream.write(128);
        writeValue(stream, ((ConnectedDevice) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/
  public static class ConnectionCallbackApi {
    private final BinaryMessenger binaryMessenger;
    public ConnectionCallbackApi(BinaryMessenger argBinaryMessenger){
      this.binaryMessenger = argBinaryMessenger;
    }
    public interface Reply<T> {
      void reply(T reply);
    }
    static MessageCodec<Object> getCodec() {
      return ConnectionCallbackApiCodec.INSTANCE;
    }

    public void onDeviceConnected(ConnectedDevice deviceArg, Reply<Boolean> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ConnectionCallbackApi.onDeviceConnected", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(deviceArg)), channelReply -> {
        @SuppressWarnings("ConstantConditions")
        Boolean output = (Boolean)channelReply;
        callback.reply(output);
      });
    }
    public void onDeviceDisconnected(ConnectedDevice deviceArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.ConnectionCallbackApi.onDeviceDisconnected", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(deviceArg)), channelReply -> {
        callback.reply(null);
      });
    }
  }
  private static class DiscoveryApiCodec extends StandardMessageCodec {
    public static final DiscoveryApiCodec INSTANCE = new DiscoveryApiCodec();
    private DiscoveryApiCodec() {}
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface DiscoveryApi {
    void startDiscovery(Result<Long> result);
    void stopDiscovery(Result<Long> result);

    /** The codec used by DiscoveryApi. */
    static MessageCodec<Object> getCodec() {
      return DiscoveryApiCodec.INSTANCE;
    }

    /** Sets up an instance of `DiscoveryApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, DiscoveryApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.DiscoveryApi.startDiscovery", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.startDiscovery(resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.DiscoveryApi.stopDiscovery", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.stopDiscovery(resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class DiscoveryCallbackApiCodec extends StandardMessageCodec {
    public static final DiscoveryCallbackApiCodec INSTANCE = new DiscoveryCallbackApiCodec();
    private DiscoveryCallbackApiCodec() {}
  }

  /** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/
  public static class DiscoveryCallbackApi {
    private final BinaryMessenger binaryMessenger;
    public DiscoveryCallbackApi(BinaryMessenger argBinaryMessenger){
      this.binaryMessenger = argBinaryMessenger;
    }
    public interface Reply<T> {
      void reply(T reply);
    }
    static MessageCodec<Object> getCodec() {
      return DiscoveryCallbackApiCodec.INSTANCE;
    }

    public void onDeviceDiscovered(String deviceIdArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.DiscoveryCallbackApi.onDeviceDiscovered", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(deviceIdArg)), channelReply -> {
        callback.reply(null);
      });
    }
    public void onDeviceLost(String deviceIdArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.DiscoveryCallbackApi.onDeviceLost", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(deviceIdArg)), channelReply -> {
        callback.reply(null);
      });
    }
  }
  private static class AdvertiseApiCodec extends StandardMessageCodec {
    public static final AdvertiseApiCodec INSTANCE = new AdvertiseApiCodec();
    private AdvertiseApiCodec() {}
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface AdvertiseApi {
    void startAdvertise(Result<Long> result);
    void stopAdvertise(Result<Long> result);

    /** The codec used by AdvertiseApi. */
    static MessageCodec<Object> getCodec() {
      return AdvertiseApiCodec.INSTANCE;
    }

    /** Sets up an instance of `AdvertiseApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, AdvertiseApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.AdvertiseApi.startAdvertise", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.startAdvertise(resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.AdvertiseApi.stopAdvertise", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.stopAdvertise(resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class CommunicationApiCodec extends StandardMessageCodec {
    public static final CommunicationApiCodec INSTANCE = new CommunicationApiCodec();
    private CommunicationApiCodec() {}
  }

  /** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
  public interface CommunicationApi {
    void sendMessage(String toDeviceId, String endpoint, String payload, Result<Long> result);
    void sendMessageToVerifiedDevice(String endpoint, String data, Result<Long> result);

    /** The codec used by CommunicationApi. */
    static MessageCodec<Object> getCodec() {
      return CommunicationApiCodec.INSTANCE;
    }

    /** Sets up an instance of `CommunicationApi` to handle messages through the `binaryMessenger`. */
    static void setup(BinaryMessenger binaryMessenger, CommunicationApi api) {
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.CommunicationApi.sendMessage", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              String toDeviceIdArg = (String)args.get(0);
              if (toDeviceIdArg == null) {
                throw new NullPointerException("toDeviceIdArg unexpectedly null.");
              }
              String endpointArg = (String)args.get(1);
              if (endpointArg == null) {
                throw new NullPointerException("endpointArg unexpectedly null.");
              }
              String payloadArg = (String)args.get(2);
              if (payloadArg == null) {
                throw new NullPointerException("payloadArg unexpectedly null.");
              }
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.sendMessage(toDeviceIdArg, endpointArg, payloadArg, resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
      {
        BasicMessageChannel<Object> channel =
            new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.CommunicationApi.sendMessageToVerifiedDevice", getCodec());
        if (api != null) {
          channel.setMessageHandler((message, reply) -> {
            Map<String, Object> wrapped = new HashMap<>();
            try {
              ArrayList<Object> args = (ArrayList<Object>)message;
              String endpointArg = (String)args.get(0);
              if (endpointArg == null) {
                throw new NullPointerException("endpointArg unexpectedly null.");
              }
              String dataArg = (String)args.get(1);
              if (dataArg == null) {
                throw new NullPointerException("dataArg unexpectedly null.");
              }
              Result<Long> resultCallback = new Result<Long>() {
                public void success(Long result) {
                  wrapped.put("result", result);
                  reply.reply(wrapped);
                }
                public void error(Throwable error) {
                  wrapped.put("error", wrapError(error));
                  reply.reply(wrapped);
                }
              };

              api.sendMessageToVerifiedDevice(endpointArg, dataArg, resultCallback);
            }
            catch (Error | RuntimeException exception) {
              wrapped.put("error", wrapError(exception));
              reply.reply(wrapped);
            }
          });
        } else {
          channel.setMessageHandler(null);
        }
      }
    }
  }
  private static class CommunicationCallbackApiCodec extends StandardMessageCodec {
    public static final CommunicationCallbackApiCodec INSTANCE = new CommunicationCallbackApiCodec();
    private CommunicationCallbackApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return DataMessage.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof DataMessage) {
        stream.write(128);
        writeValue(stream, ((DataMessage) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/
  public static class CommunicationCallbackApi {
    private final BinaryMessenger binaryMessenger;
    public CommunicationCallbackApi(BinaryMessenger argBinaryMessenger){
      this.binaryMessenger = argBinaryMessenger;
    }
    public interface Reply<T> {
      void reply(T reply);
    }
    static MessageCodec<Object> getCodec() {
      return CommunicationCallbackApiCodec.INSTANCE;
    }

    public void onMessageReceived(DataMessage msgArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.CommunicationCallbackApi.onMessageReceived", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(msgArg)), channelReply -> {
        callback.reply(null);
      });
    }
    public void onRawMessageReceived(String deviceIdArg, String msgArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(deviceIdArg, msgArg)), channelReply -> {
        callback.reply(null);
      });
    }
  }
  private static class StateCallbackApiCodec extends StandardMessageCodec {
    public static final StateCallbackApiCodec INSTANCE = new StateCallbackApiCodec();
    private StateCallbackApiCodec() {}
    @Override
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
      switch (type) {
        case (byte)128:         
          return StateResponse.fromMap((Map<String, Object>) readValue(buffer));
        
        default:        
          return super.readValueOfType(type, buffer);
        
      }
    }
    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value)     {
      if (value instanceof StateResponse) {
        stream.write(128);
        writeValue(stream, ((StateResponse) value).toMap());
      } else 
{
        super.writeValue(stream, value);
      }
    }
  }

  /** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/
  public static class StateCallbackApi {
    private final BinaryMessenger binaryMessenger;
    public StateCallbackApi(BinaryMessenger argBinaryMessenger){
      this.binaryMessenger = argBinaryMessenger;
    }
    public interface Reply<T> {
      void reply(T reply);
    }
    static MessageCodec<Object> getCodec() {
      return StateCallbackApiCodec.INSTANCE;
    }

    public void onBluetoothStateChanged(StateResponse stateArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.StateCallbackApi.onBluetoothStateChanged", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(stateArg)), channelReply -> {
        callback.reply(null);
      });
    }
    public void onWifiStateChanged(StateResponse stateArg, Reply<Void> callback) {
      BasicMessageChannel<Object> channel =
          new BasicMessageChannel<>(binaryMessenger, "dev.flutter.pigeon.StateCallbackApi.onWifiStateChanged", getCodec());
      channel.send(new ArrayList<Object>(Arrays.asList(stateArg)), channelReply -> {
        callback.reply(null);
      });
    }
  }
  private static Map<String, Object> wrapError(Throwable exception) {
    Map<String, Object> errorMap = new HashMap<>();
    errorMap.put("message", exception.toString());
    errorMap.put("code", exception.getClass().getSimpleName());
    errorMap.put("details", "Cause: " + exception.getCause() + ", Stacktrace: " + Log.getStackTraceString(exception));
    return errorMap;
  }
}
