//
//  NetworkReachInterceptor.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/4/6.
//

#import "NetworkListener.h"
#import "NetworkReachInterceptor.h"

static NSString *const NetworkReachInterceptorErrorDomain = @"com.lidan.FastNetworkDemo.NetworkReachInterceptorErrorDomain";
static NSString *const NetworkReachInterceptorErrorMessage = @"无可用网络，请检查网络设置";
static NSInteger const NetworkReachInterceptorErrorError = -1001;


@implementation NetworkReachInterceptor

- (FSTInterceptPriority)interceptPriority {
    return FSTInterceptPriorityRequired;
}

- (FSTInterceptor *)interceptorWillStart:(FSTInterceptor *)interceptor {
    return [self interceptorDidError:interceptor];
}

- (FSTInterceptor *)interceptorDidError:(FSTInterceptor *)interceptor {
    if (![NetworkListener sharedListener].isReachable) {
        interceptor.error = [NSError errorWithDomain:NetworkReachInterceptorErrorDomain
                                                code:NetworkReachInterceptorErrorError
                                            userInfo:@{NSLocalizedDescriptionKey: NetworkReachInterceptorErrorMessage}];
    }
    return interceptor;
}

@end
