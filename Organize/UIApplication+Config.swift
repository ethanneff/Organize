//
//  UIApplication+Config.swift
//  Organize
//
//  Created by Ethan Neff on 6/13/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

extension UIApplication {
  class func topViewController(base base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}