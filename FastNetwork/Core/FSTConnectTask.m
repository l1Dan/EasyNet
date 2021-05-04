//
// FSTConnectTask.m
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

#import "FSTConnectTask.h"
#import "FSTNetworkMediator.h"

#import "FSTConnectTask+Private.h"

NSInteger const FSTConnectTaskCacheNotFoundErrorCode = -101;
NSInteger const FSTConnectTaskJSONSerializationErrorCode = -100;

NSErrorDomain const FSTConnectTaskCacheNotFoundErrorDomain = @"com.lidan.FastNetwork.CacheNotFoundErrorDomain";
NSErrorDomain const FSTConnectTaskJSONSerializationErrorDomain = @"com.lidan.FastNetwork.JSONSerializationErrorDomain";

// Private
static NSErrorUserInfoKey const FSTExceptionName = @"ExceptionName";
static NSErrorUserInfoKey const FSTExceptionReason = @"ExceptionReason";
static NSErrorUserInfoKey const FSTExceptionCallStackReturnAddresses = @"ExceptionCallStackReturnAddresses";
static NSErrorUserInfoKey const FSTExceptionCallStackSymbols = @"ExceptionCallStackSymbols";
static NSErrorUserInfoKey const FSTExceptionUserInfo = @"ExceptionUserInfo";

static FSTNetworkMediator *_networkMediator = nil;


@interface FSTConnectTask ()

@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong, nullable) id<FSTJSONConvertible> convertObject;

@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSMutableArray<id<FSTInterceptable>> *interceptors;

@end


@implementation FSTConnectTask

#pragma mark - Getter

+ (__kindof FSTNetworkMediator *)networInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkMediator = [[FSTNetworkMediator alloc] init];
    });
    return _networkMediator;
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

- (FSTRequestMethod)requestMethod {
    return FSTRequestMethodGet;
}

- (FSTRequestSerializerType)requestSerializerType {
    return FSTRequestSerializerTypeHTTP;
}

- (FSTResponseSerializerType)responseSerializerType {
    return FSTResponseSerializerTypeJSON;
}

- (FSTRequestCachePolicy)cachePolicy {
    return FSTRequestCachePolicyDefault;
}

