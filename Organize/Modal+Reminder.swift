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
  func modalReminderDisplay()
  func modalReminderValue(reminderType reminderType: ReminderType)
}

class ModalReminderViewController: UIViewController {
  // MARK: properties
  weak var delegate: ModalReminderDelegate?
  var selected: ReminderType?
  
  
  // TODO: look into var? for memory leak
  // TODO: need deinit
  var modal: UIView = UIView()
  let modalTitleText: String = "Pick a reminder"
  let modalHeightPadding: CGFloat = 60
  let modalWidthPadding: CGFloat = 100

  
  let buttonHeight: CGFloat = 75
  let buttonMultiplier: CGFloat = 0.18
  let buttonRows: CGFloat = 3
  let buttonColumns: CGFloat = 3
  let buttonTitleRows: Int = 2
  let buttonTitleFontSize: CGFloat = 13
  
  // MARK: create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  func setupView() {
    Modal.createModalTemplate(background: view, modal: modal, titleText: modalTitleText)
    
    modal.widthAnchor.constraintLessThanOrEqualToAnchor(view.widthAnchor, multiplier: buttonMultiplier*buttonColumns, constant: modalWidthPadding).active = true
    modal.heightAnchor.constraintGreaterThanOrEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier*buttonRows, constant: modalHeightPadding).active = true
    
    let buttonOne = UIButton()
    let buttonTwo = UIButton()
    let buttonThree = UIButton()
    let buttonFour = UIButton()
    let buttonFive = UIButton()
    let buttonSix = UIButton()
    let buttonSeven = UIButton()
    let buttonEight = UIButton()
    let buttonNine = UIButton()
    
    modal.addSubview(buttonOne)
    modal.addSubview(buttonTwo)
    modal.addSubview(buttonThree)
    modal.addSubview(buttonFour)
    modal.addSubview(buttonFive)
    modal.addSubview(buttonSix)
    modal.addSubview(buttonSeven)
    modal.addSubview(buttonEight)
    modal.addSubview(buttonNine)
    
    configureButton(button: buttonOne, reminderType: ReminderType.Later)
    configureButton(button: buttonTwo, reminderType: ReminderType.Evening)
    configureButton(button: buttonThree, reminderType: ReminderType.Tomorrow)
    configureButton(button: buttonFour, reminderType: ReminderType.Weekend)
    configureButton(button: buttonFive, reminderType: ReminderType.Week)
    configureButton(button: buttonSix, reminderType: ReminderType.Month)
    configureButton(button: buttonSeven, reminderType: ReminderType.Someday)
    configureButton(button: buttonEight, reminderType: ReminderType.None)
    configureButton(button: buttonNine, reminderType: ReminderType.Date)
    
    let topSeparatorOne = UIView()
    let topSeparatorTwo = UIView()
    let topSeparatorThree = UIView()
    
    modal.addSubview(topSeparatorOne)
    modal.addSubview(topSeparatorTwo)
    modal.addSubview(topSeparatorThree)
    
    let midSeparatorOne = UIView()
    let midSeparatorTwo = UIView()
    
    modal.addSubview(midSeparatorOne)
    modal.addSubview(midSeparatorTwo)
    
    // TODO: need to combine into activeConstraint array
    buttonOne.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    buttonOne.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor).active = true
    
    buttonTwo.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor).active = true
    buttonTwo.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor).active = true
    buttonTwo.widthAnchor.constraintEqualToAnchor(buttonOne.widthAnchor).active = true
    
    buttonThree.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    buttonThree.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor).active = true
    buttonThree.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor).active = true
    buttonThree.widthAnchor.constraintEqualToAnchor(buttonOne.widthAnchor).active = true
    
    buttonFour.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    buttonFour.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor).active = true
    
    buttonFive.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor).active = true
    buttonFive.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor).active = true
    buttonFive.widthAnchor.constraintEqualToAnchor(buttonFour.widthAnchor).active = true
    
    buttonSix.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    buttonSix.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor).active = true
    buttonSix.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor).active = true
    buttonSix.widthAnchor.constraintEqualToAnchor(buttonFour.widthAnchor).active = true
    
    buttonSeven.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    buttonSeven.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    
    buttonEight.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor).active = true
    buttonEight.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    buttonEight.widthAnchor.constraintEqualToAnchor(buttonSeven.widthAnchor).active = true
    
    buttonNine.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    buttonNine.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor).active = true
    buttonNine.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    buttonNine.widthAnchor.constraintEqualToAnchor(buttonSeven.widthAnchor).active = true
    
    topSeparatorOne.backgroundColor = Config.colorBorder
    topSeparatorOne.translatesAutoresizingMaskIntoConstraints = false
    topSeparatorOne.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    topSeparatorOne.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    topSeparatorOne.bottomAnchor.constraintEqualToAnchor(buttonOne.topAnchor).active = true
    topSeparatorOne.heightAnchor.constraintEqualToConstant(Modal.separator).active = true
    
    topSeparatorTwo.backgroundColor = Config.colorBorder
    topSeparatorTwo.translatesAutoresizingMaskIntoConstraints = false
    topSeparatorTwo.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    topSeparatorTwo.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    topSeparatorTwo.bottomAnchor.constraintEqualToAnchor(buttonFour.topAnchor).active = true
    topSeparatorTwo.heightAnchor.constraintEqualToConstant(Modal.separator).active = true
    
    topSeparatorThree.backgroundColor = Config.colorBorder
    topSeparatorThree.translatesAutoresizingMaskIntoConstraints = false
    topSeparatorThree.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    topSeparatorThree.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    topSeparatorThree.bottomAnchor.constraintEqualToAnchor(buttonSeven.topAnchor).active = true
    topSeparatorThree.heightAnchor.constraintEqualToConstant(Modal.separator).active = true
    
    midSeparatorOne.backgroundColor = Config.colorBorder
    midSeparatorOne.translatesAutoresizingMaskIntoConstraints = false
    midSeparatorOne.leadingAnchor.constraintEqualToAnchor(buttonSeven.trailingAnchor).active = true
    midSeparatorOne.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    midSeparatorOne.topAnchor.constraintEqualToAnchor(topSeparatorOne.topAnchor).active = true
    midSeparatorOne.widthAnchor.constraintEqualToConstant(Modal.separator).active = true
    
    midSeparatorTwo.backgroundColor = Config.colorBorder
    midSeparatorTwo.translatesAutoresizingMaskIntoConstraints = false
    midSeparatorTwo.leadingAnchor.constraintEqualToAnchor(buttonEight.trailingAnchor).active = true
    midSeparatorTwo.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    midSeparatorTwo.topAnchor.constraintEqualToAnchor(topSeparatorOne.topAnchor).active = true
    midSeparatorTwo.widthAnchor.constraintEqualToConstant(Modal.separator).active = true
  }
  
  func configureButton(button button: UIButton, reminderType: ReminderType) {
    button.tag = reminderType.hashValue
    button.setTitle(reminderType.title, forState: .Normal)
    button.layer.cornerRadius = Modal.radius
    button.tintColor = Config.colorButton
    button.setImage(reminderType.imageView.image, forState: .Normal)
    button.setTitleColor(Config.colorButton, forState: .Normal)
    button.setTitleColor(Config.colorShadow, forState: .Highlighted)
    
    button.titleLabel?.font = reminderType == .None ? .boldSystemFontOfSize(buttonTitleFontSize) : .systemFontOfSize(buttonTitleFontSize)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.titleLabel?.textAlignment = .Center
    button.titleLabel?.numberOfLines = buttonTitleRows
    button.alignImageAndTitleVertically(spacing: 0)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier).active = true
  }
  
  // MARK: buttons
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    if let type = ReminderType(rawValue: button.tag) {
      close(reminderType: type)
    }
  }
  
  // MARK: open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  func close(reminderType reminderType: ReminderType) {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
      Modal.clear(background: self.view)
      self.delegate?.modalReminderValue(reminderType: reminderType)
    }
  }
}