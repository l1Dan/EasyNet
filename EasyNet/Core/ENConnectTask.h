//
// ENConnectTask.h
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

#import <Foundation/Foundation.h>

#import "ENInterceptor.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSInteger const ENConnectTaskCacheNotFoundErrorCode;   // 缓存找不到
FOUNDATION_EXPORT NSString *const ENConnectTaskCacheNotFoundErrorDomain; // 缓存找不到

FOUNDATION_EXPORT NSInteger const ENConnectTaskJSONSerializationErrorCode;   // JSON 解析出错
FOUNDATION_EXPORT NSString *const ENConnectTaskJSONSerializationErrorDomain; // JSON 解析出错

typedef NS_ENUM(NSUInteger, ENRequestMethod) {
    ENRequestMethodGet = 0,
    ENRequestMethodPost,
    ENRequestMethodHead,
    ENRequestMethodPut,
    ENRequestMethodDelete,
    ENRequestMethodPatch,
};

typedef NS_ENUM(NSInteger, ENRequestSerializerType) {
    ENRequestSerializerTypeHTTP = 0,
    ENRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, ENResponseSerializerType) {
    ENResponseSerializerTypeHTTP,
    ENResponseSerializerTypeJSON,
    ENResponseSerializerTypeXMLParser,
};

typedef NS_ENUM(NSInteger, ENRequestPriority) {
    ENRequestPriorityLow = -4L,
    ENRequestPriorityDefault = 0,
    ENRequestPriorityHigh = 4,
};

typedef NS_ENUM(NSUInteger, ENRequestCachePolicy) {
    ENRequestCachePolicyDefault,              // HTTP(s) 默认
    ENRequestCachePolicyStaleWhileRevalidate, // 数据太旧需要重新校验，缓存请求到的数据
    ENRequestCachePolicyNetFirst,             // 网络数据优先；没有网络数据找缓存，缓存没有数据则返回请求失败
    ENRequestCachePolicyNetOnly,              // 强制使用网络数据
    ENRequestCachePolicyCacheFirst,           // 缓存数据优先；没有缓存数据找网络，网络请求失败则返回请求失败
    ENRequestCachePolicyCacheOnly             // 强制使用缓存数据
};


@class ENConnectTask, ENNetworkAgent;
@protocol AFMultipartFormData;

typedef void (^ENConnectTaskBlock)(__kindof ENConnectTask *connectTask);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);

/// 遵守协议即可实现数据转模型操作
@protocol ENResponseJSONConvertible <NSObject>

@optional

/// 自定义数据转换方式。如果实现则不调用自动转换流程
/// @param object 请求接收到的 responseObject
+ (nullable id<ENResponseJSONConvertible>)customConvertFromObject:(id)object;

@end

@protocol ENConnectTaskDelegate <NSObject>

@optional

/// 连接获取数据成功
/// @param connectTask ENConnectTask
- (void)connectTaskDidSucceed:(ENConnectTask *)connectTask;

/// 连接获取数据失败
/// @param connectTask ENConnectTask
- (void)connectTaskDidFailed:(ENConnectTask *)connectTask;

@end


@interface ENConnectTask : NSObject

/// 设置网络请求实例对象，ENNetworkAgent 或者子类，子类最好使用单例设计，可选重写，则内部默认使用 ENNetworkAgent 单例
@property (nonatomic, strong, readonly, class) ENNetworkAgent __kindof *networInstance;

#pragma mark - ####################### 必须重写 #######################

/// 请求相对路径，如果是绝对路径则不拼接 BaseURL，必须重写
@property (nonatomic, copy, readonly) NSString *requestURL;

#pragma mark - ####################### 可选重写（开始） #######################

/// BaseURL，可选重写
@property (nonatomic, copy, readonly, nullable) NSString *baseURL;

/// 完全自定义 Request 忽略所有重写参数，可选重写
@property (nonatomic, strong, readonly, nullable) NSURLRequest *customRequest;

/// 请求头，可选重写，默认 nil
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;

/// 请求参数，可选重写，默认 nil
@property (nonatomic, strong, readonly, nullable) id parameters;

/// 下载地址，可选重写，默认 nil，仅当 ENRequestMethodGet 时才会判断 resumableDownloadPath
@property (nonatomic, strong, nullable) NSString *resumableDownloadPath;

/// 是否使用自定义缓存，可选重写，默认 NO（与 HTTP 缓存策略无关）
@property (nonatomic, assign, readonly) ENRequestCachePolicy cachePolicy;

