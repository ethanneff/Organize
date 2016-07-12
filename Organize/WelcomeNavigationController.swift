//
//  WelcomeNavigationViewController.swift
//  Organize
//
//  Created by Ethan Neff on 7/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class WelcomeNavigationController: UINavigationController {
  
  override func loadView() {
    super.loadView()
    pushViewController(WelcomePageViewController(), animated: false)
    navigationBar.hidden = true
  }
  
  deinit {
    print("welcome nav deinit")
  }
}
