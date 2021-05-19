//
// NSURLSession+HTTPProxy.m
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

#import <objc/runtime.h>

#import "NSURLSession+HTTPProxy.h"

static inline void ENHTTPProxySwizzleMethod(Class aClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(aClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(aClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@implementation NSURLSession (HTTPProxy)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ENHTTPProxySwizzleMethod([NSURLSession class], @selector(sessionWithConfiguration:), @selector(_en_sessionWithConfiguration:));
        ENHTTPProxySwizzleMethod([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:), @selector(_en_sessionWithConfiguration:delegate:delegateQueue:));
    });
}

#pragma mark - NSURLSession

+ (NSURLSession *)_en_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    if (![self en_httpProxyEnabled]) {
        configuration.connectionProxyDictionary = @{};
    }
    
    return [self _en_sessionWithConfiguration:configuration];
}

+ (NSURLSession *)_en_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    if (![self en_httpProxyEnabled]) {
        configuration.connectionProxyDictionary = @{};
    }
    
    return [self _en_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

#pragma mark - Public

+ (BOOL)en_httpProxyEnabled {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number && [number isKindOfClass:[NSNumber class]]) {
        return [number boolValue];
    }
    return NO;
}

+ (void)setEn_httpProxyEnabled:(BOOL)en_httpProxyEnabled {
    objc_setAssociatedObject(self, @selector(en_httpProxyEnabled), [NSNumber numberWithBool:en_httpProxyEnabled], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
