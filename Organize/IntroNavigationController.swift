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
    displayController(navController: MenuNavigationController())
    
    //    User.get(completion: { user in
    //      if user == nil {
    //        Util.delay(Config.appLoadingDelay) {
    //          // TODO: create a login already viewed in nsuserdefaults
    //          self.displayController(navController: AccessNavigationController())
    //        }
    //      } else {
    //        self.displayController(navController: MenuNavigationController())
    //      }
    //    })
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
