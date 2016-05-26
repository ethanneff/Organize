/*
 
 // add delegate
 class ViewController: UIViewController, ModalDatePickerDelegate {}
 
 // call modal controller
 func modalDatePickerDisplay() {
 let controller = ModalDatePickerViewController()
 controller.delegate = self
 controller.modalPresentationStyle = .OverCurrentContext
 presentViewController(controller, animated: false, completion: nil)
 }
 
 // get date back from modal controller
 func modalDatePickerValue(date date: NSDate) {
 
 }
 
 */

import UIKit

protocol ModalDatePickerDelegate: class {
  func modalDatePickerDisplay(indexPath indexPath: NSIndexPath)
  func modalDatePickerValue(indexPath indexPath: NSIndexPath, date: NSDate)
}

class ModalDatePickerViewController: UIViewController {
  // MARK: - properties
  weak var delegate: ModalDatePickerDelegate?
  weak var data: Reminder?
  var indexPath: NSIndexPath?
  
  let modal: UIView = UIView()
  let picker: UIDatePicker = UIDatePicker()
  
  let modalWidth: CGFloat = 290
  let modalHeight: CGFloat = 290
  let modalTitleText: String = "Pick a date"
  let pickerMinuteInterval: Int = 5
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    delegate = nil
    data = nil
    Modal.clear(background: view)
  }
  
  // MARK: - open
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
    picker.minimumDate = NSDate().dateByAddingTimeInterval(1*60)
  }

  // MARK: - close
  private func close(date date: NSDate?) {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
      if let date = date, indexPath = self.indexPath {
        self.delegate?.modalDatePickerValue(indexPath: indexPath, date: date)
      }
    }
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    let yes = createButton(title: Modal.textYes, bold: false)
    let no = createButton(title: Modal.textNo, bold: true)
    let topSeparator = Modal.createSeparator()
    let midSeparator = Modal.createSeparator()
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: modalTitleText)
    
    modal.addSubview(picker)
    modal.addSubview(yes)
    modal.addSubview(no)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    
    picker.minuteInterval = pickerMinuteInterval
    picker.translatesAutoresizingMaskIntoConstraints = false
  
    NSLayoutConstraint.activateConstraints([
      modal.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
      modal.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
      modal.widthAnchor.constraintEqualToConstant(modalWidth),
      modal.heightAnchor.constraintEqualToConstant(modalHeight),
      
      picker.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      picker.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      picker.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Constant.Button.height),
      picker.bottomAnchor.constraintEqualToAnchor(topSeparator.topAnchor),
      
      no.trailingAnchor.constraintEqualToAnchor(midSeparator.leadingAnchor),
      no.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      no.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      no.heightAnchor.constraintEqualToConstant(Constant.Button.height),
      
      yes.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      yes.leadingAnchor.constraintEqualToAnchor(midSeparator.trailingAnchor),
      yes.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      yes.heightAnchor.constraintEqualToConstant(Constant.Button.height),
      yes.widthAnchor.constraintEqualToAnchor(no.widthAnchor),
      
      topSeparator.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparator.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparator.bottomAnchor.constraintEqualToAnchor(yes.topAnchor),
      topSeparator.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      midSeparator.leadingAnchor.constraintEqualToAnchor(no.trailingAnchor),
      midSeparator.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      midSeparator.heightAnchor.constraintEqualToAnchor(no.heightAnchor),
      midSeparator.widthAnchor.constraintEqualToConstant(Modal.separator),
      ])
  }
  
  private func createButton(title title: String, bold: Bool) -> UIButton {
    let button = UIButton()
    button.tag = Int(bold)
    button.layer.cornerRadius = Modal.radius
    button.setTitle(title, forState: .Normal)
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
    button.titleLabel?.font = bold ? .boldSystemFontOfSize(Modal.textSize) : .systemFontOfSize(Modal.textSize)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.playSound(systemSound: .Tap)
    Util.animateButtonPress(button: button)
    switch button.tag {
    case 0: close(date: picker.date)
    default: close(date: nil)
    }
  }
}