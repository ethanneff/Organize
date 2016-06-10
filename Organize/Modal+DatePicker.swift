//
//  Modal+DatePicker.swift
//  Organize
//
//  Created by Ethan Neff on 6/7/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//


import UIKit

class ModalDatePicker: Modal {
  // MARK: - properties
  private var header: UILabel!
  private var topSeparator: UIView!
  private var midSeparator: UIView!
  private var yes: UIButton!
  private var no: UIButton!
  private var picker: UIDatePicker!
  
  private let modalWidth: CGFloat = 290
  private let modalHeight: CGFloat = 290
  private let modalTitleText: String = "Pick a date"
  private let pickerMinuteInterval: Int = 5
  
  enum OutputKeys: String {
    case Date
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
    header = createTitle(title: modalTitleText)
    topSeparator = createSeparator()
    midSeparator = createSeparator()
    yes = createButton(title: nil, confirm: true)
    no = createButton(title: nil, confirm: false)
    picker = createDatePicker(minuteInterval: pickerMinuteInterval)
    
    modal.addSubview(header)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    modal.addSubview(yes)
    modal.addSubview(no)
    modal.addSubview(picker)
    
    yes.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    no.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func createConstraints() {
    constraintHeader(header: header)
    constraintButtonDoubleBottom(topSeparator: topSeparator, midSeparator: midSeparator, left: no, right: yes)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalWidth),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalHeight),
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: picker, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: picker, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: picker, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: picker, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
      ])
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    hide() {
      if let completion = self.completion where button.tag == 1 {
        completion(output: [ModalDatePicker.OutputKeys.Date.rawValue: self.picker.date])
      }
    }
  }
}