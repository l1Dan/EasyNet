//
// FSTNetworkMediator.m
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

#import <AFNetworking/AFNetworking.h>
#import <pthread/pthread.h>

#import "FSTConnectTask.h"
#import "FSTInterceptor.h"
#import "FSTNetworkMediator.h"

#import "FSTConnectTask+Private.h"
#import "NSString+FSTConnectTask.h"

const char *kNetworkConcurrentQueueName = "com.lidan.FastNetwork.concurrent.queue";

static pthread_mutex_t _lock;

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)


@interface FSTConnectTask ()

@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *error;

@end


@interface FSTNetworkMediator ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSIndexSet *statusCodes;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, FSTConnectTask *> *taskInfo;
@property (nonatomic, strong) NSMutableArray<id<FSTInterceptable>> *globalInterceptors;
@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *xmlParserResponseSerializer;

@end


@implementation FSTNetworkMediator {
    dispatch_queue_t _concurrentQueue;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_lock, NULL);
    });
}

- (instancetype)init {
    if (self = [super init]) {
        _statusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        _concurrentQueue = dispatch_queue_create(kNetworkConcurrentQueueName, DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - Getter

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager.completionQueue = _concurrentQueue;
        _manager.responseSerializer = self.jsonResponseSerializer;
    }
    return _manager;
}

- (NSMutableDictionary<NSNumber *, FSTConnectTask *> *)taskInfo {
    if (!_taskInfo) {
        _taskInfo = [NSMutableDictionary dictionary];
    }
    return _taskInfo;
}

- (NSMutableArray<id<FSTInterceptable>> *)globalInterceptors {
    if (!_globalInterceptors) {
        _globalInterceptors = [NSMutableArray array];
    }
    return _globalInterceptors;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = _statusCodes;
        _jsonResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", @"application/javascript", nil];
    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerializer {
    if (!_xmlParserResponseSerializer) {
        _xmlParserResponseSerializer = [AFXMLParserResponseSerializer serializer];
        _xmlParserResponseSerializer.acceptableStatusCodes = _statusCodes;
    }
    return _xmlParserResponseSerializer;
}

#pragma mark - Private

- (void)addGlobalInterceptor:(id<FSTInterceptable>)interceptor {
    [self.globalInterceptors addObject:interceptor];
}

- (float)requestPriorityForConnectTask:(FSTConnectTask *)connectTask {
    switch (connectTask.requestPriority) {
        case FSTRequestPriorityHigh: return NSURLSessionTaskPriorityHigh;
        case FSTRequestPriorityLow: return NSURLSessionTaskPriorityLow;
        default: return NSURLSessionTaskPriorityDefault;
    }
}

- (NSString *)incompleteCachePathForDownloadPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    static NSString *cacheFolder = nil;
    
    if (cacheFolder == nil) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"incomplete"];
    }
    
    NSError *error = nil;
    if (![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (nullable NSURL *)incompleteCachePathForDownloadPath:(NSString *)downloadPath {
    if (downloadPath == nil) {
        return nil;
    }
    
    NSString *string = downloadPath.fst_md5String;
    NSString *path = [[self incompleteCachePathForDownloadPath] stringByAppendingPathComponent:string];
    return path ? [NSURL fileURLWithPath:path] : nil;
}

- (NSString *)prepareRequest:(NSURLRequest *)request downloadPath:(NSString *)downloadPath error:(NSError *_Nullable __autoreleasing *)error {
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    NSString *downloadTargetPath = nil;
    if (isDirectory) {
        NSString *filename = request.URL.lastPathComponent;
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, filename]];
    } else {
        downloadTargetPath = downloadPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:error];
    }
    
    return downloadPath;
}

