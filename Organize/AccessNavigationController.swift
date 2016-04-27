import UIKit

class AccessNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    navigationbarHidden()
    setupGestures()
    pushViewController(LoginViewController(), animated: false)
  }
  
  private func navigationbarHidden() {
    // attach the status bar to the navigation bar (remove transparency)
    navigationBar.translucent = false
    // remove navigation bar bottom line
    navigationBar.hideBottomHairline()
  }
  
  private func setupGestures() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    tap.cancelsTouchesInView = false
    navigationBar.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  // TODO: need to dismiss controller before going to menu
}
