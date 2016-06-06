//
//  Modal+TextField.swift
//  Organize
//
//  Created by Ethan Neff on 6/3/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalTextField: Modalz, UITextFieldDelegate {
  // MARK: - properties
  var text: String? {
    didSet {
      textField.text = text
    }
  }
  var placeholder: String? {
    didSet {
      textField.placeholder = placeholder
    }
  }
  var textField: UITextField!
  var yes: UIButton!
  var no: UIButton!
  var topSeparator: UIView!
  var midSeparator: UIView!
  var modalCenterYConstraint: NSLayoutConstraint!
  enum OutputKeys: String {
    case Text
  }
  
  // MARK: - init
  override init() {
    super.init()
    createViews()
    createConstraints()
    createKeyboard()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  // MARK: - deinit
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  // MARK: - load
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    textField.becomeFirstResponder()
  }
  
  // MARK: - create
  private func createViews() {
    textField = createTextField()
    topSeparator = createSeparator()
    midSeparator = createSeparator()
    yes = createButton(confirm: true)
    no = createButton(confirm: false)
    
    modal.addSubview(textField)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    modal.addSubview(yes)
    modal.addSubview(no)
    
    yes.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    no.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func createKeyboard() {
    // return
    textField.delegate = self
    // scroll
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    // dismiss
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  private func createConstraints() {
    modalCenterYConstraint = NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*2+separatorHeight+Constant.Button.padding*3/2),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*6),
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      modalCenterYConstraint,
      
      NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: textField, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: textField, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: textField, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: yes, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      
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
      
      NSLayoutConstraint(item: yes, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: yes, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: yes, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: yes, attribute: .Width, relatedBy: .Equal, toItem: no, attribute: .Width, multiplier: 1, constant: 0),
      ])
  }
  
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    if button.tag == 1 {
      if let completion = completion, let text = textField?.text where text.length > 0 {
        completion(output: [OutputKeys.Text.rawValue: text])
      }
    }
    Util.animateButtonPress(button: button)
    hide()
  }
  
  // MARK: - keyboard
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    buttonPressed(yes)
    return true
  }
  
  internal func keyboardNotification(notification: NSNotification) {
    Util.handleKeyboardScrollView(keyboardNotification: notification, scrollViewBottomConstraint: modalCenterYConstraint, view: view, constant: view.center.y/2)
  }
  
  internal func dismissKeyboard() {
    view.endEditing(true)
  }
}