- (AFHTTPRequestSerializer *)requestSerializerForConnectTask:(FSTConnectTask *)connectTask withRequestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (connectTask.requestSerializerType == FSTRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (connectTask.requestSerializerType == FSTRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:FSTMethodTypeGet, FSTMethodTypeHead, FSTMethodTypeDelete, nil];
    if (!connectTask.enableParametersInURI) {
        if (connectTask.requestMethod == FSTRequestMethodGet) {
            requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:FSTMethodTypeHead, FSTMethodTypeDelete, nil];
        } else if (connectTask.requestMethod == FSTRequestMethodHead) {
            requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:FSTMethodTypeGet, FSTMethodTypeDelete, nil];
        } else if (connectTask.requestMethod == FSTRequestMethodDelete) {
            requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:FSTMethodTypeGet, FSTMethodTypeHead, nil];
        }
    }
    
    requestSerializer.timeoutInterval = connectTask.requestTimeout;
    requestSerializer.allowsCellularAccess = connectTask.isAllowsCellularAccess;
    if (connectTask.cachePolicy == FSTRequestCachePolicyNetOnly) {
        requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData; // 强制使用网络数据
    } else if (connectTask.cachePolicy == FSTRequestCachePolicyCacheOnly) {     // 强制使用本地数据
        requestSerializer.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    } else {
        requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; // 默认
    }
    
    NSDictionary<NSString *, NSString *> *header = requestHeaders;
    if (header != nil) {
        for (NSString *httpHeaderField in header.allKeys) {
            NSString *value = header[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    return requestSerializer;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError *_Nullable __autoreleasing *)error {
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters uploadProgress:nil constructingBodyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(AFURLSessionTaskProgressBlock)uploadProgress
                       constructingBodyWithBlock:(nullable void (^)(id<AFMultipartFormData> formData))block
                                           error:(NSError *_Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:nil completionHandler:^(NSURLResponse *__unused response, id responseObject, NSError *_error) {
        [self handleConnectTaskResult:dataTask responseObject:responseObject error:_error];
    }];
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters
                                                  progress:(AFURLSessionTaskProgressBlock)downloadProgress
                                                     error:(NSError *_Nullable __autoreleasing *)error {
    __block NSURLSessionDownloadTask *downloadTask = nil;
    BOOL resumeSucceeded = NO;
    NSURL *cacheURL = [self incompleteCachePathForDownloadPath:downloadPath];
    NSData *data = [NSData dataWithContentsOfURL:cacheURL];
    
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:FSTMethodTypeGet URLString:URLString parameters:parameters error:error];
    NSString *downloadTargetPath = [self prepareRequest:request downloadPath:downloadPath error:error];
    if (cacheURL && data) {
        @try {
            downloadTask = [self.manager downloadTaskWithResumeData:data progress:downloadProgress destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
                return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
            } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
                [self handleConnectTaskResult:downloadTask responseObject:filePath error:error];
            }];
            
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            resumeSucceeded = NO;
        }
    }
    
    if (!resumeSucceeded) {
        downloadTask = [self.manager downloadTaskWithRequest:request progress:downloadProgress destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
            [self handleConnectTaskResult:downloadTask responseObject:filePath error:error];
        }];
    }
    
    return downloadTask;
}

