//
// NSString+FSTConnectTask.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSString (FSTConnectTask)

- (NSString *)fst_md5String;

/// 添加注册的 class，class 不要使用 self 或者 [self class] 必须指定为注册时的类名
/// @param className 指定 registerClass
/// @param baseURL 注册的 baseURL
+ (void)fst_registerClass:(Class)className forBaseURL:(NSString *)baseURL;

/// 移除注册的 class，class 不要使用 self 或者 [self class] 必须指定为注册时的类名
/// @param className 指定 registerClass
+ (void)fst_unregisterClass:(Class)className;

/// 获取注册 class 对应的 BaseURL，class 不要使用 self 或者 [self class] 必须指定为注册时的类名
/// @param className 指定 registerClass
+ (NSString *)fst_baseURLForClass:(Class)className;

/// JSONObject to String
/// @param object JSON
+ (NSString *)fst_JSONPrettyPrintedWithObject:(id)object;

/// 获取绝对路径并且拼接参数
/// @param baseURL Base URL
/// @param requestURL Request URL
/// @param parameters 请求参数
+ (NSString *)fst_buildPathWithBaseURL:(nullable NSString *)baseURL requestURL:(nullable NSString *)requestURL parameters:(nullable id)parameters;

@end

NS_ASSUME_NONNULL_END
