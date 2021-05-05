//
//  AccessTokenInterceptor.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/4/28.
//

#import <pthread/pthread.h>

#import "AccessTokenInterceptor.h"

#import "AccessClient+Request.h"

static NSString *userId = nil;

@implementation AccessTokenInterceptor

- (FSTInterceptPriority)interceptPriority {
    return FSTInterceptPriorityDefaultHigh;
}

- (FSTInterceptor *)interceptorWillStart:(FSTInterceptor *)interceptor {
    NSString *key = @"userId";
    userId = userId ?: [interceptor valueForHTTPHeaderField:key];
    if (!userId) {
        [[AccessClient defaultClient] requestUserIdWithSuccess:^(AccessRequest * _Nonnull request) {
            AccessResponse *response = [request convertObject];
            if ([response isKindOfClass:[AccessResponse class]]) {
                userId = [response.userId stringValue];
            } else {
                NSLog(@"Fetch userId failed");
            }
        } failure:^(AccessRequest * _Nonnull request) {
            NSLog(@"Fetch userId failed");
        }];
    }
    
    if (userId) {
        [interceptor setValue:userId forHTTPHeaderField:key];
    }
    
    return interceptor;
}

@end
