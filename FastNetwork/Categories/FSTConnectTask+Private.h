//
// FSTConnectTask+Private.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NSString *FSTMethodType NS_STRING_ENUM;

FOUNDATION_EXPORT FSTMethodType const FSTMethodTypeGet;
FOUNDATION_EXPORT FSTMethodType const FSTMethodTypePost;
FOUNDATION_EXPORT FSTMethodType const FSTMethodTypeHead;
FOUNDATION_EXPORT FSTMethodType const FSTMethodTypePut;
FOUNDATION_EXPORT FSTMethodType const FSTMethodTypeDelete;
FOUNDATION_EXPORT FSTMethodType const FSTMethodTypePatch;


@interface FSTConnectTask (URLRequest)

/// Method 转字符串
@property (nonatomic, copy, readonly) FSTMethodType methodType;

/// 绝对路径(BaseURL+RequestURL)
@property (nonatomic, copy, readonly) NSString *URLAbsoluteString;

/// 绝对路径加所有参数(BaseURL+RequestURL+Parameters)
@property (nonatomic, copy, readonly) NSString *URLAbsoluteStringWithParameters;

@end


@interface FSTConnectTask (ResponseCache)

/// 取出保存的缓存数据
/// @param connectTask 当前 FSTConnectTask
/// @param block 完成回调
+ (void)responseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(FSTConnectTask *connectTask))block;

/// 保存缓存数据
/// @param connectTask 当前 FSTConnectTask
/// @param block 完成回调
+ (void)setResponseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(FSTConnectTask *connectTask))block;

/// 移除已经缓存的数据
/// @param connectTask 当前 FSTConnectTask
/// @param block 完成回调
+ (void)removeResponseWithConnectTask:(FSTConnectTask *)connectTask usingBlock:(void (^)(NSString *key))block;

@end


@interface FSTConnectTask (Interceptor)

/// 拦截器开始请求
- (FSTInterceptor *)connectTaskWillStart;

/// 拦截器完成请求，请求成功
/// @param responseObject 请求成功 JSON 数据
/// @param responseData 请求成功 Data 数据
- (FSTInterceptor *)connectTaskDidFinishWithResponseObject:(id)responseObject responseData:(NSData *)responseData;

/// 拦截器完成请求，请求失败
/// @param error 错误信息
- (FSTInterceptor *)connectTaskDidError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
