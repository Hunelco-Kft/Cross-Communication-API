// Autogenerated from Pigeon (v1.0.19), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FLTNearbyStrategy) {
  FLTNearbyStrategyP2pCluster = 0,
  FLTNearbyStrategyP2pStar = 1,
  FLTNearbyStrategyP2pPointToPoint = 2,
};

typedef NS_ENUM(NSUInteger, FLTProvider) {
  FLTProviderGatt = 0,
  FLTProviderNearby = 1,
};

typedef NS_ENUM(NSUInteger, FLTState) {
  FLTStateOn = 0,
  FLTStateOff = 1,
  FLTStateUnknown = 2,
};

@class FLTConfig;
@class FLTDataMessage;
@class FLTConnectedDevice;
@class FLTStateResponse;

@interface FLTConfig : NSObject
+ (instancetype)makeWithName:(nullable NSString *)name
    strategy:(FLTNearbyStrategy)strategy
    allowMultipleVerifiedDevice:(nullable NSNumber *)allowMultipleVerifiedDevice;
@property(nonatomic, copy, nullable) NSString * name;
@property(nonatomic, assign) FLTNearbyStrategy strategy;
@property(nonatomic, strong, nullable) NSNumber * allowMultipleVerifiedDevice;
@end

@interface FLTDataMessage : NSObject
+ (instancetype)makeWithDeviceId:(nullable NSString *)deviceId
    provider:(FLTProvider)provider
    endpoint:(nullable NSString *)endpoint
    data:(nullable NSString *)data;
@property(nonatomic, copy, nullable) NSString * deviceId;
@property(nonatomic, assign) FLTProvider provider;
@property(nonatomic, copy, nullable) NSString * endpoint;
@property(nonatomic, copy, nullable) NSString * data;
@end

@interface FLTConnectedDevice : NSObject
+ (instancetype)makeWithDeviceId:(nullable NSString *)deviceId
    provider:(FLTProvider)provider;
@property(nonatomic, copy, nullable) NSString * deviceId;
@property(nonatomic, assign) FLTProvider provider;
@end

@interface FLTStateResponse : NSObject
+ (instancetype)makeWithState:(FLTState)state;
@property(nonatomic, assign) FLTState state;
@end

/// The codec used by FLTServerApi.
NSObject<FlutterMessageCodec> *FLTServerApiGetCodec(void);

@protocol FLTServerApi
/// @return `nil` only when `error != nil`.
- (void)startServerConfig:(FLTConfig *)config error:(FlutterError *_Nullable *_Nonnull)error;
/// @return `nil` only when `error != nil`.
- (void)stopServerWithError:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void FLTServerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTServerApi> *_Nullable api);

/// The codec used by FLTClientApi.
NSObject<FlutterMessageCodec> *FLTClientApiGetCodec(void);

@protocol FLTClientApi
/// @return `nil` only when `error != nil`.
- (void)startServerConfig:(FLTConfig *)config error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void FLTClientApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTClientApi> *_Nullable api);

/// The codec used by FLTConnectionApi.
NSObject<FlutterMessageCodec> *FLTConnectionApiGetCodec(void);

@protocol FLTConnectionApi
/// @return `nil` only when `error != nil`.
- (void)connectEndpointId:(nullable NSString *)endpointId displayName:(nullable NSString *)displayName completion:(void(^)(FLTConnectedDevice *_Nullable, FlutterError *_Nullable))completion;
/// @return `nil` only when `error != nil`.
- (void)disconnectId:(nullable NSString *)id completion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
@end

extern void FLTConnectionApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTConnectionApi> *_Nullable api);

/// The codec used by FLTConnectionCallbackApi.
NSObject<FlutterMessageCodec> *FLTConnectionCallbackApiGetCodec(void);

@interface FLTConnectionCallbackApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)onDeviceConnectedDevice:(FLTConnectedDevice *)device completion:(void(^)(NSNumber *_Nullable, NSError *_Nullable))completion;
- (void)onDeviceDisconnectedDevice:(FLTConnectedDevice *)device completion:(void(^)(NSError *_Nullable))completion;
@end
/// The codec used by FLTDiscoveryApi.
NSObject<FlutterMessageCodec> *FLTDiscoveryApiGetCodec(void);

@protocol FLTDiscoveryApi
/// @return `nil` only when `error != nil`.
- (void)startDiscoveryWithCompletion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// @return `nil` only when `error != nil`.
- (void)stopDiscoveryWithCompletion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
@end

extern void FLTDiscoveryApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTDiscoveryApi> *_Nullable api);

/// The codec used by FLTDiscoveryCallbackApi.
NSObject<FlutterMessageCodec> *FLTDiscoveryCallbackApiGetCodec(void);

@interface FLTDiscoveryCallbackApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)onDeviceDiscoveredDeviceId:(NSString *)deviceId completion:(void(^)(NSError *_Nullable))completion;
- (void)onDeviceLostDeviceId:(NSString *)deviceId completion:(void(^)(NSError *_Nullable))completion;
@end
/// The codec used by FLTAdvertiseApi.
NSObject<FlutterMessageCodec> *FLTAdvertiseApiGetCodec(void);

@protocol FLTAdvertiseApi
/// @return `nil` only when `error != nil`.
- (void)startAdvertiseWithCompletion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// @return `nil` only when `error != nil`.
- (void)stopAdvertiseWithCompletion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
@end

extern void FLTAdvertiseApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTAdvertiseApi> *_Nullable api);

/// The codec used by FLTCommunicationApi.
NSObject<FlutterMessageCodec> *FLTCommunicationApiGetCodec(void);

@protocol FLTCommunicationApi
/// @return `nil` only when `error != nil`.
- (void)sendMessageToDeviceId:(nullable NSString *)toDeviceId endpoint:(nullable NSString *)endpoint payload:(nullable NSString *)payload completion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
/// @return `nil` only when `error != nil`.
- (void)sendMessageToVerifiedDeviceEndpoint:(nullable NSString *)endpoint data:(nullable NSString *)data completion:(void(^)(NSNumber *_Nullable, FlutterError *_Nullable))completion;
@end

extern void FLTCommunicationApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTCommunicationApi> *_Nullable api);

/// The codec used by FLTCommunicationCallbackApi.
NSObject<FlutterMessageCodec> *FLTCommunicationCallbackApiGetCodec(void);

@interface FLTCommunicationCallbackApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)onMessageReceivedMsg:(FLTDataMessage *)msg completion:(void(^)(NSError *_Nullable))completion;
- (void)onRawMessageReceivedDeviceId:(NSString *)deviceId msg:(NSString *)msg completion:(void(^)(NSError *_Nullable))completion;
@end
/// The codec used by FLTStateCallbackApi.
NSObject<FlutterMessageCodec> *FLTStateCallbackApiGetCodec(void);

@interface FLTStateCallbackApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)onBluetoothStateChangedState:(FLTStateResponse *)state completion:(void(^)(NSError *_Nullable))completion;
- (void)onWifiStateChangedState:(FLTStateResponse *)state completion:(void(^)(NSError *_Nullable))completion;
@end
NS_ASSUME_NONNULL_END
