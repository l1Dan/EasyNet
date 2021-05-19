//
//  PhotosTableViewDataSource.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PhotosTableViewPresenter;
@interface PhotosTableViewDataSource : NSObject <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithPresenter:(PhotosTableViewPresenter *)presenter;

@end

NS_ASSUME_NONNULL_END
