//
//  AccessRequest.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "AccessRequest.h"
#import "AccessClient.h"

@implementation AccessRequest

+ (__kindof FSTNetworkMediator *)networInstance {
    return [AccessClient defaultClient];
}

- (NSString *)requestURL {
    return @"/posts/1";
}

@end
