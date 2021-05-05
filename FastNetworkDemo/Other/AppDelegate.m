//
//  AppDelegate.m
//  FastNetworkDemo
//
//  Created by Leo Lee on 2021/4/27.
//

#import <FastNetwork/FastNetwork.h>

#import "AppDelegate.h"
#import "NetworkListener.h"
#import "BaseRequest.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NetworkListener sharedListener] start];
    
    [self setupNetwork];
    
    return YES;
}

- (void)setupNetwork {
    [NSString fst_registerClass:[BaseRequest class] forBaseURL:@"https://jsonplaceholder.typicode.com"];

#if DEBUG
    NSURLSession.fst_httpProxyEnabled = YES;
#else
    NSURLSession.fst_httpProxyEnabled = NO;
#endif
    
}

@end
