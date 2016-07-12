import UIKit
import Firebase

class IntroNavigationController: UINavigationController {
  private enum Controller {
    case Menu
    case Access
    case Welcome
    
    var controller: UINavigationController {
      switch self {
      case .Menu: return MenuNavigationController()
      case .Access: return AccessNavigationController()
      case .Welcome: return WelcomeNavigationController()
      }
    }
    
    var delay: Bool {
      switch self {
      case .Menu: return true
      default: return false
      }
    }
  }
  
  private var nextController: Controller?
  
  override func loadView() {
    super.loadView()
    navigationBar.hidden = true
    pushViewController(IntroViewController(), animated: true)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    determineNextController()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    navToController()
  }
  
  private func determineNextController() {
    print("determineNextController")
    // simulator catch
    Notebook.get { data in
      if data == nil {
        Remote.Auth.signOut()
      }
      // controller select
      let firstOpen = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppFirstOpen) as? Bool ?? true
      if firstOpen {
        self.updateAppFirstOpen(firstOpen)
        self.nextController = .Welcome
      } else if let _ = Remote.Auth.user {
        self.nextController = .Menu
      } else {
        self.nextController = .Access
      }
    }
  }
  
  private func waitForNextController(completion: (nextController: Controller) -> ()) {
    print("waitForNextController")
    if let nextController = nextController {
      completion(nextController: nextController)
    } else {
      Util.delay(0.1) {
        self.waitForNextController(completion)
      }
    }
  }
  
  private func navToController() {
    waitForNextController { nextController in
      if nextController.delay {
        Util.delay(Constant.App.loadingDelay) {
          self.displayController(navController: nextController.controller)
        }
      } else {
        self.displayController(navController: nextController.controller)
      }
    }
  }
  
  private func updateAppFirstOpen(firstOpen: Bool) {
    if firstOpen {
      Constant.UserDefault.set(key: Constant.UserDefault.Key.AppFirstOpen, val: false)
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
