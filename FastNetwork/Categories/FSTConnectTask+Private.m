//
// FSTConnectTask+Private.m
//
// Copyright (c) 2021 Leo Lee FastNetwork (https://github.com/l1Dan/FastNetwork)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <objc/runtime.h>

#import "FSTNetworkMediator.h"

#import "FSTConnectTask+Private.h"
#import "NSString+FSTConnectTask.h"

FSTMethodType const FSTMethodTypeGet = @"GET";
FSTMethodType const FSTMethodTypePost = @"POST";
FSTMethodType const FSTMethodTypeHead = @"HEAD";
FSTMethodType const FSTMethodTypePut = @"PUT";
FSTMethodType const FSTMethodTypeDelete = @"DELETE";
FSTMethodType const FSTMethodTypePatch = @"PATCH";

static NSString *const FSTResponseObjectKey = @"responseObject";
static NSString *const FSTResponseKey = @"response";

static NSString *FSTInterceptScopeKey = @"scope";
static NSString *FSTInterceptInstanceKey = @"instane";
static NSString *FSTInterceptPriorityKey = @"priority";

static const NSString *FSTInterceptScopeLocal = @"Scope-1";
static const NSString *FSTInterceptScopeGlobal = @"Scope-2";


@interface FSTInterceptor ()

@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, copy) NSString *method;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *responseHeaders;

@end


@implementation FSTConnectTask (URLRequest)

- (FSTMethodType)methodType {
    switch (self.requestMethod) {
        case FSTRequestMethodGet: return FSTMethodTypeGet;
        case FSTRequestMethodPost: return FSTMethodTypePost;
        case FSTRequestMethodHead: return FSTMethodTypeHead;
        case FSTRequestMethodPut: return FSTMethodTypePut;
        case FSTRequestMethodDelete: return FSTMethodTypeDelete;
        case FSTRequestMethodPatch: return FSTMethodTypePatch;
    }
}

- (NSString *)URLAbsoluteString {
    return [NSString fst_buildPathWithBaseURL:self.baseURL requestURL:self.requestURL parameters:nil];
}

- (NSString *)URLAbsoluteStringWithParameters {
    return [NSString fst_buildPathWithBaseURL:self.baseURL requestURL:self.requestURL parameters:self.parameters];
}

@end


@interface FSTConnectTask (ResponseCache)

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *error;

@end


@implementation FSTConnectTask (ResponseCache)

#pragma mark - Private

+ (NSString *)responseCacheKeyWithConnectTask:(FSTConnectTask *)connectTask {
    NSString *method = connectTask.methodType;
    NSString *URLAbsoluteStringWithParameters = [connectTask URLAbsoluteStringWithParameters];
    NSString *key = [NSString stringWithFormat:@"%@:%@", method, URLAbsoluteStringWithParameters];
    return key.fst_md5String;
}

#pragma mark - Public

+ (void)responseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(FSTConnectTask *_Nonnull))block {
    NSString *key = [[connectTask class] responseCacheKeyWithConnectTask:connectTask];
    id<FSTResponseCacheable> cacheable = [[connectTask class] networInstance].cacheInstance;
    NSAssert(cacheable != nil, @"NetworkMediator cacheInstance should not be nil");
    NSAssert([cacheable respondsToSelector:@selector(cacheObjectForKey:usingBlock:)], @"NetworkMediator cacheInstance has not conform the 'ResponseCacheable' protocol");
    
    if ([cacheable respondsToSelector:@selector(cacheObjectForKey:usingBlock:)]) {
        [cacheable cacheObjectForKey:key usingBlock:^(NSString *_Nonnull key, id _Nonnull object) {
            NSDictionary *info = (NSDictionary *)object;
            if ([info isKindOfClass:[NSDictionary class]]) {
                connectTask.responseObject = [info valueForKey:FSTResponseObjectKey];
                connectTask.response = [info valueForKey:FSTResponseKey];
                if (block) {
                    block(connectTask);
                }
            } else {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Can't found the cached data!"};
                connectTask.error = [NSError errorWithDomain:FSTConnectTaskCacheNotFoundErrorDomain code:FSTConnectTaskCacheNotFoundErrorCode userInfo:userInfo];
                if (block) {
                    block(connectTask);
                }
            }
        }];
    } else {
        if (block) {
            block(connectTask);
        }
    }
}