- (NSMutableArray<id<FSTInterceptable>> *)interceptors {
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

- (BOOL)ignoreInterceptor:(id<FSTInterceptable>)interceptor {
    return NO;
}

#pragma mark - Setter

+ (void)setNetworInstance:(__kindof FSTNetworkMediator *)networInstance {
    _networkMediator = networInstance;
}

#pragma mark - Private

- (void)addInterceptor:(id<FSTInterceptable>)interceptor {
    [self.interceptors addObject:interceptor];
}

- (void)setBlocksWithSuccess:(nullable FSTConnectTaskBlock)success failure:(nullable FSTConnectTaskBlock)failure {
    self.successConnectTaskBlock = success;
    self.failureConnectTaskBlock = failure;
}

- (void)requestWithCachePolicy:(FSTRequestCachePolicy)cachePolicy success:(FSTConnectTaskBlock)success failure:(FSTConnectTaskBlock)failure {
    __weak typeof(self) weakSelf = self;
    switch (cachePolicy) {
        case FSTRequestCachePolicyDefault: { // NSURLRequestUseProtocolCachePolicy
            [self setBlocksWithSuccess:success failure:failure];
            [self start];
        } break;
            
        case FSTRequestCachePolicyStaleWhileRevalidate: {
            [self requestWithCachePolicy:FSTRequestCachePolicyDefault success:^(__kindof FSTConnectTask *_Nonnull connectTask) {
                // 保存网络请求数据
                [FSTConnectTask setResponseWithConnectTask:connectTask usingBlock:success];
            } failure:failure];
        } break;
            
        case FSTRequestCachePolicyNetOnly: { // NSURLRequestReloadIgnoringCacheData
            // 先移除之前保存的本地缓存数据，防止其他请求使用
            [FSTConnectTask removeResponseWithConnectTask:self usingBlock:^(NSString *_Nonnull key) {
                [self setBlocksWithSuccess:success failure:failure];
                [self start];
            }];
        } break;
            
        case FSTRequestCachePolicyCacheOnly: { // NSURLRequestReturnCacheDataDontLoad
            [self setBlocksWithSuccess:success failure:^(__kindof FSTConnectTask *_Nonnull connectTask) {
                // 取出本地缓存数据
                [FSTConnectTask responseWithConnectTask:connectTask usingBlock:^(FSTConnectTask *connectTask) {
                    if (connectTask.error) {
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
            
        case FSTRequestCachePolicyNetFirst: {
            [self requestWithCachePolicy:FSTRequestCachePolicyStaleWhileRevalidate success:success failure:^(__kindof FSTConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:FSTRequestCachePolicyCacheOnly success:success failure:failure];
            }];
        } break;
            
        case FSTRequestCachePolicyCacheFirst: {
            [self requestWithCachePolicy:FSTRequestCachePolicyCacheOnly success:^(__kindof FSTConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:FSTRequestCachePolicyStaleWhileRevalidate success:NULL failure:NULL];
                if (success) {
                    success(connectTask);
                }
                // 保存下一次请求数据
            } failure:^(__kindof FSTConnectTask *_Nonnull connectTask) {
                [weakSelf requestWithCachePolicy:FSTRequestCachePolicyStaleWhileRevalidate success:success failure:failure];
            }];
        } break;
            
        default: {
            [self requestWithCachePolicy:FSTRequestCachePolicyDefault success:success failure:failure];
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
    NSAssert([FSTConnectTask networInstance] != nil, @"networInstance should not be nil");
    [[FSTConnectTask networInstance] addConnectTask:self];
}

- (void)stop {
    [[FSTConnectTask networInstance] removeConnectTask:self];
}

- (void)startWithSuccess:(FSTConnectTaskBlock)success failure:(FSTConnectTaskBlock)failure {
    NSAssert([FSTConnectTask networInstance] != nil, @"networInstance should not be nil");
    [self requestWithCachePolicy:self.cachePolicy success:success failure:failure];
}

- (void)startWithConvert:(Class)convert success:(FSTConnectTaskBlock)success failure:(FSTConnectTaskBlock)failure {
    [self startWithSuccess:^(__kindof FSTConnectTask *_Nonnull connectTask) {
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
                    [info setValue:exception.name forKey:FSTExceptionName];
                    [info setValue:exception.reason forKey:FSTExceptionReason];
                    [info setValue:exception.callStackReturnAddresses forKey:FSTExceptionCallStackReturnAddresses];
                    [info setValue:exception.callStackSymbols forKey:FSTExceptionCallStackSymbols];
                    [info setValue:exception.userInfo forKey:FSTExceptionUserInfo];
                    error = [[NSError alloc] initWithDomain:FSTConnectTaskJSONSerializationErrorDomain code:FSTConnectTaskJSONSerializationErrorCode userInfo:info];
                }
            }
            
            if (error && failure) {
                connectTask.error = error ?: connectTask.error;
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(connectTask);
                });
                return;
            }
            
            id<FSTJSONConvertible> converted = [convert customConvertFromObject:jsonObject];
            connectTask.convertObject = converted;
            dispatch_async(dispatch_get_main_queue(), ^{
                success(connectTask);
            });
            return;
        }
        
        __autoreleasing FSTResponseConvertBlock block = [FSTConnectTask networInstance].responseConvertBlock;
        NSAssert(block != nil, @"Configs FSTNetworkMediator +setConvertExecuteBodyUsingBlock:");
        if (block) {
            connectTask.convertObject = block(convert, jsonObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                success(connectTask);
            });
        }
    } failure:failure];
}

@end