/// 请求超时时间，可选重写，默认 60s
@property (nonatomic, assign, readonly) NSTimeInterval requestTimeout;

/// 是允许数据流量访问，可选重写，默认 YES
@property (nonatomic, assign, readonly, getter=isAllowsCellularAccess) BOOL allowsCellularAccess;

/// 将请求参数拼接在 URI 里面，默认 YES，只针对 "GET"、"HEAD"、"DELETE" 有效，可选重写
@property (nonatomic, assign, readonly, getter=isEnableParametersInURI) BOOL enableParametersInURI;

/// 请求方式，可选重写，默认 ENRequestMethodGet
@property (nonatomic, assign, readonly) ENRequestMethod requestMethod;

/// 请求优先级，可选重写，默认 ENRequestPriorityDefault
@property (nonatomic, assign, readonly) ENRequestPriority requestPriority;

/// 请求序列化方式，可选重写，默认 ENRequestSerializerTypeHTTP
@property (nonatomic, assign, readonly) ENRequestSerializerType requestSerializerType;

/// 响应序列化方式，可选重写，默认 ENResponseSerializerTypeJSON
@property (nonatomic, assign, readonly) ENResponseSerializerType responseSerializerType;

/// 上传 Form 回调数据，可选重写
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

/// 是否忽略本次调用的拦截器，可选重写 默认`NO`
/// @param interceptor 自动传入的拦截器对象
- (BOOL)ignoreInterceptor:(id<ENInterceptable>)interceptor;

#pragma mark - ####################### 重写（结束） #######################

/// 当前执行任务的 Task，不需要重写
@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;

/// 当前请求信息，不需要重写
@property (nonatomic, strong, readonly) NSURLRequest *currentReuqest;

/// 原始请求信息，不需要重写
@property (nonatomic, strong, readonly) NSURLRequest *originalReuqest;

/// 响应信息，不需要重写
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

/// 拦截器，不需要重写
@property (nonatomic, strong, readonly) NSMutableArray<id<ENInterceptable>> *interceptors;

/// 响应头，不需要重写
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, NSString *> *responseHeaders;

/// 响应数据，不需要重写
@property (nonatomic, strong, readonly, nullable) NSData *responseData;

/// 响应体，不需要重写
@property (nonatomic, strong, readonly, nullable) id responseObject;

///  响应体，不需要重写。遵循 id<ENResponseJSONConvertible> 转换成功的对象
@property (nonatomic, strong, readonly, nullable) id<ENResponseJSONConvertible> convertObject;

/// 请求出错信息，不需要重写
@property (nonatomic, strong, readonly, nullable) NSError *error;

/// 响应状态码，不需要重写
@property (nonatomic, assign, readonly) NSInteger statusCode;

/// 是否已经需要连接，不需要重写
@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;

/// 是否在连接中，不需要重写
@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

/// 通过代理方式获取回调数据
@property (nonatomic, weak, nullable) id<ENConnectTaskDelegate> delegate;

/// 请求成功回调，不需要重写
@property (nonatomic, copy, nullable) ENConnectTaskBlock successConnectTaskBlock;

/// 请求失败回调，不需要重写
@property (nonatomic, copy, nullable) ENConnectTaskBlock failureConnectTaskBlock;

/// 上传进度，不需要重写
@property (nonatomic, copy, nullable) AFURLSessionTaskProgressBlock uploadProgressBlock;

/// 下载进度，不需要重写
@property (nonatomic, copy, nullable) AFURLSessionTaskProgressBlock downloadProgressBlock;

/// 添加拦截器
/// @param interceptor id<ENInterceptable>
- (void)addInterceptor:(id<ENInterceptable>)interceptor;

/// 清除所有连接中保存的 Block 信息
- (void)clearAllBlocks;

/// 启动连接
- (void)start;

/// 关闭、取消连接
- (void)stop;

/// 启动连接并通过 Block 方式回调数据
/// @param success 成功回调
/// @param failure 失败回调
- (void)startWithSuccess:(nullable ENConnectTaskBlock)success failure:(nullable ENConnectTaskBlock)failure;

/// 启动连接并实现数据转模型，通过 Block 方式回调数据
/// 如果需要自定义数据解析，实现 ENResponseJSONConvertible 方法即可
/// @param convert 可转换的模型对象
/// @param success 成功回调
/// @param failure 失败回调
- (void)startWithConvert:(Class)convert success:(nullable ENConnectTaskBlock)success failure:(nullable ENConnectTaskBlock)failure;

@end

NS_ASSUME_NONNULL_END
