//
//  AppDelegate.swift
//  EasyNetDemoSwift
//
//  Created by lidan on 2021/5/27.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NetworkListener.shared.start()
        setupNetwork()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let nvc = UINavigationController(rootViewController: PhotosTableViewController())
        window?.rootViewController = nvc
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupNetwork() {
        NSString.en_registerClass(BaseRequest.self, forBaseURL: "https://jsonplaceholder.typicode.com")
        #if DEBUG
        URLSession.en_httpProxyEnabled = true
        #else
        URLSession.en_httpProxyEnabled = false
        #endif
    }

}
