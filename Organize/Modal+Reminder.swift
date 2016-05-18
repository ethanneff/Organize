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
      modal.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
      modal.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
      modal.widthAnchor.constraintLessThanOrEqualToAnchor(view.widthAnchor, multiplier: buttonMultiplier*buttonColumns, constant: modalWidthPadding),
      modal.heightAnchor.constraintGreaterThanOrEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier*buttonRows, constant: modalHeightPadding),
      
      buttonOne.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      buttonOne.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor),
      buttonOne.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonTwo.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor),
      buttonTwo.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor),
      buttonTwo.widthAnchor.constraintEqualToAnchor(buttonOne.widthAnchor),
      buttonTwo.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonThree.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      buttonThree.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor),
      buttonThree.bottomAnchor.constraintEqualToAnchor(topSeparatorTwo.bottomAnchor),
      buttonThree.widthAnchor.constraintEqualToAnchor(buttonOne.widthAnchor),
      buttonThree.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonFour.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      buttonFour.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor),
      buttonFour.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonFive.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor),
      buttonFive.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor),
      buttonFive.widthAnchor.constraintEqualToAnchor(buttonFour.widthAnchor),
      buttonFive.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonSix.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      buttonSix.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor),
      buttonSix.bottomAnchor.constraintEqualToAnchor(topSeparatorThree.bottomAnchor),
      buttonSix.widthAnchor.constraintEqualToAnchor(buttonFour.widthAnchor),
      buttonSix.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonSeven.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      buttonSeven.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      buttonSeven.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonEight.leadingAnchor.constraintEqualToAnchor(midSeparatorOne.trailingAnchor),
      buttonEight.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      buttonEight.widthAnchor.constraintEqualToAnchor(buttonSeven.widthAnchor),
      buttonEight.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      buttonNine.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      buttonNine.leadingAnchor.constraintEqualToAnchor(midSeparatorTwo.trailingAnchor),
      buttonNine.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      buttonNine.widthAnchor.constraintEqualToAnchor(buttonSeven.widthAnchor),
      buttonNine.heightAnchor.constraintEqualToAnchor(view.heightAnchor, multiplier: buttonMultiplier),
      
      topSeparatorOne.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparatorOne.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparatorOne.bottomAnchor.constraintEqualToAnchor(buttonOne.topAnchor),
      topSeparatorOne.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      topSeparatorTwo.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparatorTwo.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparatorTwo.bottomAnchor.constraintEqualToAnchor(buttonFour.topAnchor),
      topSeparatorTwo.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      topSeparatorThree.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparatorThree.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparatorThree.bottomAnchor.constraintEqualToAnchor(buttonSeven.topAnchor),
      topSeparatorThree.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      midSeparatorOne.leadingAnchor.constraintEqualToAnchor(buttonSeven.trailingAnchor),
      midSeparatorOne.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      midSeparatorOne.topAnchor.constraintEqualToAnchor(topSeparatorOne.topAnchor),
      midSeparatorOne.widthAnchor.constraintEqualToConstant(Modal.separator),
      
      midSeparatorTwo.leadingAnchor.constraintEqualToAnchor(buttonEight.trailingAnchor),
      midSeparatorTwo.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      midSeparatorTwo.topAnchor.constraintEqualToAnchor(topSeparatorOne.topAnchor),
      midSeparatorTwo.widthAnchor.constraintEqualToConstant(Modal.separator),
      ])
  }
  
  private func createButton(reminderType reminderType: ReminderType) -> UIButton {
    let button = UIButton()
    
    button.tag = reminderType.hashValue
    button.setTitle(reminderType.title, forState: .Normal)
    button.tintColor = Config.colorButton
    button.setImage(reminderType.imageView(color: Config.colorButton).image, forState: .Normal)
    button.setImage(reminderType.imageView(color: Config.colorBorder).image, forState: .Highlighted)
    button.setTitleColor(Config.colorButton, forState: .Normal)
    button.setTitleColor(Config.colorBorder, forState: .Highlighted)
    
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
          button.backgroundColor = Config.colorShadow
        } else {
          button.backgroundColor = Config.colorBackground
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