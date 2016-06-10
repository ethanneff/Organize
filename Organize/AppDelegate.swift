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
  
  // MARK: - app states
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // load
    configureFirebase()
    navigateToFirstController()
    registerForPushNotifications(application)
    return true
  }
  func applicationWillTerminate(application: UIApplication) {
    // terminate
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // launch and foreground
    reportState(active: true)
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // resign background terminate
    reportState(active: false)
    clearBadgeIcon()
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // background
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // foreground
  }
  
  // MARK: - navigation
  func navigateToFirstController() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    if let window = window {
      window.backgroundColor = UIColor.whiteColor()
      window.rootViewController = IntroNavigationController()
      window.makeKeyAndVisible()
    }
  }
  // MARK: - firebase
  private func configureFirebase() {
    // Firebase dynamic links
    FIROptions.defaultOptions().deepLinkURLScheme = Constant.App.deepLink
    // Firebase config
    FIRApp.configure()
  }
  
  // MARK: - deep links
  func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    return application(app, openURL: url, sourceApplication: nil, annotation: [:])
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    // app open via deep link for the first time or after an iOS update
    let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLinkFromCustomSchemeURL(url)
    if let dynamicLink = dynamicLink {
      handleDeepLink(url: dynamicLink.url, firstTime: true)
      return true
    }
    return false
  }
  
  @available(iOS 8.0, *)
  func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
    // app open via deep link
    let handled = FIRDynamicLinks.dynamicLinks()?.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
      if let dynamicLink = dynamicLink {
        self.handleDeepLink(url: dynamicLink.url, firstTime: false)
      }
    }
    return handled!
  }
  
  private func handleDeepLink(url url: NSURL?, firstTime: Bool) {
    
  }
  
  // MARK: - badges
  private func clearBadgeIcon() {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
  }
  
  // MARK: - push notifications
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    // tap on notification to open app
    if application.applicationState == UIApplicationState.Inactive || application.applicationState == UIApplicationState.Background  {
      // go to screen relevant to Notification content
    } else {
      // app in foreground (show alert view)
    }
    print("%@", userInfo)
  }
  
  func registerForPushNotifications(application: UIApplication) {
    let notificationSettings = UIUserNotificationSettings(
      forTypes: [.Badge, .Sound, .Alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""
    
    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    print("Device Token:", tokenString)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print("Failed to register:", error)
  }
  
  // MARK: - reporting
  private func reportState(active active: Bool) {
    AppState.sharedInstance.foreground = active ? true : false
    Report.sharedInstance.track(event: active ? "app_open" : "app_close")
  }
}

