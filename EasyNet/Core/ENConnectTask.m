//
// ENConnectTask.m
//
// Copyright (c) 2021 Leo Lee EasyNet (https://github.com/l1Dan/EasyNet)
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

#import "ENConnectTask.h"
#import "ENNetworkAgent.h"

#import "ENConnectTask+Private.h"

NSInteger const ENConnectTaskCacheNotFoundErrorCode = -101;
NSInteger const ENConnectTaskJSONSerializationErrorCode = -100;

NSErrorDomain const ENConnectTaskCacheNotFoundErrorDomain = @"com.github.l1Dan.CacheNotFoundErrorDomain";
NSErrorDomain const ENConnectTaskJSONSerializationErrorDomain = @"com.github.l1Dan.JSONSerializationErrorDomain";

// Private
static NSErrorUserInfoKey const ENExceptionName = @"ExceptionName";
static NSErrorUserInfoKey const ENExceptionReason = @"ExceptionReason";
static NSErrorUserInfoKey const ENExceptionCallStackReturnAddresses = @"ExceptionCallStackReturnAddresses";
static NSErrorUserInfoKey const ENExceptionCallStackSymbols = @"ExceptionCallStackSymbols";
static NSErrorUserInfoKey const ENExceptionUserInfo = @"ExceptionUserInfo";

static ENNetworkAgent *_ENNetworkAgent = nil;


@interface ENConnectTask ()

@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *responseError;

@property (nonatomic, strong, nullable) id<ENResponseJSONConvertible> convertObject;
@property (nonatomic, strong) NSMutableArray<id<ENInterceptable>> *interceptors;

@end


@implementation ENConnectTask

#pragma mark - Getter

+ (__kindof ENNetworkAgent *)networInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ENNetworkAgent = [[ENNetworkAgent alloc] init];
    });
    return _ENNetworkAgent;
}

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSDictionary<NSString *, NSString *> *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSInteger)statusCode {
    return self.response.statusCode;
}

- (NSURLRequest *)currentReuqest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}

- (NSTimeInterval)requestTimeout {
    return 30;
}

- (ENRequestMethod)requestMethod {
    return ENRequestMethodGet;
}

- (ENRequestSerializerType)requestSerializerType {
    return ENRequestSerializerTypeHTTP;
}

- (ENResponseSerializerType)responseSerializerType {
    return ENResponseSerializerTypeJSON;
}

- (ENRequestCachePolicy)requestCachePolicy {
    return ENRequestCachePolicyDefault;
}

- (NSMutableArray<id<ENInterceptable>> *)interceptors {
    if (!_interceptors) {
        _interceptors = [NSMutableArray array];
    }
    return _interceptors;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isRunning {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

- (BOOL)isAllowsCellularAccess {
    return YES;
}

- (BOOL)isEnableParametersInURI {
    return YES;
}

- (BOOL)ignoreInterceptor:(id<ENInterceptable>)interceptor {
    return NO;
}

#pragma mark - Private

- (void)addInterceptor:(id<ENInterceptable>)interceptor {
    [self.interceptors addObject:interceptor];
}

- (void)setBlocksWithSuccess:(nullable ENConnectTaskBlock)success failure:(nullable ENConnectTaskBlock)failure {
    self.successConnectTaskBlock = success;
    self.failureConnectTaskBlock = failure;
}

- (void)requestWithCachePolicy:(ENRequestCachePolicy)cachePolicy success:(ENConnectTaskBlock)success failure:(ENConnectTaskBlock)failure {
    __weak typeof(self) weakSelf = self;
    switch (cachePolicy) {
        case ENRequestCachePolicyDefault: { // NSURLRequestUseProtocolCachePolicy
            [self setBlocksWithSuccess:success failure:failure];
            [self start];
        } break;
            
        case ENRequestCachePolicyStaleWhileRevalidate: {
            [self requestWithCachePolicy:ENRequestCachePolicyDefault success:^(__kindof ENConnectTask *_Nonnull connectTask) {
                // 保存网络请求数据
                [ENConnectTask setResponseWithConnectTask:connectTask usingBlock:success];
            } failure:failure];
        } break;
            
        case ENRequestCachePolicyNetOnly: { // NSURLRequestReloadIgnoringCacheData
            // 先移除之前保存的本地缓存数据，防止其他请求使用
            [ENConnectTask removeResponseWithConnectTask:self usingBlock:^(NSString *_Nonnull key) {
                [self setBlocksWithSuccess:success failure:failure];
                [self start];
            }];
        } break;
            
        case ENRequestCachePolicyCacheOnly: { // NSURLRequestReturnCacheDataDontLoad
            [self setBlocksWithSuccess:success failure:^(__kindof ENConnectTask *_Nonnull connectTask) {
                // 取出本地缓存数据
                [ENConnectTask responseWithConnectTask:connectTask usingBlock:^(ENConnectTask *connectTask) {
                    if (connectTask.responseError) {
                        if (failure) {
                            failure(connectTask);
                        }
                    } else {
                        if (success) {
                            success(connectTask);
                        }
                    }
                }];
            }];
            [self start];
        } break;
            
        case ENRequestCachePolicyNetFirst: {
            [self requestWithCachePolicy:ENRequestCachePolicyStaleWhileRevalidate success:success failure:^(__kindof ENConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:ENRequestCachePolicyCacheOnly success:success failure:failure];
            }];
        } break;
            
        case ENRequestCachePolicyCacheFirst: {
            [self requestWithCachePolicy:ENRequestCachePolicyCacheOnly success:^(__kindof ENConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:ENRequestCachePolicyStaleWhileRevalidate success:NULL failure:NULL];
                if (success) {
                    success(connectTask);
                }
                // 保存下一次请求数据
            } failure:^(__kindof ENConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:ENRequestCachePolicyStaleWhileRevalidate success:success failure:failure];
            }];
        } break;
            
        default: {
            [self requestWithCachePolicy:ENRequestCachePolicyDefault success:success failure:failure];
        } break;
    }
}

