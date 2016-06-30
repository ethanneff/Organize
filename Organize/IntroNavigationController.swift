import UIKit
import Firebase

class IntroNavigationController: UINavigationController {
  override func loadView() {
    super.loadView()
    navigationBar.hidden = true
    pushViewController(IntroViewController(), animated: true)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // TODO: fix
              self.displayController(navController: TestNavigationController())
    
//    determineController()
  }
  
  private func determineController() {
    Notebook.get { data in
      if data == nil {
        Remote.Auth.signOut()
      }
      Util.delay(Constant.App.loadingDelay) {
        if let _ = Remote.Auth.user {
          self.displayController(navController: MenuNavigationController())
        } else {
          self.displayController(navController: AccessNavigationController())
        }
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
