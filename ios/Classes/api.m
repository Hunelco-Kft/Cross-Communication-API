// Autogenerated from Pigeon (v1.0.19), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "api.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ? error.code : [NSNull null]),
        @"message": (error.message ? error.message : [NSNull null]),
        @"details": (error.details ? error.details : [NSNull null]),
        };
  }
  return @{
      @"result": (result ? result : [NSNull null]),
      @"error": errorDict,
      };
}
static id GetNullableObject(NSDictionary* dict, id key) {
  id result = dict[key];
  return (result == [NSNull null]) ? nil : result;
}


@interface FLTConfig ()
+ (FLTConfig *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTDataMessage ()
+ (FLTDataMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTConnectedDevice ()
+ (FLTConnectedDevice *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTStateResponse ()
+ (FLTStateResponse *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation FLTConfig
+ (instancetype)makeWithName:(nullable NSString *)name
    strategy:(FLTNearbyStrategy)strategy
    allowMultipleVerifiedDevice:(nullable NSNumber *)allowMultipleVerifiedDevice {
  FLTConfig* pigeonResult = [[FLTConfig alloc] init];
  pigeonResult.name = name;
  pigeonResult.strategy = strategy;
  pigeonResult.allowMultipleVerifiedDevice = allowMultipleVerifiedDevice;
  return pigeonResult;
}
+ (FLTConfig *)fromMap:(NSDictionary *)dict {
  FLTConfig *pigeonResult = [[FLTConfig alloc] init];
  pigeonResult.name = GetNullableObject(dict, @"name");
  pigeonResult.strategy = [GetNullableObject(dict, @"strategy") integerValue];
  pigeonResult.allowMultipleVerifiedDevice = GetNullableObject(dict, @"allowMultipleVerifiedDevice");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.name ? self.name : [NSNull null]), @"name", @(self.strategy), @"strategy", (self.allowMultipleVerifiedDevice ? self.allowMultipleVerifiedDevice : [NSNull null]), @"allowMultipleVerifiedDevice", nil];
}
@end

@implementation FLTDataMessage
+ (instancetype)makeWithDeviceId:(nullable NSString *)deviceId
    provider:(FLTProvider)provider
    endpoint:(nullable NSString *)endpoint
    data:(nullable NSString *)data {
  FLTDataMessage* pigeonResult = [[FLTDataMessage alloc] init];
  pigeonResult.deviceId = deviceId;
  pigeonResult.provider = provider;
  pigeonResult.endpoint = endpoint;
  pigeonResult.data = data;
  return pigeonResult;
}
+ (FLTDataMessage *)fromMap:(NSDictionary *)dict {
  FLTDataMessage *pigeonResult = [[FLTDataMessage alloc] init];
  pigeonResult.deviceId = GetNullableObject(dict, @"deviceId");
  pigeonResult.provider = [GetNullableObject(dict, @"provider") integerValue];
  pigeonResult.endpoint = GetNullableObject(dict, @"endpoint");
  pigeonResult.data = GetNullableObject(dict, @"data");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.deviceId ? self.deviceId : [NSNull null]), @"deviceId", @(self.provider), @"provider", (self.endpoint ? self.endpoint : [NSNull null]), @"endpoint", (self.data ? self.data : [NSNull null]), @"data", nil];
}
@end

@implementation FLTConnectedDevice
+ (instancetype)makeWithDeviceId:(nullable NSString *)deviceId
    provider:(FLTProvider)provider {
  FLTConnectedDevice* pigeonResult = [[FLTConnectedDevice alloc] init];
  pigeonResult.deviceId = deviceId;
  pigeonResult.provider = provider;
  return pigeonResult;
}
+ (FLTConnectedDevice *)fromMap:(NSDictionary *)dict {
  FLTConnectedDevice *pigeonResult = [[FLTConnectedDevice alloc] init];
  pigeonResult.deviceId = GetNullableObject(dict, @"deviceId");
  pigeonResult.provider = [GetNullableObject(dict, @"provider") integerValue];
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.deviceId ? self.deviceId : [NSNull null]), @"deviceId", @(self.provider), @"provider", nil];
}
@end

