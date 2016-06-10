import UIKit

class AccessNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    navigationBarColor()
    setupGestures()
    pushViewController(LoginViewController(), animated: false)
  }
  
  private func navigationBarColor() {
    navigationBar.hideBottomHairline()
  }
  
  private func setupGestures() {
    // tap navigation bar
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    tap.cancelsTouchesInView = false
    navigationBar.addGestureRecognizer(tap)
    navigationBar.barStyle = Constant.Color.statusBar
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
}
