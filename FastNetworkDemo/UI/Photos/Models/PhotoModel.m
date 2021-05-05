//
//  PhotoModel.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "PhotoModel.h"
#import "BaseResponse.h"

@implementation PhotoModel

- (instancetype)initWithPhotoResponse:(PhotoResponse *)response {
    if (self = [super init]) {
        _albumId = response.albumId;
        _userId = response.userId;
        _thumbnailUrl = response.thumbnailUrl;
        _title = response.title;
        _url = response.url;
    }
    return self;
}

@end