@implementation FLTStateResponse
+ (instancetype)makeWithState:(FLTState)state {
  FLTStateResponse* pigeonResult = [[FLTStateResponse alloc] init];
  pigeonResult.state = state;
  return pigeonResult;
}
+ (FLTStateResponse *)fromMap:(NSDictionary *)dict {
  FLTStateResponse *pigeonResult = [[FLTStateResponse alloc] init];
  pigeonResult.state = [GetNullableObject(dict, @"state") integerValue];
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:@(self.state), @"state", nil];
}
@end

@interface FLTServerApiCodecReader : FlutterStandardReader
@end
@implementation FLTServerApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTConfig fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTServerApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTServerApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTConfig class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTServerApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTServerApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTServerApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTServerApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTServerApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTServerApiCodecReaderWriter *readerWriter = [[FLTServerApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTServerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTServerApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.ServerApi.startServer"
        binaryMessenger:binaryMessenger
        codec:FLTServerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startServerConfig:error:)], @"FLTServerApi api (%@) doesn't respond to @selector(startServerConfig:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTConfig *arg_config = args[0];
        FlutterError *error;
        [api startServerConfig:arg_config error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.ServerApi.stopServer"
        binaryMessenger:binaryMessenger
        codec:FLTServerApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(stopServerWithError:)], @"FLTServerApi api (%@) doesn't respond to @selector(stopServerWithError:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api stopServerWithError:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTClientApiCodecReader : FlutterStandardReader
