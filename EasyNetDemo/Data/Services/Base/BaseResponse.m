//
//  BaseResponse.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <MJExtension/MJExtension.h>

#import "BaseResponse.h"

@implementation BaseResponse

@end

@implementation PhotoResponse

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"userId": @"id"};
}

@end

@implementation UserAddressData

@end

@implementation UserCompanyData

@end

@implementation UserResponse

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"userId": @"id"};
}

@end
