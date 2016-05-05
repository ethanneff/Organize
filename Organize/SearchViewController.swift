import UIKit

class SearchViewController: UIViewController {
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  func setupView() {
    view.backgroundColor = Config.colorBackground
    
    let label = UILabel()
    label.text = "coming soon.."
    label.textAlignment = .Center
    label.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(label)
    
    NSLayoutConstraint.activateConstraints([
      label.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
      label.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
      label.heightAnchor.constraintEqualToConstant(Config.buttonHeight),
      label.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
      ])
  }
}
