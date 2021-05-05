//
//  NetworkClient+Request.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "NetworkClient.h"

#import "BaseRequest.h"
#import "BaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkClient (Request)

- (void)requestPhotosWithSuccess:(void (^_Nullable)(PhotosRequest *request))success failure:(void (^_Nullable)(PhotosRequest *request))failure;

- (void)requestUserWithUserId:(NSNumber *)userId success:(void (^_Nullable)(UserRequest *request))success failure:(void (^_Nullable)(UserRequest *request))failure;

@end

NS_ASSUME_NONNULL_END
