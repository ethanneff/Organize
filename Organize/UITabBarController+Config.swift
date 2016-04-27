import UIKit

extension UITabBarController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    // color
    tabBar.backgroundImage = UIImage()
    tabBar.backgroundColor = Config.colorBackground
    tabBar.tintColor = Config.colorButton
  }
}