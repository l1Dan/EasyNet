//
//  LoggerInterceptor.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/4/28.
//

#import "LoggerInterceptor.h"

#import "NSString+ENConnectTask.h"

@implementation LoggerInterceptor

- (ENInterceptorPriority)interceptorPriority {
    return ENInterceptorPriorityDefaultLow;
}

- (ENInterceptor *)interceptorWillStart:(ENInterceptor *)interceptor {
    NSString *URLString = [NSString en_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] REQUEST BEGIN\n%@:%@\nHeaders: %@\nParameters: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.requestHeaders,
                          [NSString en_JSONPrettyPrintedWithObject:interceptor.parameters]];
    NSLog(@"%@", formated);
    return interceptor;
}

- (ENInterceptor *)interceptorDidSuccess:(ENInterceptor *)interceptor {
    NSString *URLString = [NSString en_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] RESPONSE SUCCEEDED\n%@:%@\nHeaders: %@\nParameters: %@\nResponse: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.responseHeaders,
                          [NSString en_JSONPrettyPrintedWithObject:interceptor.parameters],
                          [NSString en_JSONPrettyPrintedWithObject:interceptor.responseObject]];
    NSLog(@"%@", formated);
    return interceptor;
}

- (ENInterceptor *)interceptorDidFailure:(ENInterceptor *)interceptor {
    NSString *URLString = [NSString en_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] RESPONSE FAILED\n%@:%@\nHeaders: %@\nParameters: %@\nError: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.responseHeaders,
                          [NSString en_JSONPrettyPrintedWithObject:interceptor.parameters],
                          interceptor.responseError];
    NSLog(@"%@", formated);
    return interceptor;
}

@end
