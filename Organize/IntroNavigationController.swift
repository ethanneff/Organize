import UIKit

class IntroNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    navigationBar.hidden = true
    pushViewController(IntroViewController(), animated: true)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
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
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
}
