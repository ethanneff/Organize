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
  func modalDatePickerDisplay()
  func modalDatePickerValue(date date: NSDate)
}

class ModalDatePickerViewController: UIViewController {
  // MARK: properties
  weak var delegate: ModalDatePickerDelegate?
  
  
  // TODO: look into var? for memory leak
  // TODO: need deinit
  var modal: UIView = UIView()
  var modalWidth: CGFloat = 290
  var modalHeight: CGFloat = 290
  let modalTitleText: String = "Pick a date"
  
  let picker: UIDatePicker = UIDatePicker()
  let pickerMinuteInterval: Int = 5
  
  
  // MARK: create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    Modal.createModalTemplate(background: view, modal: modal, titleText: modalTitleText)
    
    modal.widthAnchor.constraintEqualToConstant(modalWidth).active = true
    modal.heightAnchor.constraintEqualToConstant(modalHeight).active = true
    
    modal.addSubview(picker)
    
    let yes = UIButton()
    modal.addSubview(yes)
    
    let no = UIButton()
    modal.addSubview(no)
    
    let topSeparator = UIView()
    modal.addSubview(topSeparator)
    
    let midSeparator = UIView()
    modal.addSubview(midSeparator)
    
    // TODO: need to combine into activeConstraint array
    picker.minuteInterval = pickerMinuteInterval
    picker.translatesAutoresizingMaskIntoConstraints = false
    picker.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    picker.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    picker.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Modal.textHeight).active = true
    picker.bottomAnchor.constraintEqualToAnchor(topSeparator.topAnchor).active = true
    
    no.layer.cornerRadius = Modal.radius
    no.setTitle(Modal.textNo, forState: .Normal)
    no.setTitleColor(Config.colorButton, forState: .Normal)
    no.setTitleColor(Config.colorBorder, forState: .Highlighted)
    no.titleLabel?.font = .boldSystemFontOfSize(Modal.textSize)
    no.addTarget(self, action: #selector(noButtonPressed(_:)), forControlEvents: .TouchUpInside)
    no.translatesAutoresizingMaskIntoConstraints = false
    no.trailingAnchor.constraintEqualToAnchor(midSeparator.leadingAnchor).active = true
    no.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    no.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    no.heightAnchor.constraintEqualToConstant(Modal.textHeight).active = true
    
    yes.layer.cornerRadius = Modal.radius
    yes.setTitle(Modal.textYes, forState: .Normal)
    yes.setTitleColor(Config.colorButton, forState: .Normal)
    yes.setTitleColor(Config.colorBorder, forState: .Highlighted)
    yes.titleLabel?.font = .systemFontOfSize(Modal.textSize)
    yes.addTarget(self, action: #selector(yesButtonPressed(_:)), forControlEvents: .TouchUpInside)
    yes.translatesAutoresizingMaskIntoConstraints = false
    yes.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    yes.leadingAnchor.constraintEqualToAnchor(midSeparator.trailingAnchor).active = true
    yes.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    yes.heightAnchor.constraintEqualToConstant(Modal.textHeight).active = true
    yes.widthAnchor.constraintEqualToAnchor(no.widthAnchor).active = true
    
    topSeparator.backgroundColor = Config.colorBorder
    topSeparator.translatesAutoresizingMaskIntoConstraints = false
    topSeparator.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    topSeparator.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    topSeparator.bottomAnchor.constraintEqualToAnchor(yes.topAnchor).active = true
    topSeparator.heightAnchor.constraintEqualToConstant(Modal.separator).active = true
    
    midSeparator.backgroundColor = Config.colorBorder
    midSeparator.translatesAutoresizingMaskIntoConstraints = false
    midSeparator.leadingAnchor.constraintEqualToAnchor(no.trailingAnchor).active = true
    midSeparator.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor).active = true
    midSeparator.heightAnchor.constraintEqualToAnchor(no.heightAnchor).active = true
    midSeparator.widthAnchor.constraintEqualToConstant(Modal.separator).active = true
  }
  
  // MARK: buttons
  internal func yesButtonPressed(button: UIButton) {
    close(date: picker.date)
  }
  
  internal func noButtonPressed(button: UIButton) {
    close(date: nil)
  }
  
  // MARK: open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  private func close(date date: NSDate?) {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
      Modal.clear(background: self.view)
      if let date = date  {
        self.delegate?.modalDatePickerValue(date: date)
      }
    }
  }
}