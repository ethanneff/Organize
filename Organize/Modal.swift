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
  
  static func createSeparator() -> UIView {
    let separator = UIView()
    separator.backgroundColor = Constant.Color.border
    separator.translatesAutoresizingMaskIntoConstraints = false
    
    return separator
  }
  
  static func show(parentController parentController: UIViewController, modalController: UIViewController, modal: UIView) {
    modalController.modalPresentationStyle = .OverCurrentContext
    parentController.presentViewController(modalController, animated: false, completion: nil)
    animateIn(modal: modal, background: modalController.view, completion: nil)
  }
}