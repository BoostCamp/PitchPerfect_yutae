//
//  AppDelegate.swift
//  PitchPerfect
//
//  Created by 최유태 on 2016. 12. 29..
//  Copyright © 2016년 YutaeChoi. All rights reserved.
//

import UIKit
import CircularSpinner
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate {

    var window: UIWindow?
    var callObserver = CXCallObserver()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Navigation Bar Color 지정
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.themeColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // Call Observer Delegate 셋팅 CallKit iOS 10 이상
        callObserver.setDelegate(self, queue: nil)
        
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
    
    // Calling Status 일 때 로딩 화면 처리로 앱 튕김 예외처리
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        
        if call.hasEnded {
            print("Call End!")
            DispatchQueue.main.async {
                CircularSpinner.hide()
            }
        } else {
            print("Calling Status!")
            // Waiting for call to end
            DispatchQueue.main.async {
                CircularSpinner.trackPgColor = UIColor.init(red: 0/255, green: 183/255, blue: 168/255, alpha: 1.0)
                CircularSpinner.show("Waiting...", animated: true, type: .indeterminate, showDismissButton: false)
            }
        }
    }
    

}

