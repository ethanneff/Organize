//
//  AppDelegate.swift
//  Organize
//
//  Created by Ethan Neff on 4/27/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//    print("launch")
    // Override point for customization after application launch.
    FIRApp.configure()
    navigateToFirstController()
//    assert(false)
    return true
  }
  
  func navigateToFirstController() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    if let window = window {
      window.backgroundColor = UIColor.whiteColor()
      // TODO: change back
//      window.rootViewController = IntroNavigationController()
      window.rootViewController = MenuNavigationController()
      window.makeKeyAndVisible()
    }
  }
  
  func applicationWillResignActive(application: UIApplication) {
//    print("close")
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
//    print("in background")
        AppState.sharedInstance.foreground = false
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
//    print("in foreground")
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    AppState.sharedInstance.foreground = true
//    print("active (launch and foreground)")
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
//    print("terminate")
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

