//
//  NetworkClient.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <MJExtension/MJExtension.h>
#import <YYCache/YYCache.h>

#import "NetworkClient.h"

#import "BaseRequest.h"

#import "AccessTokenInterceptor.h"
#import "LoggerInterceptor.h"
#import "NetworkReachInterceptor.h"

static NSString *const NetworkStorageCacheDirectory = @"com.github.l1Dan.EasyNetDemo.cache.default";

static YYCache *_customCacheInstance = nil;

@interface YYCache (Helper)

/// 获取缓存对象
+ (instancetype)sharedCache;

/// 设置缓存对象
/// @param sharedCache 缓存对象
+ (void)setSharedCache:(id)sharedCache;

/// 清除缓存
/// @param handler 完成回调
- (void)clearAllCachesDataWithCompletionHandler:(void (^)(void))handler;

@end


@implementation YYCache (Helper)

+ (void)setSharedCache:(id)sharedCache {
    NSAssert([sharedCache isKindOfClass:[YYCache class]], @"请使用 YYCache 子类创建！");
    _customCacheInstance = sharedCache;
}

+ (instancetype)sharedCache {
    NSAssert(_customCacheInstance != nil, @"请使用 YYCache 子类创建！");
    return _customCacheInstance;
}

- (void)clearAllCachesDataWithCompletionHandler:(void (^)(void))handler {
    [_customCacheInstance removeAllObjectsWithBlock:handler];
}

@end


@interface URLResponseCache : YYCache <ENResponseCacheable>

@end


@implementation URLResponseCache

- (void)setCacheObject:(id)object forKey:(NSString *)key usingBlock:(void (^)(void))block {
    [self setObject:object forKey:key withBlock:block];
}

- (void)cacheObjectForKey:(NSString *)key usingBlock:(void (^)(NSString *_Nonnull, id _Nonnull))block {
    [self objectForKey:key withBlock:block];
}

- (void)removecacheObjectForKey:(NSString *)key usingBlock:(void (^)(NSString *key))block {
    [self removeObjectForKey:key withBlock:block];
}

@end

@implementation NetworkClient

+ (NetworkClient *)defaultClient {
    static NetworkClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkClient alloc] init];
        
        // 设置拦截器
        [instance addGlobalInterceptor:[AccessTokenInterceptor new]];
        [instance addGlobalInterceptor:[LoggerInterceptor new]];
        [instance addGlobalInterceptor:[NetworkReachInterceptor new]];
        
        // 设置缓存大小
        URLResponseCache *cache = [URLResponseCache cacheWithName:NetworkStorageCacheDirectory];
        cache.memoryCache.ageLimit = 60 * 60 * 24;   // 24 hour
        cache.diskCache.ageLimit = 60 * 60 * 24 * 7; // 1 week
        
        // 替换原来默认的缓存
        [URLResponseCache setSharedCache:cache];
        // 设置请求队列缓存对象
        instance.cacheInstance = [URLResponseCache sharedCache];

        // JSON 解析
        [instance setResponseConvertBlock:^id _Nullable(Class  _Nonnull __unsafe_unretained convert, id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                return [convert mj_objectArrayWithKeyValuesArray:responseObject];
            }
            return [convert mj_objectWithKeyValues:responseObject];
        }];
    });
    return instance;
}

@end
