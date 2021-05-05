//
//  PhotoModel.h
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat const PhotosTableViewCellRowHeight = 120;

@class PhotoResponse;
@interface PhotoModel : NSObject

@property (nonatomic, strong, readonly) NSNumber *albumId;
@property (nonatomic, strong, readonly) NSNumber *userId;

@property (nonatomic, copy, readonly) NSString *thumbnailUrl;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *url;

- (instancetype)initWithPhotoResponse:(PhotoResponse *)response;

@end

NS_ASSUME_NONNULL_END
