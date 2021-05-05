//
//  PhotosTableViewDataSource.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "PhotosTableViewDataSource.h"
#import "PhotosTableViewPresenter.h"

#import "PhotosTableViewCell.h"

#import "PhotoModel.h"

@interface PhotosTableViewDataSource ()

@property (nonatomic, strong) PhotosTableViewPresenter *presenter;

@end

@implementation PhotosTableViewDataSource

- (instancetype)initWithPresenter:(PhotosTableViewPresenter *)presenter {
    if (self = [super init]) {
        _presenter = presenter;
    }
    return self;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presenter.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[PhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    PhotoModel *photoModel = self.presenter.photos[indexPath.row];
    cell.photoModel = photoModel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PhotosTableViewCellRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.presenter.view respondsToSelector:@selector(photosTableViewPresenter:didSelectUserId:)]) {
        [self.presenter.view photosTableViewPresenter:self.presenter didSelectUserId:self.presenter.photos[indexPath.row].userId];
    }
}

@end
