import UIKit

class OrganizeViewController: UIViewController {

  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    view.backgroundColor = Config.colorBackground
  }
}
