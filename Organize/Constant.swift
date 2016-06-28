//
//  Constants.swift
//  Organize
//
//  Created by Ethan Neff on 5/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit
import GoogleMobileAds

struct Constant {
  
  struct App {
    static let name: String = "Organize"
    static let id: String = "1116178818"
    static let loadingDelay: Double = release ? 0.2 : 0
    static let release: Bool = false
    static let logging: Bool = true
    static let deepLink: String = "eneff.organize"
    static let deepLinkUrl: String = "https://yp4ut.app.goo.gl/4D6z"
    static let firebaseAppId: String = "ca-app-pub-4503899421913794~1486671265"
    static let firebaseBannerAdUnitID: String = "ca-app-pub-4503899421913794/4160936069"
    static let firebaseTestDevices = release ? [] : ["890bce2d489474fd09494eaad9f55aab", kGADSimulatorID]
    static let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.DarkMode) as? Bool ?? false
  }
  
  struct Button {
    static let height: CGFloat = 40
    static let padding: CGFloat = 10
    static let widthMultiplier: CGFloat = 0.4
    static let fontSize: CGFloat = 17
    static func widthConstant(padding padding: CGFloat) -> CGFloat {
      return padding * -1.8 + 185
    }
  }
  
  struct Color {
    // FIXME: this should be a class.sharedInstance
    // toggle should change properties, then save
    // get at beginning
    // no enum because need .color at end
    private enum Item {
      case Button
      case Title
      case Border
      case Background
    }
    
    static var button = Constant.Color.getColor(.Button)
    static var title = Constant.Color.getColor(.Title)
    static var border = Constant.Color.getColor(.Border)
    static var background = Constant.Color.getColor(.Background)
    static var statusBar = Constant.Color.getStatusBar()
    static var statusBarStyle = Constant.Color.getStatusBarStyle()
    
    static let selected = UIColor(hex: "#f5f5f5")
    static let backdrop = UIColor(hex: "#000000").colorWithAlphaComponent(0.4)
    
    static let red = UIColor(hex:"#ed5522")
    static let green = UIColor(hex:"#67d768")
    static let yellow = UIColor(hex:"#fed23b")
    static let brown = UIColor(hex:"#d7a678")
    static let blue = UIColor(hex:"#3498db")
    static let gray = UIColor(hex: "#757575")
    
    static func toggleColor() {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.DarkMode) as? Bool ?? false
      Constant.UserDefault.set(key: Constant.UserDefault.Key.DarkMode, val: !darkMode)
      
      button = Constant.Color.getColor(.Button)
      title = Constant.Color.getColor(.Title)
      border = Constant.Color.getColor(.Border)
      background = Constant.Color.getColor(.Background)
      statusBar = Constant.Color.getStatusBar()
      statusBarStyle = Constant.Color.getStatusBarStyle()
    }
    
    private static func getColor(item: Item) -> UIColor {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.DarkMode) as? Bool ?? false
      switch item {
      case .Button: return darkMode ? UIColor(hex:"#CB6724") : UIColor(hex:"#3498db")
      case .Title: return darkMode ? UIColor(hex: "#ffffff").colorWithAlphaComponent(1.0) : UIColor(hex: "#212121")
      case .Border: return darkMode ? UIColor(hex: "#787878").colorWithAlphaComponent(0.7) : UIColor(hex: "#cdcdcd")
      case .Background: return darkMode ? UIColor(hex: "#212121") : UIColor(hex: "#ffffff")
      }
    }
    
    private static func getStatusBar() -> UIBarStyle {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.DarkMode) as? Bool ?? false
      let barStyle: UIBarStyle = darkMode ? .BlackTranslucent : .Default
      
      return barStyle
    }
    
    private static func getStatusBarStyle() -> UIStatusBarStyle {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.DarkMode) as? Bool ?? false
      let statusBarStyle: UIStatusBarStyle = darkMode ? .LightContent : .Default
      return statusBarStyle
    }
  }
  
  struct NotificationKey {
    
  }
  
  struct AnalyticsKey {
    static let appOpen = "app open"
    static let appClose = "app close"
  }
  
  struct UserDefault {
    enum Key: String {
      case AskedLocalNotification
      case DarkMode
      case FeedbackApp
      case ReviewApp
      case ReviewCount
    }
    
    static func get(key key: UserDefault.Key) -> AnyObject? {
      return NSUserDefaults.standardUserDefaults().valueForKey(key.rawValue)
    }
    
    static func set(key key: UserDefault.Key, val: AnyObject) {
      NSUserDefaults.standardUserDefaults().setValue(val, forKey: key.rawValue)
    }
  }
}