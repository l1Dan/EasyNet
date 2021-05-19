//
//  AccessClient+Request.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "AccessRequest.h"

#import "AccessClient+Request.h"

@implementation AccessClient (Request)

- (void)requestUserIdWithSuccess:(void (^)(AccessRequest * _Nonnull))success failure:(void (^)(AccessRequest * _Nonnull))failure {
    AccessRequest *request = [[AccessRequest alloc] init];
    [request startWithConvert:[AccessResponse class] success:success failure:failure];
}

@end
