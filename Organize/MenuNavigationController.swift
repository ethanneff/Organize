import UIKit

class MenuNavigationController: UINavigationController {
  
  override func loadView() {
    super.loadView()
    
    navigationBar.hidden = false
    navigationBar.barStyle = .Default
    pushViewController(MenuViewController(), animated: false)
  }
}
