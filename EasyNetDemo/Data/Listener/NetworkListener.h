//
//  NetworkListener.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2020/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const NetworkListenerDidChangeStateNotification;

@class NetworkListener;

typedef NS_ENUM(NSInteger, NetworkListenerStatus) {
    NetworkListenerStatusUnknown = -1,
    NetworkListenerStatusNotReachable = 0,
    NetworkListenerStatusViaWWAN = 1,
    NetworkListenerStatusViaWiFi = 2,
};

@protocol NetworkListenerDelegate <NSObject>

/// 监听网络变化代理
/// @param listener NetworkListener
/// @param status 变化之后的状态
- (void)networkListener:(NetworkListener *)listener didChangeStatus:(NetworkListenerStatus)status;

@end


@interface NetworkListener : NSObject

/// 单例初始化网络监听器
@property (nonatomic, strong, readonly, class) NetworkListener *sharedListener;

/// 当前网络状态
@property (nonatomic, assign, readonly) NetworkListenerStatus currentStatus;

/// 是否有网络
@property (readonly, nonatomic, assign, getter=isReachable) BOOL reachable;

/// 移动数据网络
@property (readonly, nonatomic, assign, getter=isReachableViaWWAN) BOOL reachableViaWWAN;

/// Wi-Fi
@property (readonly, nonatomic, assign, getter=isReachableViaWiFi) BOOL reachableViaWiFi;

/// 代理
@property (nonatomic, weak, nullable) id<NetworkListenerDelegate> delegate;

/// 一般在 AppDelegate 里面已经开启监听，无需重复调用
- (void)start;

/// 停止监听
- (void)stop;

/// 使用 Blok 获取网络变化状态
/// @param block 网络变化回调
- (void)networkListenerChangeStatusUsingBlock:(void (^)(NetworkListenerStatus status))block;

@end

NS_ASSUME_NONNULL_END
