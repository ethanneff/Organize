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
    // load (install or updated)
    configureFirebase()
    navigateToFirstController()
    return true
  }
  func applicationWillTerminate(application: UIApplication) {
    // terminate
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // launch and foreground
    reportState(active: true)
    updateFirebase()
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // resign background terminate
    reportState(active: false)
    clearBadgeIcon()
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // background
    disconnectFCM()
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
    // Firebase database offline
    FIRDatabase.database().persistenceEnabled = true
  }
  
  private func updateFirebase() {
    listenFCM()
    Remote.Device.open()
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
      if let aps = userInfo["aps"] as? NSDictionary, let message = aps["alert"] as? String, let topController = UIApplication.topViewController() {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alert.addAction(action)
        topController.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  
  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    // if register for local, register for push as well
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
    // save token
    Remote.Device.updatePushAPN(token: tokenString)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    Report.sharedInstance.log("Failed to register notification: \(error)")
  }
  
  // MARK: - fcm notifications
  private func listenFCM() {
    if FIRInstanceID.instanceID().token() == nil {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receivedFCM(_:)), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
    }
  }
  
  private func removeFCM() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kFIRInstanceIDTokenRefreshNotification, object: nil)
  }
  
  func receivedFCM(notification: NSNotification) {
    if let token = FIRInstanceID.instanceID().token() {
      Remote.Device.updatePushFCM(token: token)
      connectFCM()
      removeFCM()
    }
  }
  
  private func connectFCM() {
    FIRMessaging.messaging().connectWithCompletion { (error) in
      if (error != nil) {
        Report.sharedInstance.log("Unable to connect with FCM. \(error)")
      }
    }
  }
  
  private func disconnectFCM() {
    FIRMessaging.messaging().disconnect()
  }
  
  // MARK: - reporting
  private func reportState(active active: Bool) {
    AppState.sharedInstance.foreground = active ? true : false
    Report.sharedInstance.track(event: active ? "app_open" : "app_close")
  }
}

