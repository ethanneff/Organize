///*
// 
// // add delegate
// class ViewController: UIViewController, ModalDatePickerDelegate {}
// 
// // call modal controller
// func modalDatePickerDisplay() {
// let controller = ModalDatePickerViewController()
// controller.delegate = self
// controller.modalPresentationStyle = .OverCurrentContext
// presentViewController(controller, animated: false, completion: nil)
// }
// 
// // get date back from modal controller
// func modalDatePickerValue(date date: NSDate) {
// 
// }
// 
// */


import UIKit

class ModalDatePicker: Modal {
  
}


//
//import UIKit
//
//protocol ModalDatePickerDelegate: class {
//  func modalDatePickerDisplay(indexPath indexPath: NSIndexPath)
//  func modalDatePickerValue(indexPath indexPath: NSIndexPath, date: NSDate)
//}
//
//class ModalDatePickerViewController: UIViewController {
//  // MARK: - properties
//  weak var delegate: ModalDatePickerDelegate?
//  weak var data: Reminder?
//  var indexPath: NSIndexPath?
//  
//  let modal: UIView = UIView()
//  let picker: UIDatePicker = UIDatePicker()
//  
//  let modalWidth: CGFloat = 290
//  let modalHeight: CGFloat = 290
//  let modalTitleText: String = "Pick a date"
//  let pickerMinuteInterval: Int = 5
//  
//  // MARK: - deinit
//  deinit {
//    dealloc()
//  }
//  
//  private func dealloc() {
//    delegate = nil
//    data = nil
//    Modal.clear(background: view)
//  }
//  
//  // MARK: - open
//  override func viewWillAppear(animated: Bool) {
//    super.viewWillAppear(animated)
//    Modal.animateIn(modal: modal, background: view, completion: nil)
//    picker.minimumDate = NSDate().dateByAddingTimeInterval(1*60)
//  }
//  
//  // MARK: - close
//  private func close(date date: NSDate?) {
//    Modal.animateOut(modal: modal, background: view) {
//      self.dismissViewControllerAnimated(false, completion: nil)
//      if let date = date, indexPath = self.indexPath {
//        self.delegate?.modalDatePickerValue(indexPath: indexPath, date: date)
//      }
//    }
//  }
//  
//  // MARK: - create
//  override func loadView() {
//    super.loadView()
//    setupView()
//  }
//  
//  private func setupView() {
//    let yes = createButton(title: Modal.textYes, bold: false)
//    let no = createButton(title: Modal.textNo, bold: true)
//    let topSeparator = Modal.createSeparator()
//    let midSeparator = Modal.createSeparator()
//    
//    Modal.createModalTemplate(background: view, modal: modal, titleText: modalTitleText)
//    
//    modal.addSubview(picker)
//    modal.addSubview(yes)
//    modal.addSubview(no)
//    modal.addSubview(topSeparator)
//    modal.addSubview(midSeparator)
//    
//    picker.minuteInterval = pickerMinuteInterval
//    picker.translatesAutoresizingMaskIntoConstraints = false
//    
//    NSLayoutConstraint.activateConstraints([
//      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalWidth),
//      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalHeight),
//      
//      NSLayoutConstraint(item: picker, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: picker, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: picker, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.height),
//      NSLayoutConstraint(item: picker, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
//      
//      NSLayoutConstraint(item: no, attribute: .Trailing, relatedBy: .Equal, toItem: midSeparator, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      
//      NSLayoutConstraint(item: yes, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Leading, relatedBy: .Equal, toItem: midSeparator, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      NSLayoutConstraint(item: yes, attribute: .Width, relatedBy: .Equal, toItem: no, attribute: .Width, multiplier: 1, constant: 0),
//      
//      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: yes, attribute: .Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      
//      NSLayoutConstraint(item: midSeparator, attribute: .Leading, relatedBy: .Equal, toItem: no, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Height, relatedBy: .Equal, toItem: no, attribute: .Height, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      ])
//  }
//  
//  private func createButton(title title: String, bold: Bool) -> UIButton {
//    let button = UIButton()
//    button.tag = Int(bold)
//    button.layer.cornerRadius = Modal.radius
//    button.setTitle(title, forState: .Normal)
//    button.setTitleColor(Constant.Color.button, forState: .Normal)
//    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
//    button.titleLabel?.font = bold ? .boldSystemFontOfSize(Modal.textSize) : .systemFontOfSize(Modal.textSize)
//    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
//    button.translatesAutoresizingMaskIntoConstraints = false
//    
//    return button
//  }
//  
//  // MARK: - buttons
//  internal func buttonPressed(button: UIButton) {
//    Util.playSound(systemSound: .Tap)
//    Util.animateButtonPress(button: button)
//    switch button.tag {
//    case 0: close(date: picker.date)
//    default: close(date: nil)
//    }
//  }
//}