//
//  AppDelegate.m
//  EasyNetDemo
//
//  Created by Leo Lee on 2021/4/27.
//

#import <EasyNet/EasyNet.h>

#import "AppDelegate.h"
#import "NetworkListener.h"
#import "BaseRequest.h"
#import "PhotosTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NetworkListener sharedListener] start];
    
    [self setupNetwork];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:[[PhotosTableViewController alloc] init]];
    self.window.rootViewController = nvc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setupNetwork {
    [NSString en_registerClass:[BaseRequest class] forBaseURL:@"https://jsonplaceholder.typicode.com"];

#if DEBUG
    NSURLSession.en_httpProxyEnabled = YES;
#else
    NSURLSession.en_httpProxyEnabled = NO;
#endif
    
}

@end
