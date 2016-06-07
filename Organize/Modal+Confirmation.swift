//
//  Modal+Confirmation.swift
//  Organize
//
//  Created by Ethan Neff on 6/3/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalConfirmation: Modal {
  // MARK: - properties
  var message: String? {
    didSet {
      updateLabel(text: message, label: label, modalMinWidth: modalMinWidth, modalMaxWidth: modalMaxWidth, modalMinHeight: modalMinHeight, modalMaxHeight: modalMaxHeight, modalWidthConstraint: modalWidthConstraint, modalHeightConstraint: modalHeightConstraint)
    }
  }
  
  var label: UILabel!
  var yes: UIButton!
  var no: UIButton!
  var topSeparator: UIView!
  var midSeparator: UIView!
  
  var modalWidthConstraint: NSLayoutConstraint!
  var modalHeightConstraint: NSLayoutConstraint!
  
  let modalMinWidth: CGFloat = Constant.Button.height*5
  let modalMaxWidth: CGFloat = Constant.Button.height*7
  let modalMinHeight: CGFloat = Constant.Button.height*2
  let modalMaxHeight: CGFloat = Constant.Button.height*7
  
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
    print("confirmation deinit")
  }
  
  // MARK: - create
  private func createViews() {
    label = createTitle(title: nil)
    topSeparator = createSeparator()
    midSeparator = createSeparator()
    yes = createButton(title: nil, confirm: true)
    no = createButton(title: nil, confirm: false)
    
    modal.addSubview(label)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    modal.addSubview(yes)
    modal.addSubview(no)
    
    yes.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    no.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  
  private func createConstraints() {
    modalWidthConstraint = NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalMinWidth)
    modalHeightConstraint = NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalMinHeight)
    
    NSLayoutConstraint.activateConstraints([
      modalWidthConstraint,
      modalHeightConstraint,
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: yes, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: midSeparator, attribute: .Leading, relatedBy: .Equal, toItem: no, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: yes, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: midSeparator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: no, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: no, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: no, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: yes, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: yes, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: yes, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: yes, attribute: .Width, relatedBy: .Equal, toItem: no, attribute: .Width, multiplier: 1, constant: 0),
      ])
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    if button.tag == 1 {
      if let completion = completion {
        completion(output: [:])
      }
    }
    Util.animateButtonPress(button: button)
    hide()
  }
}