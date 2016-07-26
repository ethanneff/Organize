//
//  Local.swift
//  Organize
//
//  Created by Ethan Neff on 7/24/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class Local {
  // MARK: - singleton
  static let sharedInstance = Local()
  private init() {}
  
  // MARK: - data locations
  private static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
  
  enum Location: String {
    case Notebook
    
    var path: String {
      return DocumentsDirectory.URLByAppendingPathComponent(rawValue).path!
    }
  }
  
  // MARK: - get
  func get(location location: Location, completion: (data: AnyObject?) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      completion(data:  NSKeyedUnarchiver.unarchiveObjectWithFile(location.path))
    })
  }
  
  func set(location location: Location, data: AnyObject, completion: ((success: Bool) -> ())? = nil) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: location.path)
      if !isSuccessfulSave {
        if let completion = completion {
          completion(success: false)
        }
      } else {
        if let completion = completion {
          completion(success: true)
        }
      }
    })
  }
}