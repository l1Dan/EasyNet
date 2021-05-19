//
//  ProfileTableViewDataSource.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ProfileTableViewPresenter;
@interface ProfileTableViewDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithPresenter:(ProfileTableViewPresenter *)presenter;

@end

NS_ASSUME_NONNULL_END
