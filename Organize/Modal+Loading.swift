//
//  Modal+Loading.swift
//  Organize
//
//  Created by Ethan Neff on 6/6/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalLoading: Modal {
  // MARK: - properties
  var indicator: UIActivityIndicatorView!
  let modalWidth: CGFloat = Constant.Button.height*2
  let modalHeight: CGFloat = Constant.Button.height*2
  
  enum OutputKeys: String {
    case None
  }
  
  // MARK: - init
  override init() {
    super.init()
    createViews()
    createConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  // MARK: - deinit
  deinit {
    
  }
  
  // MARK: - create
  private func createViews() {
    indicator = createIndicator()
    modal.addSubview(indicator)
  }
  
  private func createConstraints() {
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalHeight),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalWidth),
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      
      NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: modal, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: modal, attribute: .CenterY, multiplier: 1, constant: 0),
      ])
  }
}

