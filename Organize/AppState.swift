//
//  AppState.swift
//  Organize
//
//  Created by Ethan Neff on 5/19/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class AppState {
  static let sharedInstance = AppState()
  
  var signedIn: Bool = false
  var foreground: Bool = false
  var displayName: String?
  var photoUrl: NSURL?
}
