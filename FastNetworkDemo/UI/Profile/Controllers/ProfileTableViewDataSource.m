//
//  ProfileTableViewDataSource.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import "ProfileTableViewDataSource.h"
#import "ProfileTableViewPresenter.h"
#import "ProfileTableViewCell.h"

#import "UserModel.h"

@interface ProfileTableViewDataSource ()

@property (nonatomic, strong) ProfileTableViewPresenter *presenter;

@end

@implementation ProfileTableViewDataSource

- (instancetype)initWithPresenter:(ProfileTableViewPresenter *)presenter {
    if (self = [super init]) {
        _presenter = presenter;
    }
    return self;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presenter.profiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    cell.textLabel.text = self.presenter.profiles[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ProfileTableViewCellRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
