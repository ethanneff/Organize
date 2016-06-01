import UIKit

class IntroViewController: UIViewController {
  // MARK: - properties
  let label: UILabel = UILabel()
  let introMessages = [
    "level up. reach your full potential.",
    "1% better than yesterday.",
    "100% focus. always.",
    "keep up the momentum.",
    "look for ways to both get ahead."
  ]
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    createView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    label.text = introMessages[Int(arc4random_uniform(UInt32(introMessages.count)))]
  }
  
  // MARK: - create
  private func createView() {
    let indicator = UIActivityIndicatorView()
    let image = UIImageView()
    let title = UILabel()
    
    
    view.backgroundColor = Constant.Color.button
    view.addSubview(image)
    view.addSubview(indicator)
    view.addSubview(title)
    
    title.text = "Organize"
    title.font = .boldSystemFontOfSize(22)
    title.textColor = Constant.Color.background
    title.translatesAutoresizingMaskIntoConstraints = false
    
    indicator.activityIndicatorViewStyle = .WhiteLarge
    indicator.hidesWhenStopped = true
    indicator.startAnimating()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    
    image.image = UIImage(named: "icon")!
    image.contentMode = .ScaleAspectFit
    image.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: title, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -view.frame.width/2),
      
      NSLayoutConstraint(item: image, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: image, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
      
      NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: view.frame.width/2),
      ])
  }
}
