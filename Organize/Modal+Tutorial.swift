//
//  Modal+Tutorial.swift
//  Organize
//
//  Created by Ethan Neff on 6/6/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalTutorial: Modalz {
  // MARK: - properties
  var indicator: UIActivityIndicatorView!
  
  var message: UILabel!
  var image: UIImageView!
  var button: UIButton!
  var progress: UIView!
  var progressWidthConstraint: NSLayoutConstraint!
  var messageSeparator: UIView!
  var topSeparator: UIView!
  
  let progressHeight: CGFloat = 3
  let progressAnimation: Double = 0.4
  
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
    //    case Undo // TODO: v2
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
      //      case .Undo: return "Shake to undo last action"
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
      //      case .Undo: return UIImage(named: "shot-undo")!
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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  // MARK: - deinit
  deinit {
    
  }
  
  // MARK: - create
  private func createViews() {
    let slide = Slide(rawValue: 0)!
    message = createTitle()
    image = UIImageView()
    progress = createProgress()
//    button = createButton(title: "Next", confirm: true)
    topSeparator = createSeparator()
    messageSeparator = createSeparator()
    
    modal.addSubview(message)
    modal.addSubview(messageSeparator)
    modal.addSubview(image)
    modal.addSubview(progress)
    modal.addSubview(topSeparator)
    modal.addSubview(button)
  }
  
  private func createConstraints() {
    progressWidthConstraint = NSLayoutConstraint(item: progress!, attribute: .Width, relatedBy: .Equal, toItem: modal, attribute: .Width, multiplier: 0, constant: 0)
//    
//    NSLayoutConstraint.activateConstraints([
//      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.7, constant: 50),
//      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.6, constant: 100),
//      
//      NSLayoutConstraint(item: message!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: message!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: message!, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
//      NSLayoutConstraint(item: message!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      
//      NSLayoutConstraint(item: messageSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: messageSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: messageSeparator, attribute: .Top, relatedBy: .Equal, toItem: message!, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding/2),
//      NSLayoutConstraint(item: messageSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      ])
//    
//    NSLayoutConstraint.activateConstraints([
//      NSLayoutConstraint(item: image!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: image!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: image!, attribute: .Top, relatedBy: .Equal, toItem: messageSeparator, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding),
//      NSLayoutConstraint(item: image!, attribute: .Bottom, relatedBy: .Equal, toItem: progress!, attribute: .Top, multiplier: 1, constant: -Constant.Button.padding),
//      
//      progressWidthConstraint!,
//      NSLayoutConstraint(item: progress!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: progress!, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: progress!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: progressHeight),
//      
//      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: button!, attribute: .Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      
//      NSLayoutConstraint(item: button!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: button!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: button!, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: button!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      ])
  }
  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
    
    if button.tag >= Slide.count-1 {
      hide()
      return
    }
    if button.tag == Slide.count-2 {
      button.setTitle("Done", forState: .Normal)
      button.titleLabel?.font = .boldSystemFontOfSize(Modal.textSize)
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






import UIKit

class ModalTutorialViewController: UIViewController {
  // MARK: - properties
  let modal: UIView = UIView()
  
  var message: UILabel?
  var image: UIImageView?
  var button: UIButton?
  var progress: UIView?
  var progressWidthConstraint: NSLayoutConstraint?
  
  let progressHeight: CGFloat = 3
  let progressAnimation: Double = 0.4
  
  // MARK: - data
  enum Slide: Int {
    case Complete
    case Uncomplete
    case Indent
    case Reminder
    case Delete
    //    case Undo // TODO: v2
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
      //      case .Undo: return "Shake to undo last action"
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
      //      case .Undo: return UIImage(named: "shot-undo")!
      case .Collapse: return UIImage(named: "shot-collapse")!
      case .Reorder: return UIImage(named: "shot-reorder")!
      case .Edit: return UIImage(named: "shot-edit")!
      }
    }
  }
  
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    message = nil
    image = nil
    progress = nil
    progressWidthConstraint = nil
    Modal.clear(background: view)
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    let slide = Slide(rawValue: 0)!
    message = createTitle(title: slide.title)
    image = createImageView(image: slide.image)
    progress = createProgress()
    button = createButton(title: "Next", confirm: true)
    let topSeparator = Modal.createSeparator()
    let messageSeparator = Modal.createSeparator()
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
    modal.addSubview(message!)
    modal.addSubview(messageSeparator)
    modal.addSubview(image!)
    modal.addSubview(progress!)
    modal.addSubview(topSeparator)
    modal.addSubview(button!)
    
    progressWidthConstraint = NSLayoutConstraint(item: progress!, attribute: .Width, relatedBy: .Equal, toItem: modal, attribute: .Width, multiplier: 0, constant: 0)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.7, constant: 50),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.6, constant: 100),
      
      NSLayoutConstraint(item: message!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: message!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: message!, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: message!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      
      NSLayoutConstraint(item: messageSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: messageSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: messageSeparator, attribute: .Top, relatedBy: .Equal, toItem: message!, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding/2),
      NSLayoutConstraint(item: messageSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: image!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image!, attribute: .Top, relatedBy: .Equal, toItem: messageSeparator, attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: image!, attribute: .Bottom, relatedBy: .Equal, toItem: progress!, attribute: .Top, multiplier: 1, constant: -Constant.Button.padding),
      
      progressWidthConstraint!,
      NSLayoutConstraint(item: progress!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: progress!, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: progress!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: progressHeight),
      
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: button!, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      
      NSLayoutConstraint(item: button!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button!, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
  }
  
  private func createProgress() -> UIView {
    let view = UIView()
    view.backgroundColor = Constant.Color.button
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  private func createTitle(title title: String) -> UILabel {
    let label = UILabel()
    label.textAlignment = .Center
    label.font = .boldSystemFontOfSize(Modal.textSize)
    label.text = title
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }
  
  private func createImageView(image image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.image = image
    imageView.contentMode = .ScaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
  }
  
  private func createButton(title title: String, confirm: Bool) -> UIButton {
    let button = UIButton()
    button.layer.cornerRadius = Modal.radius
    button.setTitle(title, forState: .Normal)
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
    button.titleLabel?.font = confirm ? .systemFontOfSize(Modal.textSize) : .boldSystemFontOfSize(Modal.textSize)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
    
    if button.tag >= Slide.count-1 {
      close()
      return
    }
    if button.tag == Slide.count-2 {
      button.setTitle("Done", forState: .Normal)
      button.titleLabel?.font = .boldSystemFontOfSize(Modal.textSize)
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
  
  // MARK: - open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  private func close() {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
    }
  }
}