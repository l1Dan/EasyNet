//
// ENConnectTask+Private.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NSString *ENMethodType NS_STRING_ENUM;

FOUNDATION_EXPORT ENMethodType const ENMethodTypeGet;
FOUNDATION_EXPORT ENMethodType const ENMethodTypePost;
FOUNDATION_EXPORT ENMethodType const ENMethodTypeHead;
FOUNDATION_EXPORT ENMethodType const ENMethodTypePut;
FOUNDATION_EXPORT ENMethodType const ENMethodTypeDelete;
FOUNDATION_EXPORT ENMethodType const ENMethodTypePatch;


@interface ENConnectTask (URLRequest)

/// Method 转字符串
@property (nonatomic, copy, readonly) ENMethodType methodType;

/// 绝对路径(BaseURL+RequestURL)
@property (nonatomic, copy, readonly) NSString *URLAbsoluteString;

/// 绝对路径加所有参数(BaseURL+RequestURL+Parameters)
@property (nonatomic, copy, readonly) NSString *URLAbsoluteStringWithParameters;

@end


@interface ENConnectTask (ResponseCache)

/// 取出保存的缓存数据
/// @param connectTask 当前 ENConnectTask
/// @param block 完成回调
+ (void)responseWithConnectTask:(ENConnectTask *)connectTask usingBlock:(void (^)(ENConnectTask *connectTask))block;

/// 保存缓存数据
/// @param connectTask 当前 ENConnectTask
/// @param block 完成回调
+ (void)setResponseWithConnectTask:(ENConnectTask *)connectTask usingBlock:(void (^)(ENConnectTask *connectTask))block;

/// 移除已经缓存的数据
/// @param connectTask 当前 ENConnectTask
/// @param block 完成回调
+ (void)removeResponseWithConnectTask:(ENConnectTask *)connectTask usingBlock:(void (^)(NSString *key))block;

@end


@interface ENConnectTask (Interceptor)

/// 拦截器开始请求
- (ENInterceptor *)connectTaskWillStart;

/// 拦截器完成请求，请求成功
/// @param responseObject 请求成功 JSON 数据
/// @param responseData 请求成功 Data 数据
- (ENInterceptor *)connectTaskDidFinishWithResponseObject:(id)responseObject responseData:(NSData *)responseData;

/// 拦截器完成请求，请求失败
/// @param error 错误信息
- (ENInterceptor *)connectTaskDidError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
