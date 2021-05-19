//
//  PhotosTableViewController.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/4/27.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "PhotosTableViewController.h"
#import "ProfileTableViewController.h"

#import "PhotosTableViewPresenter.h"
#import "PhotosTableViewDataSource.h"

#import "PhotosTableViewCell.h"

#import "NetworkListener.h"

@interface PhotosTableViewController () <PhotosTableView>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PhotosTableViewPresenter *presenter;
@property (nonatomic, strong) PhotosTableViewDataSource *dataSource;

@end

@implementation PhotosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Photos";
    
    [[NetworkListener sharedListener] networkListenerChangeStatusUsingBlock:^(NetworkListenerStatus status) {
        [self sendRequest];
    }];
    [self setupTableView];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if (@available(iOS 12.0, *)) {
        if (previousTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        } else {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
        }
    } else {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    }
}

#pragma mark - Private

- (void)sendRequest {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:nil];
    [self.presenter requestPhotosWithSuccess:^{
        [weakSelf.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:nil];
        [SVProgressHUD dismissWithDelay:0.2];
    } failure:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:nil];
        [SVProgressHUD dismissWithDelay:0.2];
    }];
}

- (void)setupTableView {
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[PhotosTableViewCell class] forCellReuseIdentifier:NSStringFromClass([PhotosTableViewCell class])];
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
}

#pragma mark - PhotosTableView

- (void)photosTableViewPresenter:(PhotosTableViewPresenter *)presenter didSelectUserId:(NSNumber *)userId {
    ProfileTableViewController *viewController = [[ProfileTableViewController alloc] init];
    viewController.userId = userId;
    [self.navigationController pushViewController:viewController animated:YES];
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

- (PhotosTableViewPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[PhotosTableViewPresenter alloc] init];
        _presenter.view = self;
    }
    return _presenter;
}

- (PhotosTableViewDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[PhotosTableViewDataSource alloc] initWithPresenter:self.presenter];
    }
    return _dataSource;
}

@end
