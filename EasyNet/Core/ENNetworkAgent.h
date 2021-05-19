//
// ENNetworkAgent.h
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

#import "ENConnectTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^ENResponseConvertBlock)(Class convert, id _Nullable responseObject);

@protocol ENResponseCacheable <NSObject>

/// 异步设置缓存
/// @param key 缓存标志
/// @param block 处理完成回调
- (void)cacheObjectForKey:(NSString *)key usingBlock:(nullable void (^)(NSString *key, id object))block;

/// 异步获取缓存
/// @param object 缓存对象
/// @param key 缓存标志
/// @param block 处理完成回调
- (void)setCacheObject:(nullable id)object forKey:(NSString *)key usingBlock:(nullable void (^)(void))block;

/// 异步移除缓存
/// @param key 缓存标志
/// @param block 处理完成回调
- (void)removecacheObjectForKey:(NSString *)key usingBlock:(void (^)(NSString *key))block;

@end

/// 连接队列，有所有的连接
@interface ENNetworkAgent : NSObject

/// 需要外部设置
@property (nonatomic, strong) id<ENResponseCacheable> cacheInstance;

/// 全局拦截器
@property (nonatomic, strong, readonly) NSMutableArray<id<ENInterceptable>> *globalInterceptors;

/// 设置 JSON 转模型时需要执行的操作，仅当使用此  `-startWithConvert:success:failure:`  方法时才会调用
@property (nonatomic, copy) ENResponseConvertBlock responseConvertBlock;

/// 添加全局拦截器
/// @param interceptor id<ENInterceptable>
- (void)addGlobalInterceptor:(id<ENInterceptable>)interceptor;

/// 添加 ENConnectTask
/// @param connectTask ENConnectTask
- (void)addConnectTask:(ENConnectTask *)connectTask;

/// 移除 ENConnectTask
/// @param connectTask ENConnectTask
- (void)removeConnectTask:(ENConnectTask *)connectTask;

/// 移除所有 ENConnectTask
- (void)removeAllConnectTasks;

@end

NS_ASSUME_NONNULL_END
