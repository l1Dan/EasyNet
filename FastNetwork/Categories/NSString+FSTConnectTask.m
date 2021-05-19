//
// NSString+FSTConnectTask.m
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


#import <CommonCrypto/CommonDigest.h>
#import <pthread/pthread.h>

#import "NSString+FSTConnectTask.h"

static NSMutableDictionary *_registerClassInfo;
static pthread_mutex_t _registerClassLock;

FOUNDATION_EXPORT NSArray *_FSTQueryStringPairsFromKeyAndValue(NSString *key, id value);
FOUNDATION_EXPORT NSArray *_FSTQueryStringPairsFromDictionary(NSDictionary *dictionary);

NSString *_FSTPercentEscapedStringFromString(NSString *string) {
    static NSString *const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString *const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}


@interface _FSTQueryStringPair : NSObject

@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;

@end


@implementation _FSTQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return _FSTPercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", _FSTPercentEscapedStringFromString([self.field description]), _FSTPercentEscapedStringFromString([self.value description])];
    }
}

@end


NSString *_FSTQueryStringFromParameters(NSDictionary *parameters) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (_FSTQueryStringPair *pair in _FSTQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray *_FSTQueryStringPairsFromDictionary(NSDictionary *dictionary) { return _FSTQueryStringPairsFromKeyAndValue(nil, dictionary); }

NSArray *_FSTQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an
        // array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:_FSTQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:_FSTQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            [mutableQueryStringComponents addObjectsFromArray:_FSTQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[_FSTQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}


@implementation NSString (FSTConnectTask)

- (NSString *)fst_md5String {
    NSParameterAssert(self != nil && [self length] > 0);
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    
    return outputString;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _registerClassInfo = [NSMutableDictionary dictionary];
        pthread_mutex_init(&_registerClassLock, NULL);
    });
}

#pragma mark - Private

+ (NSString *)_fst_replacmentWhitespaceStringFromString:(NSString *)string {
    if (string == nil) return string;
    
    NSString *str = [string stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)_fst_buildPathWithBaseURL:(NSString *)baseURL requestURL:(NSString *)requestURL {
    if (requestURL && requestURL.length) {
        requestURL = [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    if (baseURL && baseURL.length) {
        baseURL = [baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURL *url = [NSURL URLWithString:requestURL];
    if (url && url.host && url.scheme) {
        return [url absoluteString];
    } else {
        NSURL *url = [NSURL URLWithString:baseURL];
        return [[NSURL URLWithString:requestURL relativeToURL:url] absoluteString];
    }
}

#pragma mark - Public

#pragma mark URL 注册机制

+ (void)fst_registerClass:(Class)className forBaseURL:(NSString *)baseURL {
    pthread_mutex_lock(&_registerClassLock);
    _registerClassInfo[NSStringFromClass(className)] = baseURL;
    pthread_mutex_unlock(&_registerClassLock);
}

+ (void)fst_unregisterClass:(Class)className {
    pthread_mutex_lock(&_registerClassLock);
    [_registerClassInfo removeObjectForKey:NSStringFromClass(className)];
    pthread_mutex_unlock(&_registerClassLock);
}

+ (NSString *)fst_baseURLForClass:(Class)className {
    NSString *url = _registerClassInfo[NSStringFromClass(className)];
    if (!url || ![url isKindOfClass:[NSString class]] || [self _fst_replacmentWhitespaceStringFromString:url].length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"请先注册 BaseURL 然后再使用！" userInfo:nil];
    }
    return url;
}

#pragma mark JSON

+ (NSString *)fst_JSONPrettyPrintedWithObject:(id)object {
    if (!object) return nil;
    
    if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]]) {
        @try {
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
            if (!data) return [NSString stringWithFormat:@"%@", object];
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } @catch (NSException *exception) {
            return [NSString stringWithFormat:@"%@", object];
        }
    } else if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else {
        return [NSString stringWithFormat:@"%@", object];
    }
}

#pragma mark URL

+ (NSString *)fst_buildPathWithBaseURL:(NSString *)baseURL requestURL:(NSString *)requestURL parameters:(id)parameters {
    NSString *path = [self _fst_buildPathWithBaseURL:baseURL requestURL:requestURL];
    if (!path || !parameters) {
        return path;
    }
    
    NSString *query = _FSTQueryStringFromParameters(parameters);
    if (!query) {
        return path;
    }
    
    return [NSString stringWithFormat:@"%@?%@", path, query];
}

@end
