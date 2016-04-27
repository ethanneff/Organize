import UIKit

class Modal {
  static let animationDuration: NSTimeInterval = 0.2
  static let radius: CGFloat = 15
  static let separator: CGFloat = 0.5
  static let textSize: CGFloat = 17
  static let textHeight: CGFloat = 44
  static let textPadding: CGFloat = 10
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
  
  static func createModalTemplate(background background: UIView, modal: UIView, titleText: String) {
    background.backgroundColor = Config.colorBackdrop
    
    background.addSubview(modal)
    
    let title = UILabel()
    modal.addSubview(title)
    
    title.textAlignment = .Center
    title.font = .boldSystemFontOfSize(Modal.textSize)
    title.text = titleText
    title.translatesAutoresizingMaskIntoConstraints = false
    title.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor).active = true
    title.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor).active = true
    title.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Modal.textPadding).active = true
    title.heightAnchor.constraintEqualToConstant(Modal.textHeight).active = true
    
    modal.backgroundColor = Config.colorBackground
    modal.layer.cornerRadius = Modal.radius
    modal.translatesAutoresizingMaskIntoConstraints = false
    modal.centerXAnchor.constraintEqualToAnchor(background.centerXAnchor).active = true
    modal.centerYAnchor.constraintEqualToAnchor(background.centerYAnchor).active = true
    
  }
}