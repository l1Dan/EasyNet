//
// ENInterceptor.m
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

#import "ENInterceptor.h"

@interface ENInterceptor ()

@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *requestURL;
@property (nonatomic, copy) NSString *method;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *allRequestHeaders;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *responseHeaders;

@end


@implementation ENInterceptor

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    return [[self allRequestHeaders] copy];
}

- (NSMutableDictionary<NSString *, NSString *> *)allRequestHeaders {
    if (!_allRequestHeaders) {
        _allRequestHeaders = [NSMutableDictionary dictionary];
    }
    return _allRequestHeaders;
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    if (!field) {
        return nil;
    }
    return [self.allRequestHeaders valueForKey:field.lowercaseString];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [self.allRequestHeaders setValue:value forKey:field.lowercaseString];
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    NSString *oldValue = [self valueForHTTPHeaderField:field];
    if (oldValue && value) {
        [self setValue:[NSString stringWithFormat:@"%@,%@", oldValue, value] forHTTPHeaderField:field];
    } else {
        [self setValue:value forHTTPHeaderField:field];
    }
}

- (void)setAllHTTPRequestHeaders:(NSDictionary<NSString *, NSString *> *)requestHeaders {
    if (requestHeaders && requestHeaders.count) {
        for (NSString *key in requestHeaders.allKeys) {
            [self setValue:requestHeaders[key] forHTTPHeaderField:key];
        }
    }
}

@end