@end
@implementation FLTClientApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTConfig fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTClientApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTClientApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTConfig class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTClientApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTClientApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTClientApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTClientApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTClientApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTClientApiCodecReaderWriter *readerWriter = [[FLTClientApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTClientApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTClientApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.ClientApi.startClient"
        binaryMessenger:binaryMessenger
        codec:FLTClientApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startClientConfig:error:)], @"FLTClientApi api (%@) doesn't respond to @selector(startClientConfig:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTConfig *arg_config = args[0];
        FlutterError *error;
        [api startClientConfig:arg_config error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTConnectionApiCodecReader : FlutterStandardReader
@end
@implementation FLTConnectionApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTConnectedDevice fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTConnectionApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTConnectionApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTConnectedDevice class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTConnectionApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTConnectionApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTConnectionApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTConnectionApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTConnectionApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTConnectionApiCodecReaderWriter *readerWriter = [[FLTConnectionApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTConnectionApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTConnectionApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.ConnectionApi.connect"
        binaryMessenger:binaryMessenger
        codec:FLTConnectionApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(connectEndpointId:displayName:completion:)], @"FLTConnectionApi api (%@) doesn't respond to @selector(connectEndpointId:displayName:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_endpointId = args[0];
        NSString *arg_displayName = args[1];
        [api connectEndpointId:arg_endpointId displayName:arg_displayName completion:^(FLTConnectedDevice *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.ConnectionApi.disconnect"
        binaryMessenger:binaryMessenger
        codec:FLTConnectionApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(disconnectId:completion:)], @"FLTConnectionApi api (%@) doesn't respond to @selector(disconnectId:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_id = args[0];
        [api disconnectId:arg_id completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTConnectionCallbackApiCodecReader : FlutterStandardReader
@end
@implementation FLTConnectionCallbackApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTConnectedDevice fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTConnectionCallbackApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTConnectionCallbackApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTConnectedDevice class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTConnectionCallbackApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTConnectionCallbackApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTConnectionCallbackApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTConnectionCallbackApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTConnectionCallbackApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTConnectionCallbackApiCodecReaderWriter *readerWriter = [[FLTConnectionCallbackApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


@interface FLTConnectionCallbackApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation FLTConnectionCallbackApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)onDeviceConnectedDevice:(FLTConnectedDevice *)arg_device completion:(void(^)(NSNumber *_Nullable, NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.ConnectionCallbackApi.onDeviceConnected"
      binaryMessenger:self.binaryMessenger
      codec:FLTConnectionCallbackApiGetCodec()];
  [channel sendMessage:@[arg_device] reply:^(id reply) {
    NSNumber *output = reply;
    completion(output, nil);
  }];
}
- (void)onDeviceDisconnectedDevice:(FLTConnectedDevice *)arg_device completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.ConnectionCallbackApi.onDeviceDisconnected"
      binaryMessenger:self.binaryMessenger
      codec:FLTConnectionCallbackApiGetCodec()];
  [channel sendMessage:@[arg_device] reply:^(id reply) {
    completion(nil);
  }];
}
@end
@interface FLTDiscoveryApiCodecReader : FlutterStandardReader
@end
@implementation FLTDiscoveryApiCodecReader
@end

@interface FLTDiscoveryApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTDiscoveryApiCodecWriter
@end

@interface FLTDiscoveryApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTDiscoveryApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTDiscoveryApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTDiscoveryApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTDiscoveryApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTDiscoveryApiCodecReaderWriter *readerWriter = [[FLTDiscoveryApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTDiscoveryApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTDiscoveryApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.DiscoveryApi.startDiscovery"
        binaryMessenger:binaryMessenger
        codec:FLTDiscoveryApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startDiscoveryWithCompletion:)], @"FLTDiscoveryApi api (%@) doesn't respond to @selector(startDiscoveryWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api startDiscoveryWithCompletion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.DiscoveryApi.stopDiscovery"
        binaryMessenger:binaryMessenger
        codec:FLTDiscoveryApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(stopDiscoveryWithCompletion:)], @"FLTDiscoveryApi api (%@) doesn't respond to @selector(stopDiscoveryWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api stopDiscoveryWithCompletion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTDiscoveryCallbackApiCodecReader : FlutterStandardReader
@end
@implementation FLTDiscoveryCallbackApiCodecReader
@end

@interface FLTDiscoveryCallbackApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTDiscoveryCallbackApiCodecWriter
@end

@interface FLTDiscoveryCallbackApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTDiscoveryCallbackApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTDiscoveryCallbackApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTDiscoveryCallbackApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTDiscoveryCallbackApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTDiscoveryCallbackApiCodecReaderWriter *readerWriter = [[FLTDiscoveryCallbackApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


@interface FLTDiscoveryCallbackApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation FLTDiscoveryCallbackApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)onDeviceDiscoveredDeviceId:(NSString *)arg_deviceId completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.DiscoveryCallbackApi.onDeviceDiscovered"
      binaryMessenger:self.binaryMessenger
      codec:FLTDiscoveryCallbackApiGetCodec()];
  [channel sendMessage:@[arg_deviceId] reply:^(id reply) {
    completion(nil);
  }];
}
- (void)onDeviceLostDeviceId:(NSString *)arg_deviceId completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.DiscoveryCallbackApi.onDeviceLost"
      binaryMessenger:self.binaryMessenger
      codec:FLTDiscoveryCallbackApiGetCodec()];
  [channel sendMessage:@[arg_deviceId] reply:^(id reply) {
    completion(nil);
  }];
}
@end
@interface FLTAdvertiseApiCodecReader : FlutterStandardReader
@end
@implementation FLTAdvertiseApiCodecReader
@end

@interface FLTAdvertiseApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTAdvertiseApiCodecWriter
@end

@interface FLTAdvertiseApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTAdvertiseApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTAdvertiseApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTAdvertiseApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTAdvertiseApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTAdvertiseApiCodecReaderWriter *readerWriter = [[FLTAdvertiseApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTAdvertiseApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTAdvertiseApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.AdvertiseApi.startAdvertise"
        binaryMessenger:binaryMessenger
        codec:FLTAdvertiseApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(startAdvertiseWithCompletion:)], @"FLTAdvertiseApi api (%@) doesn't respond to @selector(startAdvertiseWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api startAdvertiseWithCompletion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.AdvertiseApi.stopAdvertise"
        binaryMessenger:binaryMessenger
        codec:FLTAdvertiseApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(stopAdvertiseWithCompletion:)], @"FLTAdvertiseApi api (%@) doesn't respond to @selector(stopAdvertiseWithCompletion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        [api stopAdvertiseWithCompletion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTCommunicationApiCodecReader : FlutterStandardReader
@end
@implementation FLTCommunicationApiCodecReader
@end

