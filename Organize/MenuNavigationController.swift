import UIKit

class MenuNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    
    pushViewController(MenuViewController(), animated: false)
  }
}
