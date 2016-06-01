import UIKit

class SearchViewController: UIViewController {

  override func loadView() {
    super.loadView()
    setupView()
  }

  func setupView() {
    var constraints: [NSLayoutConstraint] = []
    view.backgroundColor = Constant.Color.background

    // scroll view
    let scrollView = UIScrollView()
    var scrollViewHeight: CGFloat = 0
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)

    // label
    let label = UILabel()
    label.text = "coming soon..."
    label.textAlignment = .Center
    label.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(label)

    constraints.append(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: scrollView, attribute: .CenterY, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    scrollViewHeight += Constant.Button.height

    // scroll view
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: scrollViewHeight)

    NSLayoutConstraint.activateConstraints(constraints)
  }
}
