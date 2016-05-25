//
//  Analytics.swift
//  Organize
//
//  Created by Ethan Neff on 5/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation
import Firebase

class Analytics {
  static let sharedInstance = AppState()
  
  
  enum Events {
    
  }
  
  func create(name name: String) {
    Util.threadBackground {
      FIRAnalytics.logEventWithName(name, parameters: [
        kFIRParameterContentType:"cont",
        kFIRParameterItemID:"1"
        ])
    }
    
  }
}