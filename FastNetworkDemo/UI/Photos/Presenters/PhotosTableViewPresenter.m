//
//  PhotosTableViewPresenter.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "PhotosTableViewPresenter.h"
#import "NetworkClient+Request.h"

#import "PhotoModel.h"

@interface PhotosTableViewPresenter ()

@property (nonatomic, strong) NSArray<PhotoModel *> *photos;

@end

@implementation PhotosTableViewPresenter

- (void)requestPhotosWithSuccess:(void (^)(void))success failure:(void (^)(NSError * _Nullable))failure {
    [[NetworkClient defaultClient] requestPhotosWithSuccess:^(__kindof FSTConnectTask * _Nonnull connectTask) {
        if ([connectTask.convertObject isKindOfClass:[NSArray class]]) {
            NSArray<PhotoResponse *> *responses = (NSArray<PhotoResponse *> *)connectTask.convertObject;
            NSMutableArray<PhotoModel *> *photos = [NSMutableArray array];
            for (PhotoResponse *response in responses) {
                [photos addObject:[[PhotoModel alloc] initWithPhotoResponse:response]];
            }
            self.photos = photos;
            if (success) { success(); }
        } else {
            if (failure) { failure(connectTask.error); }
        }
    } failure:^(__kindof FSTConnectTask * _Nonnull connectTask) {
        if (failure) { failure(connectTask.error); }
    }];
}

@end
