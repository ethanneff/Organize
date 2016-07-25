//
//  Modal+Tutorial.swift
//  Organize
//
//  Created by Ethan Neff on 6/6/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalTutorial: Modal {
  // MARK: - properties
  private var message: UILabel!
  private var image: UIImageView!
  private var button: UIButton!
  private var progress: UIView!
  private var progressWidthConstraint: NSLayoutConstraint!
  private var messageSeparator: UIView!
  private var topSeparator: UIView!
  
  private let progressHeight: CGFloat = 3
  private let progressAnimation: Double = 0.4
  private let modalWidthConstant: CGFloat = 180
  private let modalHeightConstant: CGFloat = 140
  
  enum OutputKeys: String {
    case None
  }
  
  // MARK: - data
  enum Slide: Int {
    case Complete
    case Uncomplete
    case Indent
    case Reminder
    case Delete
    case Collapse
    case Reorder
    case Edit
    
    static var count: Int {
      return Slide.Edit.hashValue + 1
    }
    
    var title: String {
      switch self {
      case .Complete: return "Swipe right to complete"
      case .Uncomplete: return "Swipe left to uncomplete"
      case .Indent: return "Swipe right or left to indent"
      case .Reminder: return "Swipe right to set a reminder"
      case .Delete: return "Swipe right to delete"
      case .Collapse: return "Double tap to collapse"
      case .Reorder: return "Hold to reorder"
      case .Edit: return "Tap to edit or create"
      }
    }
    
    var image: UIImage {
      switch self {
      case .Complete: return UIImage(named: "shot-complete")!
      case .Uncomplete: return UIImage(named: "shot-uncomplete")!
      case .Indent: return UIImage(named: "shot-indent")!
      case .Reminder: return UIImage(named: "shot-reminder")!
      case .Delete: return UIImage(named: "shot-delete")!
      case .Collapse: return UIImage(named: "shot-collapse")!
      case .Reorder: return UIImage(named: "shot-reorder")!
      case .Edit: return UIImage(named: "shot-edit")!
      }
    }
  }
  
  // MARK: - init
  override init() {
    super.init()
    createViews()
    createConstraints()
    createListener()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  deinit {

  }
}

// MARK: - create
extension ModalTutorial {
  private func createViews() {
    let slide = Slide(rawValue: 0)!
    message = createTitle(title: slide.title)
    image = createImageView(image: slide.image)
    progress = createProgress()
    button = createButton(title: "Next", confirm: true)
    topSeparator = createSeparator()
    messageSeparator = createSeparator()
    
    modal.addSubview(message)
    modal.addSubview(messageSeparator)
    modal.addSubview(image)
    modal.addSubview(progress)
    modal.addSubview(topSeparator)
    modal.addSubview(button)
    
    button.tag = 0
    button.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
  }
  
  private func createConstraints() {
    progressWidthConstraint = NSLayoutConstraint(item: progress!, attribute: .Width, relatedBy: .Equal, toItem: modal, attribute: .Width, multiplier: 0, constant: 0)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.3, constant: modalWidthConstant),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.4, constant: modalHeightConstant),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: message, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: message, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: message, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: message, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: messageSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: messageSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: messageSeparator, attribute: .Top, relatedBy: .Equal, toItem: message!, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding/2),
      NSLayoutConstraint(item: messageSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: image, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image, attribute: .Top, relatedBy: .Equal, toItem: messageSeparator, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: image, attribute: .Bottom, relatedBy: .Equal, toItem: progress!, attribute: .Top, multiplier: 1, constant: -Constant.Button.padding),
      ])
    
    NSLayoutConstraint.activateConstraints([
      progressWidthConstraint!,
      NSLayoutConstraint(item: progress, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: progress, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: progress, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: progressHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: button!, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
  }
  
  private func createListener() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
    modal.addGestureRecognizer(tap)
  }
}


// MARK: - buttons
extension ModalTutorial {
  internal func buttonPressed() {
    Util.animateButtonPress(button: button)
    
    if button.tag >= Slide.count-1 {
      hide() {
        if let completion = self.completion {
           completion(output: [:])
        }
      }
      return
    }
    if button.tag == Slide.count-2 {
      button.setTitle(buttonConfirmTitle, forState: .Normal)
      button.titleLabel?.font = .boldSystemFontOfSize(Constant.Font.button)
    }
    
    changeSlide(button: button)
  }
  
  private func changeSlide(button button: UIButton) {
    button.tag += 1
    if let slide = Slide(rawValue: button.tag) {
      UIView.animateWithDuration(progressAnimation/2, delay: 0.0, options: [.CurveEaseOut], animations: {
        self.message?.alpha = 0.4
        self.image?.alpha = 0.4
        }, completion: { success in
          self.message?.text = slide.title
          self.image?.image = slide.image
          UIView.animateWithDuration(self.progressAnimation/2, delay: 0.0, options: [.CurveEaseOut], animations: {
            self.message?.alpha = 1
            self.image?.alpha = 1
            }, completion: nil)
      })
      self.progressWidthConstraint?.constant = CGFloat(button.tag)/CGFloat(Slide.count-1)*self.modal.frame.width
      UIView.animateWithDuration(progressAnimation, delay: 0, options: [.CurveEaseOut], animations: {
        self.view.layoutIfNeeded()
        }, completion: nil)
    }
  }
}