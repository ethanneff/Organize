//
//  Modal+Error.swift
//  Organize
//
//  Created by Ethan Neff on 6/3/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalError: Modalz {
  // MARK: - properties
  var error: String? {
    didSet {
      updateLabel(text: error)
    }
  }
  
  var label: UILabel!
  var button: UIButton!
  var topSeparator: UIView!
  var modalWidthConstraint: NSLayoutConstraint!
  var modalHeightConstraint: NSLayoutConstraint!
  
  let modalMaxWidth: CGFloat = Constant.Button.height*6
  let modalMinWidth: CGFloat = Constant.Button.height*2
  let modalMinHeight: CGFloat = Constant.Button.height*2
  let modalMaxHeight: CGFloat = Constant.Button.height*12
  
  
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
    label = createTitle()
    topSeparator = createSeparator()
    button = createButton(confirm: true)
    
    modal.addSubview(label)
    modal.addSubview(topSeparator)
    modal.addSubview(button)
    
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func createConstraints() {
    modalWidthConstraint = NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*2+separatorHeight)
    modalHeightConstraint = NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalMinWidth)
    
    NSLayoutConstraint.activateConstraints([
      modalWidthConstraint,
      modalHeightConstraint,
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: button, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      
      NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
  }
  
  // MARK: - dynamic label
  private func updateLabel(text text: String?) {
    label.translatesAutoresizingMaskIntoConstraints = true
    label.text = text
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.font = .boldSystemFontOfSize(buttonFontSize)
    label.lineBreakMode = .ByClipping
    let minLabelSize = CGSizeMake(modalMinWidth, modalMinHeight/2);
    let maxLabelSize = CGSizeMake(modalMaxWidth, modalMaxHeight);
    let expectedSize = label.sizeThatFits(maxLabelSize)
    let actualSize = CGSizeMake(minLabelSize.width > expectedSize.width ?  minLabelSize.width : expectedSize.width, minLabelSize.height > expectedSize.height ?  minLabelSize.height : expectedSize.height)
    
    label.frame = CGRectMake(Constant.Button.padding, Constant.Button.padding, actualSize.width, actualSize.height)
    modalWidthConstraint?.constant = label.frame.size.height+Constant.Button.height+separatorHeight+Constant.Button.padding*2
    modalHeightConstraint?.constant = label.frame.size.width+Constant.Button.padding*2
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    Util.playSound(systemSound: .Tap)
    hide()
  }
}