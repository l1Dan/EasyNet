//
//  NetworkListener.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2020/7/23.
//

#import <AFNetworking/AFNetworking.h>

#import "NetworkListener.h"

NSString *const NetworkListenerDidChangeStateNotification = @"com.lidan.EasyNetDemo.NetworkListenerDidChangeStateNotification";


@interface NetworkListener ()
@property (nonatomic, copy) void (^reachabilityChangeBlock)(NetworkListenerStatus);
@property (nonatomic, assign) NetworkListenerStatus preStatus; //上一个状态
@end


@implementation NetworkListener

+ (NetworkListener *)sharedListener {
    static NetworkListener *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark -
- (void)reachabilityChangedNotification:(NSNotification *)notification {
    if (![notification.object isKindOfClass:[AFNetworkReachabilityManager class]]) return;

    AFNetworkReachabilityManager *manager = (AFNetworkReachabilityManager *)notification.object;
    NetworkListenerStatus status = [self currentStatusWithReachabilityStatus:[manager networkReachabilityStatus]];
    if (status == self.preStatus) {
        return;
    }
    self.preStatus = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkListenerDidChangeStateNotification object:self];
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkListener:didChangeStatus:)]) {
        [self.delegate networkListener:self didChangeStatus:status];
    }

    // Block
    if (self.reachabilityChangeBlock) {
        self.reachabilityChangeBlock(status);
    }
}

- (NetworkListenerStatus)currentStatusWithReachabilityStatus:(AFNetworkReachabilityStatus)status {
    switch (status) {
        case AFNetworkReachabilityStatusUnknown: return NetworkListenerStatusUnknown;
        case AFNetworkReachabilityStatusNotReachable: return NetworkListenerStatusNotReachable;
        case AFNetworkReachabilityStatusReachableViaWWAN: return NetworkListenerStatusViaWWAN;
        case AFNetworkReachabilityStatusReachableViaWiFi: return NetworkListenerStatusViaWiFi;
    }
}

#pragma mark - Public
- (NetworkListenerStatus)currentStatus {
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    return [self currentStatusWithReachabilityStatus:status];
}

- (BOOL)isReachable {
    return self.isReachableViaWWAN || self.isReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN {
    return self.currentStatus == NetworkListenerStatusViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.currentStatus == NetworkListenerStatusViaWiFi;
}

- (void)start {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)stop {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)networkListenerChangeStatusUsingBlock:(void (^)(NetworkListenerStatus))block {
    self.reachabilityChangeBlock = block;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
