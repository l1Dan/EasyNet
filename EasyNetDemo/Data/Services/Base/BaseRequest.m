//
//  BaseRequest.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "BaseRequest.h"
#import "NetworkClient.h"

@implementation BaseRequest

+ (__kindof ENNetworkAgent *)networInstance {
    return [NetworkClient defaultClient];
}

- (NSString *)baseURL {
    return [NSString en_baseURLForClass:[BaseRequest class]];
}

- (ENRequestMethod)requestMethod {
    return ENRequestMethodGet;
}

@end

@implementation PhotosRequest

- (NSString *)requestURL {
    return @"/photos";
}

@end

@implementation UserRequest

- (instancetype)initWithUserId:(NSNumber *)userId {
    if (self = [super init]) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestURL {
    return [NSString stringWithFormat:@"/users/%@", self.userId];
}

@end

@implementation Post1CommentsRequest

- (NSString *)requestURL {
    return @"/posts/1/comments";
}

@end
