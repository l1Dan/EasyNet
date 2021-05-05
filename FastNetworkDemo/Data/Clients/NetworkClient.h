//
//  NetworkClient.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <FastNetwork/FastNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkClient : FSTNetworkMediator

@property (nonatomic, strong, readonly, class) NetworkClient *defaultClient;

@end

NS_ASSUME_NONNULL_END
