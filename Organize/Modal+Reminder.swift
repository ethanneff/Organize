/*
 
 // add delegate
 class ViewController: UIViewController, ModalReminderProtocol {}
 
 // call modal controller
 func modalReminderDisplay() {
 let controller = ModalReminderController()
 controller.delegate = self
 controller.modalPresentationStyle = .OverCurrentContext
 presentViewController(controller, animated: false, completion: nil)
 }
 
 // get date back from modal controller
 func modalReminderValue(reminderType reminderType: ReminderType) {
 
 }
 
 */

import UIKit

protocol ModalReminderDelegate: class {
  func modalReminderDisplay(indexPath indexPath: NSIndexPath)
  func modalReminderValue(indexPath indexPath: NSIndexPath, reminderType: ReminderType)
}


class ModalReminderViewController: UIViewController {
  // MARK: - properties
  weak var delegate: ModalReminderDelegate?
  weak var data: Reminder?
  var indexPath: NSIndexPath?
  
  let modal: UIView = UIView()
  
  let modalTitleText: String = "Pick a reminder"
  let modalHeightPadding: CGFloat = 60
  let modalWidthPadding: CGFloat = 100
  
  let buttonHeight: CGFloat = 75
  let buttonMultiplier: CGFloat = 0.18
  let buttonRows: CGFloat = 3
  let buttonColumns: CGFloat = 3
  let buttonTitleRows: Int = 2
  let buttonTitleFontSize: CGFloat = 13
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    delegate = nil
    data = nil
    Modal.clear(background: view)
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  // MARK: - open
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
    updateSelected()
  }
  
  // MARK: - close
  private func close(reminderType reminderType: ReminderType) {
    Modal.animateOut(modal: modal, background: view) {
      // calls deinit
      self.dismissViewControllerAnimated(false, completion: nil)
      if let indexPath = self.indexPath where reminderType != .None {
        self.delegate?.modalReminderValue(indexPath: indexPath, reminderType: reminderType)
      }
    }
  }
  
  private func setupView() {
    let buttonOne = createButton(reminderType: ReminderType.Later)
    let buttonTwo = createButton(reminderType: ReminderType.Evening)
    let buttonThree = createButton(reminderType: ReminderType.Tomorrow)
    let buttonFour = createButton(reminderType: ReminderType.Weekend)
    let buttonFive = createButton(reminderType: ReminderType.Week)
    let buttonSix = createButton(reminderType: ReminderType.Month)
    let buttonSeven = createButton(reminderType: ReminderType.Someday)
    let buttonEight = createButton(reminderType: ReminderType.None)
    let buttonNine = createButton(reminderType: ReminderType.Date)
    
    let topSeparatorOne = Modal.createSeparator()
    let topSeparatorTwo = Modal.createSeparator()
    let topSeparatorThree = Modal.createSeparator()
    
    let midSeparatorOne = Modal.createSeparator()
    let midSeparatorTwo = Modal.createSeparator()
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: modalTitleText)
    
    modal.addSubview(buttonOne)
    modal.addSubview(buttonTwo)
    modal.addSubview(buttonThree)
    modal.addSubview(buttonFour)
    modal.addSubview(buttonFive)
    modal.addSubview(buttonSix)
    modal.addSubview(buttonSeven)
    modal.addSubview(buttonEight)
    modal.addSubview(buttonNine)
    
    modal.addSubview(topSeparatorOne)
    modal.addSubview(topSeparatorTwo)
    modal.addSubview(topSeparatorThree)
    
    modal.addSubview(midSeparatorOne)
    modal.addSubview(midSeparatorTwo)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: buttonMultiplier*buttonColumns, constant: modalWidthPadding),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier*buttonRows, constant: modalHeightPadding),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: buttonOne, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonOne, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorTwo, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonOne, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonTwo, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorOne, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonTwo, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorTwo, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonTwo, attribute: .Width, relatedBy: .Equal, toItem: buttonOne, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonTwo, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonThree, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonThree, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorTwo, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonThree, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorTwo, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonThree, attribute: .Width, relatedBy: .Equal, toItem: buttonOne, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonThree, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: buttonFour, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonFour, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorThree, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonFour, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonFive, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorOne, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonFive, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorThree, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonFive, attribute: .Width, relatedBy: .Equal, toItem: buttonFour, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonFive, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonSix, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSix, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorTwo, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSix, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparatorThree, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSix, attribute: .Width, relatedBy: .Equal, toItem: buttonFour, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSix, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: buttonSeven, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSeven, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonSeven, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonEight, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorOne, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonEight, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonEight, attribute: .Width, relatedBy: .Equal, toItem: buttonSeven, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonEight, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      
      NSLayoutConstraint(item: buttonNine, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonNine, attribute: .Leading, relatedBy: .Equal, toItem: midSeparatorTwo, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonNine, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonNine, attribute: .Width, relatedBy: .Equal, toItem: buttonSeven, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: buttonNine, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: buttonMultiplier, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparatorOne, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorOne, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorOne, attribute: .Bottom, relatedBy: .Equal, toItem: buttonOne, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorOne, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      
      NSLayoutConstraint(item: topSeparatorTwo, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorTwo, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorTwo, attribute: .Bottom, relatedBy: .Equal, toItem: buttonFour, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorTwo, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      
      NSLayoutConstraint(item: topSeparatorThree, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorThree, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorThree, attribute: .Bottom, relatedBy: .Equal, toItem: buttonSeven, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparatorThree, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      
      NSLayoutConstraint(item: midSeparatorOne, attribute: .Leading, relatedBy: .Equal, toItem: buttonSeven, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorOne, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorOne, attribute: .Top, relatedBy: .Equal, toItem: topSeparatorOne, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorOne, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      
      NSLayoutConstraint(item: midSeparatorTwo, attribute: .Leading, relatedBy: .Equal, toItem: buttonEight, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorTwo, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorTwo, attribute: .Top, relatedBy: .Equal, toItem: topSeparatorOne, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparatorTwo, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
      ])
  }
  
  private func createButton(reminderType reminderType: ReminderType) -> UIButton {
    let button = UIButton()
    
    button.tag = reminderType.hashValue
    button.setTitle(reminderType.title, forState: .Normal)
    button.tintColor = Constant.Color.button
    button.setImage(reminderType.imageView(color: Constant.Color.button).image, forState: .Normal)
    button.setImage(reminderType.imageView(color: Constant.Color.border).image, forState: .Highlighted)
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
    
    button.titleLabel?.font = reminderType == .None ? .boldSystemFontOfSize(buttonTitleFontSize) : .systemFontOfSize(buttonTitleFontSize)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.titleLabel?.textAlignment = .Center
    button.titleLabel?.numberOfLines = buttonTitleRows
    button.alignImageAndTitleVertically(spacing: 0)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  private func updateSelected() {
    for view in modal.subviews {
      if let button = view as? UIButton, reminder = ReminderType(rawValue: button.tag) {
        if data?.type == reminder && data?.date.timeIntervalSinceNow > 0  {
          button.backgroundColor = Constant.Color.shadow
        } else {
          button.backgroundColor = Constant.Color.background
        }
      }
    }
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
    if let type = ReminderType(rawValue: button.tag) {
      close(reminderType: type)
    }
  }
}