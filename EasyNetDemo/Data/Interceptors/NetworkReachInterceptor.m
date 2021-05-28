//
//  NetworkReachInterceptor.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/4/6.
//

#import "NetworkListener.h"
#import "NetworkReachInterceptor.h"

static NSString *const NetworkReachInterceptorErrorDomain = @"com.github.l1Dan.EasyNetDemo.NetworkReachInterceptorErrorDomain";
static NSString *const NetworkReachInterceptorErrorMessage = @"无可用网络，请检查网络设置";
static NSInteger const NetworkReachInterceptorErrorError = -1001;


@implementation NetworkReachInterceptor

- (ENInterceptorPriority)interceptorPriority {
    return ENInterceptorPriorityRequired;
}

- (ENInterceptor *)interceptorWillStart:(ENInterceptor *)interceptor {
    return [self interceptorDidError:interceptor];
}

- (ENInterceptor *)interceptorDidError:(ENInterceptor *)interceptor {
    if (![NetworkListener sharedListener].isReachable) {
        interceptor.error = [NSError errorWithDomain:NetworkReachInterceptorErrorDomain
                                                code:NetworkReachInterceptorErrorError
                                            userInfo:@{NSLocalizedDescriptionKey: NetworkReachInterceptorErrorMessage}];
    }
    return interceptor;
}

@end
