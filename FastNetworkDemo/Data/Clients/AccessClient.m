//
//  AccessClient.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <MJExtension/MJExtension.h>

#import "AccessClient.h"

#import "LoggerInterceptor.h"
#import "NetworkReachInterceptor.h"

@implementation AccessClient

+ (AccessClient *)defaultClient {
    static AccessClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AccessClient alloc] init];
        
        // 设置拦截器
        [instance addGlobalInterceptor:[LoggerInterceptor new]];
        [instance addGlobalInterceptor:[NetworkReachInterceptor new]];
        
        // JSON 解析
        [instance setResponseConvertBlock:^id _Nullable(Class  _Nonnull __unsafe_unretained convert, id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                return [convert mj_objectArrayWithKeyValuesArray:responseObject];
            }
            return [convert mj_objectWithKeyValues:responseObject];
        }];
    });
    
    return instance;
}

@end
