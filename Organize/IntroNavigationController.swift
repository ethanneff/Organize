import UIKit

class IntroNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    whiteStatusBarText()
    pushViewController(IntroViewController(), animated: false)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    determineController()
  }
  
  private func determineController() {
    Util.delay(Constant.App.loadingDelay) {
      if let user = Remote.Auth.currentUser {
        print(user)
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