@interface FLTCommunicationApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTCommunicationApiCodecWriter
@end

@interface FLTCommunicationApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTCommunicationApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTCommunicationApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTCommunicationApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTCommunicationApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTCommunicationApiCodecReaderWriter *readerWriter = [[FLTCommunicationApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTCommunicationApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTCommunicationApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.CommunicationApi.sendMessage"
        binaryMessenger:binaryMessenger
        codec:FLTCommunicationApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(sendMessageToDeviceId:endpoint:payload:completion:)], @"FLTCommunicationApi api (%@) doesn't respond to @selector(sendMessageToDeviceId:endpoint:payload:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_toDeviceId = args[0];
        NSString *arg_endpoint = args[1];
        NSString *arg_payload = args[2];
        [api sendMessageToDeviceId:arg_toDeviceId endpoint:arg_endpoint payload:arg_payload completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.CommunicationApi.sendMessageToVerifiedDevice"
        binaryMessenger:binaryMessenger
        codec:FLTCommunicationApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(sendMessageToVerifiedDeviceEndpoint:data:completion:)], @"FLTCommunicationApi api (%@) doesn't respond to @selector(sendMessageToVerifiedDeviceEndpoint:data:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSString *arg_endpoint = args[0];
        NSString *arg_data = args[1];
        [api sendMessageToVerifiedDeviceEndpoint:arg_endpoint data:arg_data completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
@interface FLTCommunicationCallbackApiCodecReader : FlutterStandardReader
@end
@implementation FLTCommunicationCallbackApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTDataMessage fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTCommunicationCallbackApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTCommunicationCallbackApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTDataMessage class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTCommunicationCallbackApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTCommunicationCallbackApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTCommunicationCallbackApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTCommunicationCallbackApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTCommunicationCallbackApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTCommunicationCallbackApiCodecReaderWriter *readerWriter = [[FLTCommunicationCallbackApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


@interface FLTCommunicationCallbackApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation FLTCommunicationCallbackApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)onMessageReceivedMsg:(FLTDataMessage *)arg_msg completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.CommunicationCallbackApi.onMessageReceived"
      binaryMessenger:self.binaryMessenger
      codec:FLTCommunicationCallbackApiGetCodec()];
  [channel sendMessage:@[arg_msg] reply:^(id reply) {
    completion(nil);
  }];
}
- (void)onRawMessageReceivedDeviceId:(NSString *)arg_deviceId msg:(NSString *)arg_msg completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.CommunicationCallbackApi.onRawMessageReceived"
      binaryMessenger:self.binaryMessenger
      codec:FLTCommunicationCallbackApiGetCodec()];
  [channel sendMessage:@[arg_deviceId, arg_msg] reply:^(id reply) {
    completion(nil);
  }];
}
@end
@interface FLTStateCallbackApiCodecReader : FlutterStandardReader
@end
@implementation FLTStateCallbackApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTStateResponse fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTStateCallbackApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTStateCallbackApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTStateResponse class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTStateCallbackApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTStateCallbackApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTStateCallbackApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTStateCallbackApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTStateCallbackApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTStateCallbackApiCodecReaderWriter *readerWriter = [[FLTStateCallbackApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


@interface FLTStateCallbackApi ()
@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation FLTStateCallbackApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)onBluetoothStateChangedState:(FLTStateResponse *)arg_state completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.StateCallbackApi.onBluetoothStateChanged"
      binaryMessenger:self.binaryMessenger
      codec:FLTStateCallbackApiGetCodec()];
  [channel sendMessage:@[arg_state] reply:^(id reply) {
    completion(nil);
  }];
}
- (void)onWifiStateChangedState:(FLTStateResponse *)arg_state completion:(void(^)(NSError *_Nullable))completion {
  FlutterBasicMessageChannel *channel =
    [FlutterBasicMessageChannel
      messageChannelWithName:@"dev.flutter.pigeon.StateCallbackApi.onWifiStateChanged"
      binaryMessenger:self.binaryMessenger
      codec:FLTStateCallbackApiGetCodec()];
  [channel sendMessage:@[arg_state] reply:^(id reply) {
    completion(nil);
  }];
}
@end
