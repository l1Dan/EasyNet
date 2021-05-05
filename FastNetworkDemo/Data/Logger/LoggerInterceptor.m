//
//  LoggerInterceptor.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/4/28.
//

#import "LoggerInterceptor.h"

#import "NSString+FSTConnectTask.h"

@implementation LoggerInterceptor

- (FSTInterceptPriority)interceptPriority {
    return FSTInterceptPriorityDefaultLow;
}

- (FSTInterceptor *)interceptorWillStart:(FSTInterceptor *)interceptor {
    NSString *URLString = [NSString fst_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] REQUEST BEGIN\n%@:%@\nHeaders: %@\nParameters: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.requestHeaders,
                          [NSString fst_JSONPrettyPrintedWithObject:interceptor.parameters]];
    NSLog(@"%@", formated);
    return interceptor;
}

- (FSTInterceptor *)interceptorDidFinish:(FSTInterceptor *)interceptor {
    NSString *URLString = [NSString fst_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] RESPONSE SUCCEEDED\n%@:%@\nHeaders: %@\nParameters: %@\nResponse: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.responseHeaders,
                          [NSString fst_JSONPrettyPrintedWithObject:interceptor.parameters],
                          [NSString fst_JSONPrettyPrintedWithObject:interceptor.responseObject]];
    NSLog(@"%@", formated);
    return interceptor;
}

- (FSTInterceptor *)interceptorDidError:(FSTInterceptor *)interceptor {
    NSString *URLString = [NSString fst_buildPathWithBaseURL:interceptor.baseURL requestURL:interceptor.requestURL parameters:nil];
    NSString *formated = [NSString stringWithFormat:@"[NETWORK] RESPONSE FAILED\n%@:%@\nHeaders: %@\nParameters: %@\nError: %@\n",
                          interceptor.method,
                          URLString,
                          interceptor.responseHeaders,
                          [NSString fst_JSONPrettyPrintedWithObject:interceptor.parameters],
                          interceptor.error];
    NSLog(@"%@", formated);
    return interceptor;
}

@end
