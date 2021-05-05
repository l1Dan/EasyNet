//
//  ProfileTableViewController.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/5/5.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "ProfileTableViewController.h"
#import "ProfileTableViewPresenter.h"
#import "ProfileTableViewDataSource.h"

#import "ProfileTableViewCell.h"

@interface ProfileTableViewController () <ProfileTableView>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) ProfileTableViewPresenter *presenter;
@property (nonatomic, strong) ProfileTableViewDataSource *dataSource;

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.userId stringValue];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self sendUserProfileRequest];
    [self setupTableView];
}

#pragma mark - Private

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[ProfileTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ProfileTableViewCell class])];
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

- (void)sendUserProfileRequest {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:nil];
    [self.presenter requestUserProfileWithUserId:self.userId success:^{
        [weakSelf.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:nil];
        [SVProgressHUD dismissWithDelay:0.2];
    } failure:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:nil];
        [SVProgressHUD dismissWithDelay:0.2];
    }];
}

#pragma mark - ProfileTableView

- (void)profileTableViewPresenter:(ProfileTableViewPresenter *)present updateTitleText:(NSString *)titleText {
    self.navigationItem.title = titleText;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.tableHeaderView = [UIView new];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self.dataSource;
        _tableView.dataSource = self.dataSource;
    }
    return _tableView;
}

- (ProfileTableViewPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[ProfileTableViewPresenter alloc] init];
        _presenter.view = self;
    }
    return _presenter;
}

- (ProfileTableViewDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[ProfileTableViewDataSource alloc] initWithPresenter:self.presenter];
    }
    return _dataSource;
}

@end
