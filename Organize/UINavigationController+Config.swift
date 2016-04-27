import UIKit

extension UINavigationController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    
    navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationBar.backgroundColor = Config.colorBackground
    navigationBar.tintColor = Config.colorButton
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Config.colorTitle]
    toolbar.barTintColor = Config.colorBackground
    toolbar.backgroundColor = Config.colorBackground
    toolbar.tintColor = Config.colorButton
    //    Util.setStatusBarBackgroundColor(Config.colorBackground)
    //    navigationBar.barStyle = Config.colorStatusBar
  }
}

extension UINavigationBar {
  func hideBottomHairline() {
    hairlineImageViewInNavigationBar(self)?.hidden = true
  }
  
  func showBottomHairline() {
    hairlineImageViewInNavigationBar(self)?.hidden = false
  }
  
  private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView where imageView.bounds.height <= 1 {
      return imageView
    }
    
    for subview: UIView in view.subviews {
      if let imageView = hairlineImageViewInNavigationBar(subview) {
        return imageView
      }
    }
    
    return nil
  }
}

extension UIToolbar {
  func hideHairline() {
    hairlineImageViewInToolbar(self)?.hidden = true
  }
  
  func showHairline() {
    hairlineImageViewInToolbar(self)?.hidden = false
  }
  
  private func hairlineImageViewInToolbar(view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView where imageView.bounds.height <= 1 {
      return imageView
    }
    
    for subview: UIView in view.subviews {
      if let imageView = hairlineImageViewInToolbar(subview) {
        return imageView
      }
    }
    
    return nil
  }
}