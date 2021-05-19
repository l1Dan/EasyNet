//
//  PhotosTableViewPresenter.h
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PhotosTableViewPresenter, PhotoModel;

@protocol PhotosTableView <NSObject>

@optional
- (void)photosTableViewPresenter:(PhotosTableViewPresenter *)presenter didSelectUserId:(NSNumber *)userId;

@end

@interface PhotosTableViewPresenter : NSObject

@property (nonatomic, weak, nullable) id<PhotosTableView> view;
@property (nonatomic, strong, readonly) NSArray<PhotoModel *> *photos;

- (void)requestPhotosWithSuccess:(void (^_Nullable)(void))success failure:(void (^_Nullable)(NSError *_Nullable error))failure;

@end

NS_ASSUME_NONNULL_END
