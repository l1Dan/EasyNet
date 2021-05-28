//
// ENInterceptor.h
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

NS_ASSUME_NONNULL_BEGIN

typedef float ENInterceptorPriority NS_TYPED_EXTENSIBLE_ENUM;

static const ENInterceptorPriority ENInterceptorPriorityRequired = 1000;
static const ENInterceptorPriority ENInterceptorPriorityDefaultHigh = 750;
static const ENInterceptorPriority ENInterceptorPriorityDefault = 500;
static const ENInterceptorPriority ENInterceptorPriorityDefaultLow = 250;

@class ENInterceptor;
@protocol ENInterceptable <NSObject>

@optional

/// 设置拦截器调用顺序优先级，数值越大优先级越高，拦截器调用时间越早。
/// 默认优先级：自定义拦截器默认优先级为：ENInterceptorPriorityDefault，全局拦截器默认优先级为：ENInterceptorPriorityDefaultHigh
@property (nonatomic, assign, readonly) ENInterceptorPriority interceptorPriority;

/// 拦截将要请求的数据
/// @param interceptor ENInterceptor
- (ENInterceptor *)interceptorWillStart:(ENInterceptor *)interceptor;

/// 拦截请求完成数据
/// @param interceptor ENInterceptor
- (ENInterceptor *)interceptorDidSuccess:(ENInterceptor *)interceptor;

/// 拦截请求失败数据
/// @param interceptor ENInterceptor
- (ENInterceptor *)interceptorDidFailure:(ENInterceptor *)interceptor;

@end


@interface ENInterceptor : NSObject

@property (nonatomic, copy, readonly) NSString *baseURL;
@property (nonatomic, copy, readonly) NSString *requestURL;
@property (nonatomic, copy, readonly) NSString *method;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *requestHeaders;
@property (nonatomic, strong) id parameters;

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *responseHeaders;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSError *responseError;

/// 获取 requestHeaders value
/// @param field key
- (nullable NSString *)valueForHTTPHeaderField:(NSString *)field;

/// 添加 requestHeaders value
/// @param value 需要添加的值，如果已经存在则会使用 `,` 分割每个值
/// @param field key
- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/// 设置 requestHeaders value
/// @param value 需要设置的值，如果已经存在则替换原来的值
/// @param field key
- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field;

/// 从字典设置 requestHeaders value，如果已经存在则替换原来的值
/// @param requestHeaders 需要添加的 requestHeaders
- (void)setAllHTTPRequestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders;

@end

NS_ASSUME_NONNULL_END
