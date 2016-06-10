import UIKit

class IntroNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    whiteStatusBarText()
    pushViewController(IntroViewController(), animated: true)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    setNeedsStatusBarAppearanceUpdate()
    determineController()
  }
  
  private func determineController() {
    Util.delay(Constant.App.loadingDelay) {
      if let _ = Remote.Auth.user {
        self.displayController(navController: MenuNavigationController())
      } else {
        self.displayController(navController: AccessNavigationController())
      }
    }
  }
  
  private func displayController(navController navController: UINavigationController) {
    navController.modalTransitionStyle = .CrossDissolve
    presentViewController(navController, animated: true, completion: nil)
  }
  
  private func whiteStatusBarText() {
    navigationBar.hidden = true
    navigationBar.barStyle = .Black
  }
}
