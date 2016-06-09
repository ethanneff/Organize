//
//  UIActivityViewController+Contant.swift
//  Organize
//
//  Created by Ethan Neff on 6/9/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ActivityViewController: UIActivityViewController {
  
  func _shouldExcludeActivityType(activity: UIActivity) -> Bool {
    let activityTypesToExclude = [
      "com.apple.reminders.RemindersEditorExtension",
      "com.apple.mobilenotes.SharingExtension",
//      UIActivityTypeOpenInIBooks,
      UIActivityTypePrint,
      UIActivityTypeAssignToContact,
      "com.google.Drive.ShareExtension"
    ]
    
    if let actType = activity.activityType() {
      if activityTypesToExclude.contains(actType) {
        return true
      }
      else if super.excludedActivityTypes != nil {
        return super.excludedActivityTypes!.contains(actType)
      }
    }
    return false
  }
  
}