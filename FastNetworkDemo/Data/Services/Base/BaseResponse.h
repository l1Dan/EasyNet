//
//  BaseResponse.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseResponse : NSObject

@end

@interface PhotoResponse : NSObject

@property (nonatomic, strong) NSNumber *albumId;
@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end

@interface UserAddressData : NSObject

@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *suite;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *zipcode;

@end

@interface UserCompanyData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *catchPhrase;
@property (nonatomic, copy) NSString *bs;

@end

@interface UserResponse : NSObject

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) UserAddressData *address;
@property (nonatomic, strong) UserCompanyData *company;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *website;

@end

NS_ASSUME_NONNULL_END
