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
    let title = title ?? "hello" //confirm ? buttonConfirmTitle: buttonCancelTitle
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