- (NSURLSessionTask *)dataTaskForConnectTask:(FSTConnectTask *)connectTask interceptor:(FSTInterceptor *)interceptor error:(NSError *_Nullable __autoreleasing *)error {
    NSString *url = [connectTask URLAbsoluteString];
    id parameters = [interceptor parameters];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForConnectTask:connectTask withRequestHeaders:interceptor.requestHeaders];
    FSTRequestMethod method = [connectTask requestMethod];
    AFConstructingBlock constructingBlock = [connectTask constructingBodyBlock];
    AFURLSessionTaskProgressBlock uploadProgressBlock = [connectTask uploadProgressBlock];
    
    switch (method) {
        case FSTRequestMethodGet:
            if (connectTask.resumableDownloadPath) {
                return [self downloadTaskWithDownloadPath:connectTask.resumableDownloadPath
                                        requestSerializer:requestSerializer
                                                URLString:url
                                               parameters:parameters
                                                 progress:connectTask.downloadProgressBlock
                                                    error:error];
            } else {
                return [self dataTaskWithHTTPMethod:FSTMethodTypeGet
                                  requestSerializer:requestSerializer
                                          URLString:url
                                         parameters:parameters
                                              error:error];
            }
        case FSTRequestMethodPost:
            return [self dataTaskWithHTTPMethod:FSTMethodTypePost
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:parameters
                                 uploadProgress:uploadProgressBlock
                      constructingBodyWithBlock:constructingBlock
                                          error:error];
        case FSTRequestMethodHead:
            return [self dataTaskWithHTTPMethod:FSTMethodTypeHead
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:parameters
                                          error:error];
        case FSTRequestMethodPut:
            return [self dataTaskWithHTTPMethod:FSTMethodTypePut
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:parameters
                                 uploadProgress:uploadProgressBlock
                      constructingBodyWithBlock:constructingBlock
                                          error:error];
        case FSTRequestMethodDelete:
            return [self dataTaskWithHTTPMethod:FSTMethodTypeDelete
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:parameters
                                          error:error];
        case FSTRequestMethodPatch:
            return [self dataTaskWithHTTPMethod:FSTMethodTypePatch
                              requestSerializer:requestSerializer
                                      URLString:url
                                     parameters:parameters
                                          error:error];
    }
}

- (void)handleConnectTaskResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    Lock();
    FSTConnectTask *connectTask = self.taskInfo[@(task.taskIdentifier)];
    Unlock();
    
    if (!connectTask) {
        return;
    }
    
    FSTInterceptor *interceptor = nil;
    NSError *__autoreleasing serializationError = nil;
    NSError *requestError = nil;
    
    BOOL succeed = YES;
    connectTask.responseObject = responseObject;
    if ([connectTask.responseObject isKindOfClass:[NSData class]]) {
        connectTask.responseData = responseObject;
        switch (connectTask.responseSerializerType) {
            case FSTResponseSerializerTypeHTTP: // 默认
                break;
            case FSTResponseSerializerTypeJSON:
                connectTask.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response
                                                                                               data:connectTask.responseData
                                                                                              error:&serializationError];
                break;
            case FSTResponseSerializerTypeXMLParser:
                connectTask.responseObject = [self.xmlParserResponseSerializer responseObjectForResponse:task.response
                                                                                                    data:connectTask.responseData
                                                                                                   error:&serializationError];
                break;
        }
    }
    
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (serializationError) {
        succeed = NO;
        requestError = serializationError;
    }
    
    if (succeed) {
        interceptor = [connectTask connectTaskDidFinishWithResponseObject:connectTask.responseObject responseData:connectTask.responseData];
    } else {
        interceptor = [connectTask connectTaskDidError:requestError];
    }
    
    if (requestError || interceptor.error) {
        NSError *error = requestError ?: interceptor.error;
        connectTask.error = error;
        [self connectDidFailWithConnectTask:connectTask error:connectTask.error];
    } else {
        connectTask.responseObject = interceptor.responseObject;
        connectTask.responseData = interceptor.responseData;
        [self connectDidSucceedWithConnectTask:connectTask];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeConnectTaskFromTaskInfo:connectTask];
        [connectTask clearAllBlocks];
    });
}

- (void)connectDidSucceedWithConnectTask:(FSTConnectTask *)connectTask {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (connectTask.delegate && [connectTask.delegate respondsToSelector:@selector(connectTaskDidSucceed:)]) {
            [connectTask.delegate connectTaskDidSucceed:connectTask];
        }
        
        if (connectTask.successConnectTaskBlock) {
            connectTask.successConnectTaskBlock(connectTask);
        }
    });
}

