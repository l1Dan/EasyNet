//
//  BaseRequest.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <FastNetwork/FastNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseRequest : FSTConnectTask

@end

@interface PhotosRequest : BaseRequest

@end

@interface UserRequest : BaseRequest

@property (nonatomic, strong, readonly) NSNumber *userId;

- (instancetype)initWithUserId:(NSNumber *)userId;

@end

@interface Post1CommentsRequest : BaseRequest

@end

NS_ASSUME_NONNULL_END
