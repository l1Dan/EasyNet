//
//  PhotosTableViewCell.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PhotoModel;
@interface PhotosTableViewCell : UITableViewCell

@property (nonatomic, strong) PhotoModel *photoModel;

@end

NS_ASSUME_NONNULL_END
