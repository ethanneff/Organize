//
//  NSDate.swift
//  Organize
//
//  Created by Ethan Neff on 7/24/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

extension NSDate {
  // MARK: - date 
  // NSDATE().dateStringWithFormat("yyyy-MMM-dd HH:mm:ss")
  func dateStringWithFormat(format: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.stringFromDate(self)
  }
}