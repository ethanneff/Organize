import UIKit

extension UITabBarController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    tabBar.backgroundImage = UIImage()
    tabBar.backgroundColor = Constant.Color.background
    tabBar.tintColor = Constant.Color.button
  }
}