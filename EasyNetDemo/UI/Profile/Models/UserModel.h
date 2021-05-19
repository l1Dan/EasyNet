//
//  UserModel.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat const ProfileTableViewCellRowHeight = 40;

@class UserResponse;

@interface UserModel : NSObject

@property (nonatomic, strong, readonly) NSArray<NSString *> *profiles;

- (instancetype)initWithUserResponse:(UserResponse *)response;

@end

NS_ASSUME_NONNULL_END
