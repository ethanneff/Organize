import UIKit

class SearchViewController: UIViewController {
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  func setupView() {
    var constraints: [NSLayoutConstraint] = []
    view.backgroundColor = Config.colorBackground
    
    // scroll view
    let scrollView = UIScrollView()
    var scrollViewHeight: CGFloat = 0
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    // label
    let label = UILabel()
    label.text = "coming soon.."
    label.textAlignment = .Center
    label.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(label)
    constraints.append(label.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor))
    constraints.append(label.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor))
    constraints.append(label.heightAnchor.constraintEqualToConstant(Config.buttonHeight))
    constraints.append(label.centerYAnchor.constraintEqualToAnchor(scrollView.centerYAnchor))
    scrollViewHeight += Config.buttonHeight
    
    // scroll view
    constraints.append(scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor))
    constraints.append(scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor))
    constraints.append(scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor))
    constraints.append(scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor))
    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollViewHeight)
    
    NSLayoutConstraint.activateConstraints(constraints)

  }
}
