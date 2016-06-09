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
    static let loadingDelay: Double = release ? 0.8 : 0
    static let release: Bool = false
    static let logging: Bool = false
    static let deepLink: String = "eneff.organize"
    static let firebaseAppId: String = "ca-app-pub-4503899421913794~1486671265"
    static let firebaseBannerAdUnitID: String = "ca-app-pub-4503899421913794/4160936069"
    static let firebaseTestDevices = release ? [] : ["890bce2d489474fd09494eaad9f55aab", kGADSimulatorID]
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
    static let button = UIColor(hex:"#3498db")
    static let title =  UIColor(hex: "#212121")
    static let subtitle = UIColor(hex: "#757575")
    static let border = UIColor(hex: "#cdcdcd")
    static let shadow = UIColor(hex: "#f5f5f5")
    static let background = UIColor(hex: "#ffffff")
    static let backdrop = UIColor(hex: "#000000").colorWithAlphaComponent(0.4)
    static let statusBar = UIBarStyle.Default
    
    static let red = UIColor(hex:"#ed5522")
    static let green = UIColor(hex:"#67d768")
    static let yellow = UIColor(hex:"#fed23b")
    static let brown = UIColor(hex:"#d7a678")
    
//    static let button = UIColor(hex:"#CB6724")
//    static let background = UIColor(hex: "#212121")
//    static let border = UIColor(hex: "#424242")
//    static let title =  UIColor(hex: "#fafafa")
//    static let subtitle = UIColor(hex: "#757575")
//    static let statusBar = UIBarStyle.BlackTranslucent
  }
  
  struct NotificationKey {
    
  }
  
  struct AnalyticsKey {
    static let appOpen = "app open"
    static let appClose = "app close"
  }
  
  struct UserDefaultKey {
    static let askedLocalNotification = "askedLocalNotification"
  }
}