+ (void)setResponseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(FSTConnectTask *_Nonnull))block {
    NSString *key = [[connectTask class] responseCacheKeyWithConnectTask:connectTask];
    if (connectTask.responseObject && key) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:connectTask.responseObject forKey:FSTResponseObjectKey];
        [dict setValue:connectTask.response forKey:FSTResponseKey];
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:dict];
        
        id<FSTResponseCacheable> cacheable = [[connectTask class] networInstance].cacheInstance;
        NSAssert(cacheable != nil, @"cacheInstance should not be nil");
        NSAssert([cacheable respondsToSelector:@selector(setCacheObject:forKey:usingBlock:)], @"NetworkMediator cacheInstance has not conform the 'ResponseCacheable' protocol");
        
        if ([cacheable respondsToSelector:@selector(setCacheObject:forKey:usingBlock:)]) {
            [cacheable setCacheObject:info forKey:key usingBlock:^{
                if (block) {
                    block(connectTask);
                }
            }];
        } else {
            if (block) {
                block(connectTask);
            }
        }
    }
}

+ (void)removeResponseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(NSString *_Nonnull))block {
    NSString *key = [[connectTask class] responseCacheKeyWithConnectTask:connectTask];
    id<FSTResponseCacheable> cacheable = [[connectTask class] networInstance].cacheInstance;
    NSAssert(cacheable != nil, @"NetworkMediator cacheInstance should not be nil");
    NSAssert([cacheable respondsToSelector:@selector(removeObjectForKey:)], @"NetworkMediator cacheInstance has not conform the 'ResponseCacheable' protocol");
    
    if ([cacheable respondsToSelector:@selector(removeObjectForKey:)]) {
        [cacheable removecacheObjectForKey:key usingBlock:block];
    } else {
        if (block) {
            block(key);
        }
    }
}

@end


@interface FSTConnectTask (Interceptor)

@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *allInterceptorMapped;

@end


@implementation FSTConnectTask (Interceptor)

#pragma mark - Getter & Setter

