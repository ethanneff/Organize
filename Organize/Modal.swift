import UIKit

class Modal: UIViewController {
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
  
  deinit {

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
    Util.playSound(systemSound: .Tap)
    Util.threadMain {
      self.animateOut() {
        self.dismissViewControllerAnimated(false, completion: {
          if let completion = completion {
            completion()
          }
          self.completion = nil
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

extension Modal {
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

extension Modal {
  // MARK: - create
  internal func createTitle(title text: String?) -> UILabel {
    let title: UILabel = UILabel()
    title.text = text
    title.textAlignment = .Center
    title.font = .boldSystemFontOfSize(buttonFontSize)
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
  
  internal func createProgress() -> UIView {
    let view = UIView()
    view.backgroundColor = Constant.Color.button
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }
  
  internal func createImageView(image image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.image = image
    imageView.contentMode = .ScaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
  }
  
  internal func createButton(title title: String?, confirm: Bool) -> UIButton {
    let button: UIButton = UIButton()
    let title = title ?? (confirm ? buttonConfirmTitle : buttonCancelTitle)
    button.tag = Int(confirm)
    button.layer.cornerRadius = radius
    button.setTitle(title, forState: .Normal)
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
    textField.font = UIFont.boldSystemFontOfSize(buttonFontSize)
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
  
  internal func createDatePicker(minuteInterval minuteInterval: Int) -> UIDatePicker {
    let datePicker: UIDatePicker = UIDatePicker()
    datePicker.minuteInterval = minuteInterval
    datePicker.translatesAutoresizingMaskIntoConstraints = false
    datePicker.minimumDate = NSDate().dateByAddingTimeInterval(1*60)
    
    return datePicker
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

extension Modal {
  // MARK: - dynamic label
  internal func updateLabel(text text: String?, label: UILabel, modalMinWidth: CGFloat, modalMaxWidth: CGFloat, modalMinHeight: CGFloat, modalMaxHeight: CGFloat, modalWidthConstraint: NSLayoutConstraint, modalHeightConstraint: NSLayoutConstraint) {
    label.translatesAutoresizingMaskIntoConstraints = true
    label.text = text
    label.textAlignment = .Center
    label.numberOfLines = 0
    label.font = .boldSystemFontOfSize(buttonFontSize)
    label.lineBreakMode = .ByTruncatingTail
    let minLabelSize = CGSizeMake(modalMinWidth, modalMinHeight/2);
    let maxLabelSize = CGSizeMake(modalMaxWidth, modalMaxHeight);
    let expectedSize = label.sizeThatFits(maxLabelSize)
    let actualSize = CGSizeMake(minLabelSize.width > expectedSize.width ?  minLabelSize.width : expectedSize.width, expectedSize.height > maxLabelSize.height ? maxLabelSize.height : expectedSize.height)
    
    label.frame = CGRectMake(Constant.Button.padding*2, Constant.Button.padding*1.5, actualSize.width, actualSize.height)
    modalWidthConstraint.constant = label.frame.size.width+Constant.Button.padding*4
    modalHeightConstraint.constant = label.frame.size.height+Constant.Button.height+separatorHeight+Constant.Button.padding*2.5
  }
}


extension Modal {
  // MARK: - constraints
  internal func constraintButtonDoubleBottom(topSeparator topSeparator: UIView, midSeparator: UIView, left: UIButton, right: UIButton) {
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: right, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: midSeparator, attribute: .Leading, relatedBy: .Equal, toItem: left, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: right, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: midSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: midSeparator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: left, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: left, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: left, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: right, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: right, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: right, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      NSLayoutConstraint(item: right, attribute: .Width, relatedBy: .Equal, toItem: left, attribute: .Width, multiplier: 1, constant: 0),
      ])
  }
  
  internal func constraintButtonSingleBottom(topSeparator topSeparator: UIView, button: UIButton) {
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: button, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
  }
  
  internal func constraintHeader(header header: UIView) {
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: header, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: header, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: header, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding*1.2),
      NSLayoutConstraint(item: header, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      ])
  }
}