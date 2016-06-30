//
//  TestNavigationController.swift
//  Organize
//
//  Created by Ethan Neff on 6/29/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TestNavigationController: UINavigationController {
  init() {
    super.init(nibName: nil, bundle: nil)
    pushViewController(TestViewController(), animated: false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
