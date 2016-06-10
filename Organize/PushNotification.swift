//
//  PushNotification.swift
//  Organize
//
//  Created by Ethan Neff on 6/1/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class PushNotification {
  static let sharedInstance = PushNotification()
  
  func registerPermission() {
    UIApplication.sharedApplication().registerForRemoteNotifications()
    Constant.UserDefault.set(key: Constant.UserDefault.Key.AskedPushNotification, val: true)
  }
}