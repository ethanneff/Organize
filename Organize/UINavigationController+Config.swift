import UIKit

extension UINavigationController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    
    navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    navigationBar.backgroundColor = Constant.Color.background
    navigationBar.tintColor = Constant.Color.button
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Constant.Color.title]
    toolbar.barTintColor = Constant.Color.background
    toolbar.backgroundColor = Constant.Color.background
    toolbar.tintColor = Constant.Color.button
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