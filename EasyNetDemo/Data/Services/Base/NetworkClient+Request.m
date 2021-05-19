//
//  NetworkClient+Request.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "NetworkClient+Request.h"

@implementation NetworkClient (Request)

- (void)requestPhotosWithSuccess:(void (^)(PhotosRequest * _Nonnull))success failure:(void (^)(PhotosRequest * _Nonnull))failure {
    PhotosRequest *request = [[PhotosRequest alloc] init];
    [request startWithConvert:[PhotoResponse class] success:success failure:failure];
}

- (void)requestUserWithUserId:(NSNumber *)userId success:(void (^)(UserRequest * _Nonnull))success failure:(void (^)(UserRequest * _Nonnull))failure {
    UserRequest *request = [[UserRequest alloc] initWithUserId:userId];
    [request startWithConvert:[UserResponse class] success:success failure:failure];
}

@end
