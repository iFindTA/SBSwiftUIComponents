//
//  AppDelegate.swift
//  SBSwiftUICoponents
//
//  Created by nanhu on 12/4/18.
//  Copyright © 2018 nanhu. All rights reserved.
//

import UIKit
import SBComponents
import IQKeyboardManagerSwift
import GDPerformanceView_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //SJNavigationPopGesture.install()
        IQKeyboardManager.shared.enable = true
        debugPrint(NSHomeDirectory())
        
        let bounds = UIScreen.main.bounds
        window = UIWindow(frame: bounds)
        window?.backgroundColor = UIColor.white
        let rooter = ViewController(nibName: nil, bundle: nil)
        let navigator = UINavigationController(navigationBarClass: BaseNavigationBar.self, toolbarClass: nil)
        navigator.viewControllers = [rooter]
        //let navigator = BaseNavigationProfile(rootViewController: rooter)
        navigator.setNavigationBarHidden(true, animated: true)
        window?.rootViewController = navigator
        window?.makeKeyAndVisible()
        
        #if DEBUG
        PerformanceMonitor.shared().start()
        #endif
        startServices()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /// start services
    private func startServices() {
        _ = SBHTTPState.shared.isReachable()
        SBHTTPRouter.shared.challengeNetworkPermission()
        
    }
}

