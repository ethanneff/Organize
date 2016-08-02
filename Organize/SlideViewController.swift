//
//  SlideViewController.swift
//  Organize
//
//  Created by Ethan Neff on 7/12/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController {
  
  // MARK: - init
  init(color: UIColor) {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = color
    initialization()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initialization() {
    setupView()
  }
  
  // MARK: - deinit
  deinit {
    print("slide deinit")
  }
  
  // MARK: - load
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - view
  private func setupView() {

  }
}
