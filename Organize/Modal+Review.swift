//
//  Modal+Review.swift
//  Organize
//
//  Created by Ethan Neff on 6/21/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalReview: Modal {
  // MARK: - properties
  private var header: UILabel!
  
  private let modalWidth: CGFloat = 270
  private let modalHeight: CGFloat = 100
  private let modalTitleText: String = "How would you rate " + Constant.App.name + "?"
  
  private let starNumber: Int = 5
  private var stars: [UIButton] = []
  private var starOne: UIButton!
  private var starTwo: UIButton!
  private var starThree: UIButton!
  private var starFour: UIButton!
  private var starFive: UIButton!
  private var starSize: CGFloat!
  
  enum OutputKeys: String {
    case Selection
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
    modal.addSubview(header)
    
    starSize = (modalWidth-Constant.Button.padding*2)/CGFloat(starNumber)
    for i in 0..<starNumber {
      let star = createButtonStar(tag: i)
      stars.append(star)
      modal.addSubview(star)
    }
    
  }
  
  private func createConstraints() {
    constraintHeader(header: header)
    
    for i in 0..<stars.count {
      if i == 0 {
        constraintStar(item: stars[i], top: header, leading: modal, leadingAttribute: .Leading, leadingConstant: Constant.Button.padding, trailing: stars[i+1], trailingAttribute: .Leading, trailingConstant: 0)
      } else if i == stars.count-1 {
        constraintStar(item: stars[i], top: header, leading: stars[i-1], leadingAttribute: .Trailing, leadingConstant: 0, trailing: modal, trailingAttribute: .Trailing, trailingConstant: -Constant.Button.padding)
      } else {
        constraintStar(item: stars[i], top: header, leading: stars[i-1], leadingAttribute: .Trailing, leadingConstant: 0, trailing: stars[i+1], trailingAttribute: .Leading, trailingConstant: 0)
      }
    }
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalWidth),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalHeight),
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      ])
  }
  
  private func animateButtons(last last: Int, next: Int, completion: () -> ()) {
    let button = stars[next]
    UIView.animateWithDuration(0.1, animations: {
      button.tintColor = Constant.Color.button
      }, completion: { success in
        if next < last {
          self.animateButtons(last: last, next: next+1, completion: completion)
        } else {
          Util.delay(0.2) {
            completion()
          }
        }
    })
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    animateButtons(last: button.tag, next: 0) {
      self.hide() {
        if let completion = self.completion {
          completion(output: [OutputKeys.Selection.rawValue: button.tag])
        }
      }
    }
  }
  
  // MARK: - helper
  private func createButtonStar(tag tag: Int) -> UIButton {
    let button = UIButton()
    let image = UIImage(named: "icon-star")!
    let imageView = Util.imageViewWithColor(image: image, color: Constant.Color.border)
    button.tintColor = Constant.Color.border
    button.tag = tag
    button.setImage(imageView.image, forState: .Normal)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  private func constraintStar(item item: UIView, top: UIView, leading: UIView, leadingAttribute: NSLayoutAttribute, leadingConstant: CGFloat, trailing: UIView, trailingAttribute: NSLayoutAttribute, trailingConstant: CGFloat) {
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: starSize),
      NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: starSize),
      NSLayoutConstraint(item: item, attribute: .Leading, relatedBy: .Equal, toItem: leading, attribute: leadingAttribute, multiplier: 1, constant: leadingConstant),
      NSLayoutConstraint(item: item, attribute: .Trailing, relatedBy: .Equal, toItem: trailing, attribute: trailingAttribute, multiplier: 1, constant: trailingConstant),
      NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: top, attribute: .Bottom, multiplier: 1, constant: -Constant.Button.padding),
      ])
  }
}