#pragma mark - Public

- (void)clearAllBlocks {
    self.successConnectTaskBlock = nil;
    self.failureConnectTaskBlock = nil;
    self.uploadProgressBlock = nil;
}

- (void)start {
    NSAssert([[self class] networInstance] != nil, @"networInstance should not be nil");
    [[[self class] networInstance] addConnectTask:self];
}

- (void)stop {
    [[[self class] networInstance] removeConnectTask:self];
}

- (void)startWithSuccess:(ENConnectTaskBlock)success failure:(ENConnectTaskBlock)failure {
    NSAssert([[self class] networInstance] != nil, @"networInstance should not be nil");
    [self requestWithCachePolicy:self.requestCachePolicy success:success failure:failure];
}

- (void)startWithConvert:(Class)convert success:(ENConnectTaskBlock)success failure:(ENConnectTaskBlock)failure {
    [self startWithSuccess:^(__kindof ENConnectTask *_Nonnull connectTask) {
        if (!success) {
            return;
        }
        
        id jsonObject = connectTask.responseObject ?: connectTask.responseData;
        if (convert && [convert respondsToSelector:@selector(customConvertFromObject:)]) {
            NSError *error;
            if ([jsonObject isKindOfClass:[NSData class]]) {
                @try {
                    jsonObject = [NSJSONSerialization JSONObjectWithData:jsonObject options:NSJSONReadingMutableContainers error:&error];
                } @catch (NSException *exception) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionary];
                    [info setValue:exception.name forKey:ENExceptionName];
                    [info setValue:exception.reason forKey:ENExceptionReason];
                    [info setValue:exception.callStackReturnAddresses forKey:ENExceptionCallStackReturnAddresses];
                    [info setValue:exception.callStackSymbols forKey:ENExceptionCallStackSymbols];
                    [info setValue:exception.userInfo forKey:ENExceptionUserInfo];
                    error = [[NSError alloc] initWithDomain:ENConnectTaskJSONSerializationErrorDomain code:ENConnectTaskJSONSerializationErrorCode userInfo:info];
                }
            }
            
            if (error && failure) {
                connectTask.responseError = error ?: connectTask.responseError;
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(connectTask);
                });
                return;
            }
            
            id<ENResponseJSONConvertible> converted = [convert customConvertFromObject:jsonObject];
            connectTask.convertObject = converted;
            dispatch_async(dispatch_get_main_queue(), ^{
                success(connectTask);
            });
            return;
        }
        
        __autoreleasing ENResponseConvertBlock block = [[connectTask class] networInstance].responseConvertBlock;
        NSAssert(block != nil, @"Configs ENNetworkAgent +setConvertExecuteBodyUsingBlock:");
        if (block) {
            connectTask.convertObject = block(convert, jsonObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                success(connectTask);
            });
        }
    } failure:failure];
}

@end
