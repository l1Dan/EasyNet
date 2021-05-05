//
//  ProfileTableViewPresenter.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "ProfileTableViewPresenter.h"
#import "UserModel.h"

#import "NetworkClient+Request.h"

@interface ProfileTableViewPresenter ()

@property (nonatomic, strong) NSArray<NSString *> *profiles;

@end

@implementation ProfileTableViewPresenter

- (void)requestUserProfileWithUserId:(NSNumber *)userId success:(void (^)(void))success failure:(void (^)(NSError * _Nullable))failure {
    [[NetworkClient defaultClient] requestUserWithUserId:userId success:^(UserRequest * _Nonnull request) {
        if ([request.convertObject isKindOfClass:[UserResponse class]]) {
            UserResponse *response = request.convertObject;
            UserModel *user = [[UserModel alloc] initWithUserResponse:request.convertObject];
            self.profiles = user.profiles;
            
            if ([self.view respondsToSelector:@selector(profileTableViewPresenter:updateTitleText:)]) {
                [self.view profileTableViewPresenter:self updateTitleText:response.name];
            }
            
            if (success) { success(); }
        } else {
            if (failure) { failure(request.error); }
        }
    } failure:^(UserRequest * _Nonnull request) {
        if (failure) { failure(request.error); }
    }];
}

#pragma mark - Getter

- (NSArray<NSString *> *)profiles {
    if (!_profiles) {
        _profiles = [NSArray array];
    }
    return _profiles;
}

@end
