//
//  AccessClient+Request.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "AccessClient.h"

#import "AccessRequest.h"
#import "AccessResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccessClient (Request)

- (void)requestUserIdWithSuccess:(void (^_Nullable)(AccessRequest *request))success failure:(void (^_Nullable)(AccessRequest *request))failure;

@end

NS_ASSUME_NONNULL_END
