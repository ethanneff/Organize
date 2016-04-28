import UIKit

class SettingViewController: UIViewController {

  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = Config.colorBackground
  }
}
