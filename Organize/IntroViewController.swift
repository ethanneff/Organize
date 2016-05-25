import UIKit

class IntroViewController: UIViewController {
  let label: UILabel = UILabel()
  let introMessages = [
  "level up. reach your full potential.",
  "1% better than yesterday.",
  "100% focus. always.",
  "keep up the momentum.",
  "look for ways to both get ahead."
  ]
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = Constant.Color.button
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    indicator.hidesWhenStopped = true
    indicator.startAnimating()
    view.addSubview(indicator)
    
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    indicator.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor, constant: -50).active = true
    
    label.textColor = Constant.Color.background
    label.textAlignment = .Center
    view.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
    label.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    label.text = introMessages[Int(arc4random_uniform(UInt32(introMessages.count)))]
  }
}
