//
//  ProfileTableViewPresenter.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ProfileTableViewPresenter;
@protocol ProfileTableView <NSObject>

@optional
- (void)profileTableViewPresenter:(ProfileTableViewPresenter *)present updateTitleText:(NSString *)titleText;

@end

@interface ProfileTableViewPresenter : NSObject

@property (nonatomic, weak, nullable) id<ProfileTableView> view;
@property (nonatomic, strong, readonly) NSArray<NSString *> *profiles;

- (void)requestUserProfileWithUserId:(NSNumber *)userId success:(void (^_Nullable)(void))success failure:(void (^_Nullable)(NSError *_Nullable error))failure;

@end

NS_ASSUME_NONNULL_END
