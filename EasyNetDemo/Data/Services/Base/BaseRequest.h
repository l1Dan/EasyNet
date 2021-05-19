//
//  BaseRequest.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <EasyNet/EasyNet.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseRequest : ENConnectTask

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
