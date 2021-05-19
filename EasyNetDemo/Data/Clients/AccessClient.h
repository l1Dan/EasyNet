//
//  AccessClient.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <EasyNet/EasyNet.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessClient : ENNetworkAgent

@property (nonatomic, strong, readonly, class) AccessClient *defaultClient;

@end

NS_ASSUME_NONNULL_END
