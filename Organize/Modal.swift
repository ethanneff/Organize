import UIKit

class Modal {
  static let animationDuration: NSTimeInterval = 0.2
  static let radius: CGFloat = 15
  static let separator: CGFloat = 0.5
  static let textSize: CGFloat = 17
  static let textYes: String = "Done"
  static let textNo: String = "Cancel"
  
  static func animateIn(modal modal: UIView, background: UIView, completion: (() -> ())?) {
    modal.transform = CGAffineTransformMakeScale(0.01, 0.01)
    background.alpha = 0
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseOut, animations: {
      modal.transform = CGAffineTransformIdentity
      background.alpha = 1
    }) { finished in
      if let completion = completion {
        completion()
      }
    }
  }
  
  static func animateOut(modal modal: UIView, background: UIView, completion: () -> ()) {
    modal.transform = CGAffineTransformIdentity
    background.alpha = 1
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseOut, animations: {
      modal.transform = CGAffineTransformMakeScale(0.01, 0.01)
      background.alpha = 0
    }) { finished in
      completion()
    }
  }
  
  static func clear(background background: UIView) {
    for v in background.subviews {
      v.removeFromSuperview()
    }
    background.removeFromSuperview()
  }
  
  static func createModalTemplate(background background: UIView, modal: UIView, titleText: String?) {
    var constraints: [NSLayoutConstraint] = []
    
    // background
    background.backgroundColor = Constant.Color.backdrop
    background.addSubview(modal)
    
    // modal
    modal.backgroundColor = Constant.Color.background
    modal.layer.cornerRadius = Modal.radius
    modal.layer.masksToBounds = true
    modal.translatesAutoresizingMaskIntoConstraints = false
    
    if let titleText = titleText {
      let title = UILabel()
      modal.addSubview(title)
      
      title.textAlignment = .Center
      title.font = .boldSystemFontOfSize(Modal.textSize)
      title.text = titleText
      title.translatesAutoresizingMaskIntoConstraints = false
      
      constraints.append(NSLayoutConstraint(item: title, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0))
      constraints.append(NSLayoutConstraint(item: title, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0))
      constraints.append(NSLayoutConstraint(item: title, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding))
      constraints.append(NSLayoutConstraint(item: title, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    }
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  static func createModal() -> UIView {
    let modal = UIView()
    modal.backgroundColor = Constant.Color.background
    modal.layer.cornerRadius = Modal.radius
    modal.layer.masksToBounds = true
    modal.translatesAutoresizingMaskIntoConstraints = false
    
    return modal
  }
  
  static func updateBackdrop(controllerView controllerView: UIView) -> UIView {
    controllerView.backgroundColor = Constant.Color.backdrop
    
    return controllerView
  }
  
  static func createSeparator() -> UIView {
    let separator = UIView()
    separator.backgroundColor = Constant.Color.border
    separator.translatesAutoresizingMaskIntoConstraints = false
    
    return separator
  }
  
  static func createTextField(text text: String?, placeholder: String?) -> UITextField {
    let textField = UITextField()
    textField.text = text
    textField.placeholder = placeholder
    textField.returnKeyType = .Done
    textField.textAlignment = .Center
    textField.font = UIFont.boldSystemFontOfSize(Modal.textSize)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.tintColor = Constant.Color.button
    
    return textField
  }
  
  static func createButton(confirm confirm: Bool) -> UIButton {
    let button = UIButton()
    button.tag = Int(confirm)
    button.layer.cornerRadius = Modal.radius
    button.setTitle(confirm ? Modal.textYes: Modal.textNo, forState: .Normal)
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
    button.titleLabel?.font = confirm ? .systemFontOfSize(Modal.textSize) : .boldSystemFontOfSize(Modal.textSize)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  
  static func show(parentController parentController: UIViewController, modalController: UIViewController, modal: UIView) {
    modalController.modalPresentationStyle = .OverCurrentContext
    parentController.presentViewController(modalController, animated: false, completion: nil)
    animateIn(modal: modal, background: modalController.view, completion: nil)
  }
}










class Modalz: UIViewController {
  // MARK: - properties
  var modal: UIView!
  
  var completion: completionBlock
  var tapToClose: UITapGestureRecognizer = UITapGestureRecognizer()
  let animationDuration: NSTimeInterval = 0.25
  let radius: CGFloat = 15
  let separatorHeight: CGFloat = 0.5
  let buttonConfirmTitle: String = "Okay"
  let buttonCancelTitle: String = "Cancel"
  let buttonFontSize: CGFloat = 17
  
  typealias completionBlock = ((output: [String: AnyObject]) -> ())?
  
  // MARK: - init
  init() {
    super.init(nibName: nil, bundle: nil)
    modal = createModal()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  // MARK: - public
  func show(controller controller: UIViewController, dismissible: Bool = false, completion: completionBlock = nil) {
    Util.threadMain {
      self.modalPresentationStyle = .OverCurrentContext
      controller.presentViewController(self, animated: false) {
        self.animateIn() {
          if dismissible {
            self.tapToClose.addTarget(self, action: #selector(self.tapToClosePressed(_:)))
            self.view.addGestureRecognizer(self.tapToClose)
          }
          self.completion = completion
        }
      }
    }
  }
  
  func hide(completion: (() -> ())? = nil) {
    Util.threadMain {
      self.completion = nil
      self.animateOut() {
        self.dismissViewControllerAnimated(false, completion: {
          if let completion = completion {
            completion()
          }
        })
      }
    }
  }
  
  // MARK: - gestures
  internal func tapToClosePressed(gesture: UITapGestureRecognizer) {
    // click backdrop
    if !CGRectContainsPoint(modal.frame, gesture.locationInView(view)) {
      hide()
    }
  }
}

extension Modalz {
  // MARK: - animation
  private func animateOut(completion: () -> ()) {
    modal.transform = CGAffineTransformIdentity
    modal.alpha = 1
    view.alpha = 1
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseOut, animations: {
      self.modal.transform = CGAffineTransformMakeScale(0.01, 0.01)
      self.modal.alpha = 0
      self.view.alpha = 0
    }) { finished in
      completion()
    }
  }
  
  private func animateIn(completion: (() -> ())? = nil) {
    modal.transform = CGAffineTransformMakeScale(0.01, 0.01)
    modal.alpha = 0
    view.alpha = 0
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: .CurveEaseOut, animations: {
      self.modal.transform = CGAffineTransformIdentity
      self.modal.alpha = 1
      self.view.alpha = 1
    }) { finished in
      if let completion = completion {
        completion()
      }
    }
  }
}

extension Modalz {
  // MARK: - create
  internal func createTitle() -> UILabel {
    let title: UILabel = UILabel()
    title.textAlignment = .Center
    title.font = .boldSystemFontOfSize(Modal.textSize)
    title.translatesAutoresizingMaskIntoConstraints = false
    
    return title
  }
  
  internal func createIndicator() -> UIActivityIndicatorView {
    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.activityIndicatorViewStyle = .WhiteLarge
    indicator.color = Constant.Color.button
    indicator.startAnimating()
    
    return indicator
  }
  
  internal func createButton(confirm confirm: Bool) -> UIButton {
    let button: UIButton = UIButton()
    button.tag = Int(confirm)
    button.layer.cornerRadius = radius
    button.setTitle(confirm ? buttonConfirmTitle: buttonCancelTitle, forState: .Normal)
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
    button.titleLabel?.font = confirm ? .systemFontOfSize(buttonFontSize) : .boldSystemFontOfSize(buttonFontSize)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  internal func createTextField() -> UITextField {
    let textField = UITextField()
    textField.returnKeyType = .Done
    textField.textAlignment = .Center
    textField.font = UIFont.boldSystemFontOfSize(Modal.textSize)
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.tintColor = Constant.Color.button
    
    return textField
  }
  
  internal func createSeparator() -> UIView {
    let separator: UIView = UIView()
    separator.backgroundColor = Constant.Color.border
    separator.translatesAutoresizingMaskIntoConstraints = false
    
    return separator
  }
  
  internal func createModal() -> UIView {
    let modal: UIView = UIView()
    modal.backgroundColor = Constant.Color.background
    modal.layer.cornerRadius = radius
    modal.layer.masksToBounds = true
    modal.translatesAutoresizingMaskIntoConstraints = false
    modal.alpha = 0
    view.alpha = 0
    view.backgroundColor = Constant.Color.backdrop
    view.addSubview(modal)
    
    return modal
  }
  
}