- (NSMutableArray<NSDictionary<NSString *, id> *> *)allInterceptorMapped {
    NSMutableArray<NSDictionary<NSString *, id> *> *mapped = objc_getAssociatedObject(self, _cmd);
    if (!mapped) {
        mapped = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, mapped, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 优化：避免重复排序
    if (mapped.count > 0) {
        return mapped;
    }
    
    NSArray<id<FSTInterceptable>> *local = self.interceptors;
    NSArray<id<FSTInterceptable>> *global = [[self class] networInstance].globalInterceptors;
    if (local.count || global.count) {
        // 拦截器调用顺序实现使用优先级队列的思路，全局拦截器默认优先级 > 局部拦截器默认优先级
        // 1.处理所有局部拦截器
        [local enumerateObjectsUsingBlock:^(id<FSTInterceptable> interceptable, NSUInteger idx, BOOL *stop) {
            BOOL hasResponds = [interceptable respondsToSelector:@selector(interceptPriority)];
            // 局部拦截器如果没有设置默认为：FSTInterceptPriorityDefault
            NSNumber *priority = [NSNumber numberWithFloat:hasResponds ? interceptable.interceptPriority : FSTInterceptPriorityDefault];
            NSDictionary *info = @{
                FSTInterceptScopeKey: FSTInterceptScopeLocal,
                FSTInterceptInstanceKey: interceptable,
                FSTInterceptPriorityKey: priority
            };
            [mapped addObject:info];
        }];
        
        // 2.处理所有全局拦截器
        [global enumerateObjectsUsingBlock:^(id<FSTInterceptable> interceptable, NSUInteger idx, BOOL *stop) {
            BOOL hasResponds = [interceptable respondsToSelector:@selector(interceptPriority)];
            // 全局拦截器如果没有设置默认为：FSTInterceptPriorityDefaultHigh
            NSNumber *priority = [NSNumber numberWithFloat:hasResponds ? interceptable.interceptPriority : FSTInterceptPriorityDefaultHigh];
            NSDictionary *info = @{
                FSTInterceptScopeKey: FSTInterceptScopeGlobal,
                FSTInterceptInstanceKey: interceptable,
                FSTInterceptPriorityKey: priority
            };
            [mapped addObject:info];
        }];
        
        // 3.先按照优先级排序，如果优先级一样则按照作用范围排序
        NSSortDescriptor *sortByPriority = [NSSortDescriptor sortDescriptorWithKey:FSTInterceptPriorityKey ascending:NO];
        NSSortDescriptor *sortByScope = [NSSortDescriptor sortDescriptorWithKey:FSTInterceptScopeKey ascending:NO];
        [mapped sortUsingDescriptors:@[sortByPriority, sortByScope]];
    }
    
    return mapped;
}

- (void)setAllInterceptorMapped:(NSMutableArray<NSDictionary<NSString *, id> *> *)allInterceptorMapped {
    objc_setAssociatedObject(self, @selector(allInterceptorMapped), allInterceptorMapped, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Private

+ (FSTInterceptor *)buildInterceptorWithConnectTask:(FSTConnectTask *)connectTask preformSelector:(SEL)selector {
    NSURLRequest *customRequest = [connectTask customRequest];
    NSString *baseURL = customRequest ? nil : connectTask.baseURL;
    NSString *requestURL = customRequest ? customRequest.URL.absoluteString : connectTask.requestURL;
    NSString *method = customRequest ? customRequest.HTTPMethod : connectTask.methodType;
    NSDictionary<NSString *, NSString *> *requestHeaders = customRequest ? customRequest.allHTTPHeaderFields : connectTask.requestHeaders;
    
    // 1.构造拦截器对象
    FSTInterceptor *interceptor = [[FSTInterceptor alloc] init];
    interceptor.baseURL = baseURL;
    interceptor.requestURL = requestURL;
    interceptor.method = method;
    interceptor.parameters = connectTask.parameters;
    
    interceptor.error = connectTask.error;
    interceptor.responseHeaders = connectTask.responseHeaders;
    interceptor.responseObject = connectTask.responseObject;
    interceptor.responseData = connectTask.responseData;
    
    // 2.设置 request headers
    [interceptor setAllHTTPRequestHeaders:requestHeaders];
    
    // 3.按照优先级排序规则依次调用
    for (NSDictionary<NSString *, id> *map in connectTask.allInterceptorMapped) {
        NSObject<FSTInterceptable> *interceptable = map[FSTInterceptInstanceKey];
        if ([connectTask ignoreInterceptor:interceptable]) {
            continue; // 忽略此次调用的拦截器
        }
        // 通用方法调用
        if ([interceptable respondsToSelector:selector]) {
            NSMethodSignature *signature = [interceptable methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:interceptable];
            [invocation setSelector:selector];
            // arguments index 从 2 开始
            [invocation setArgument:&interceptor atIndex:2];
            [invocation invoke];
            
            [invocation getReturnValue:&interceptor];
        }
    }
    
    return interceptor;
}

#pragma mark - Public

- (FSTInterceptor *)connectTaskWillStart {
    return [[self class] buildInterceptorWithConnectTask:self preformSelector:@selector(interceptorWillStart:)];
}

- (FSTInterceptor *)connectTaskDidFinishWithResponseObject:(id)responseObject responseData:(NSData *)responseData {
    self.responseObject = responseObject;
    self.responseData = responseData;
    return [[self class] buildInterceptorWithConnectTask:self preformSelector:@selector(interceptorDidFinish:)];
}

- (FSTInterceptor *)connectTaskDidError:(NSError *)error {
    self.error = error;
    return [[self class] buildInterceptorWithConnectTask:self preformSelector:@selector(interceptorDidError:)];
}

@end
