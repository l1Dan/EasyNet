//
// FSTNetworkMediator.h
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

#import "FSTConnectTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^FSTResponseConvertBlock)(Class convert, id _Nullable responseObject);

@protocol FSTResponseCacheable <NSObject>

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
@interface FSTNetworkMediator : NSObject

/// 需要外部设置
@property (nonatomic, strong) id<FSTResponseCacheable> cacheInstance;

/// 全局拦截器
@property (nonatomic, strong, readonly) NSMutableArray<id<FSTInterceptable>> *globalInterceptors;

/// 设置 JSON 转模型时需要执行的操作，仅当使用此  `-startWithConvert:success:failure:`  方法时才会调用
@property (nonatomic, copy) FSTResponseConvertBlock responseConvertBlock;

/// 添加全局拦截器
/// @param interceptor id<FSTInterceptable>
- (void)addGlobalInterceptor:(id<FSTInterceptable>)interceptor;

/// 添加 FSTConnectTask
/// @param connectTask FSTConnectTask
- (void)addConnectTask:(FSTConnectTask *)connectTask;

/// 移除 FSTConnectTask
/// @param connectTask FSTConnectTask
- (void)removeConnectTask:(FSTConnectTask *)connectTask;

/// 移除所有 FSTConnectTask
- (void)removeAllConnectTasks;

@end

NS_ASSUME_NONNULL_END