- (void)connectDidFailWithConnectTask:(FSTConnectTask *)connectTask error:(NSError *)error {
    connectTask.error = error;
    NSURL *cacheURL = nil;
    if (connectTask.resumableDownloadPath) {
        cacheURL = [self incompleteCachePathForDownloadPath:connectTask.resumableDownloadPath];
    }
    
    NSData *cacheDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (cacheDownloadData && cacheURL) {
        [cacheDownloadData writeToURL:cacheURL atomically:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (connectTask.delegate && [connectTask.delegate respondsToSelector:@selector(connectTaskDidFailed:)]) {
            [connectTask.delegate connectTaskDidFailed:connectTask];
        }
        
        if (connectTask.failureConnectTaskBlock) {
            connectTask.failureConnectTaskBlock(connectTask);
        }
    });
}

- (void)addConnectTaskToTaskInfo:(FSTConnectTask *)connectTask {
    Lock();
    self.taskInfo[@(connectTask.requestTask.taskIdentifier)] = connectTask;
    Unlock();
}

- (void)removeConnectTaskFromTaskInfo:(FSTConnectTask *)connectTask {
    Lock();
    [self.taskInfo removeObjectForKey:@(connectTask.requestTask.taskIdentifier)];
    Unlock();
}

#pragma mark - Public

- (void)addConnectTask:(FSTConnectTask *)connectTask {
    NSParameterAssert(connectTask != nil);
    
    FSTInterceptor *interceptor = [connectTask connectTaskWillStart];
    NSError *__autoreleasing requestSerializationError = nil;
    if (connectTask.customRequest) {
        NSURLRequest *request = connectTask.customRequest;
        if (request && ![request isKindOfClass:[NSMutableURLRequest class]]) {
            request = [request mutableCopy];
        }
        
        if (request && [request isKindOfClass:[NSMutableURLRequest class]]) {
            [(NSMutableURLRequest *)request setAllHTTPHeaderFields:interceptor.requestHeaders];
        }
        
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [self.manager dataTaskWithRequest:request
                                      uploadProgress:nil
                                    downloadProgress:nil
                                   completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
            [self handleConnectTaskResult:dataTask responseObject:responseObject error:error];
        }];
        connectTask.requestTask = dataTask;
    } else {
        connectTask.requestTask = [self dataTaskForConnectTask:connectTask interceptor:interceptor error:&requestSerializationError];
    }
    
    if (requestSerializationError || interceptor.error) {
        NSError *error = requestSerializationError ?: interceptor.error;
        connectTask.error = error;
        [self connectDidFailWithConnectTask:connectTask error:error];
        return;
    }
    
    if (interceptor.responseObject || interceptor.responseData) {
        connectTask.responseObject = interceptor.responseObject;
        connectTask.responseData = interceptor.responseData;
        [self connectDidSucceedWithConnectTask:connectTask];
        return;
    }
    
    connectTask.requestTask.priority = [self requestPriorityForConnectTask:connectTask];
    
    [self addConnectTaskToTaskInfo:connectTask];
    
    [connectTask.requestTask resume];
}

- (void)removeConnectTask:(FSTConnectTask *)connectTask {
    NSURL *cacheURL = [self incompleteCachePathForDownloadPath:connectTask.resumableDownloadPath];
    if (connectTask.resumableDownloadPath && cacheURL) {
        NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)connectTask.requestTask;
        [task cancelByProducingResumeData:^(NSData *_Nullable resumeData) {
            [resumeData writeToURL:cacheURL atomically:YES];
        }];
    } else {
        [connectTask.requestTask cancel];
    }
    
    [self removeConnectTaskFromTaskInfo:connectTask];
    
    [connectTask clearAllBlocks];
}

- (void)removeAllConnectTasks {
    Lock();
    NSArray *allKeys = [self.taskInfo allKeys];
    Unlock();
    
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            Lock();
            FSTConnectTask *connectTask = self.taskInfo[key];
            Unlock();
            
            [connectTask stop];
        }
    }
}

- (void)dealloc {
    _responseConvertBlock = NULL;
    pthread_mutex_destroy(&_lock);
}

@end
