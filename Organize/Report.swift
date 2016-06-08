//
//  Analytics.swift
//  Organize
//
//  Created by Ethan Neff on 5/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation
import Firebase

class Report {
  static let sharedInstance = Report()
  
  // TODO: move to Remote
  func track(event event: String) {
    Util.threadBackground {
      FIRAnalytics.logEventWithName(event, parameters: nil)
    }
  }
  
  func crash(event event: String) {
    Util.threadBackground {
      FIRCrashMessage(event)
    }
  }
  
  func log(message: String?=nil, function: String = #function, file: String = #file) {
    if Constant.App.logging {
      let current = Int64(NSDate().timeIntervalSince1970*1000)
      let output = "\(current) | \(file) | \(function) | \(message ?? "")"
      print(output)
      crash(event: output)
    }
  }
}