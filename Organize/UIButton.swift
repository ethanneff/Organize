import UIKit

extension UIButton {
  func alignImageAndTitleVertically(spacing spacing: CGFloat = 6) {
    if let imageSize = self.imageView?.image?.size, titleLabel = self.titleLabel, titleLabelText = self.titleLabel?.text {
      self.titleEdgeInsets = UIEdgeInsetsMake(-6.0, -imageSize.width, -(imageSize.height + spacing), 0.0);
      let labelString = NSString(string: titleLabelText)
      let titleSize = labelString.sizeWithAttributes([NSFontAttributeName: titleLabel.font])
      self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0.0, 0.0, -titleSize.width);
    }
  }
  
  func animate(completion: (() -> ())? = nil) {
    UIView.animateWithDuration(0.05, animations: {
      self.alpha = 0.4
      }, completion: { success in
        UIView.animateWithDuration(0.20, animations: {
          self.alpha = 1
          }, completion: { success in
            if let completion = completion {
              completion()
            }
        })
    })
    Util.playSound(systemSound: .Tap)
  }
}