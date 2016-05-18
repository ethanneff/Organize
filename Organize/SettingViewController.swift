import UIKit

protocol SettingsDelegate: class {
  func settingsButtonPressed(button button: SettingViewController.Button)
}

class SettingViewController: UIViewController {
  
  weak var menu: SettingsDelegate?
  weak var delegate: SettingsDelegate?
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  enum Button: Int  {
    case Collapse
    case Uncollapse
    case Delete
    case Feedback
    case Tutorial
    
    static var count: Int {
      return Tutorial.hashValue+1
    }
    
    var title: String {
      switch self {
      case .Collapse: return "Collapse all"
      case .Uncollapse: return "Expand all"
      case .Delete: return "Delete completed"
      case .Feedback: return "Send feedback"
      case .Tutorial: return "Watch tutorial"
      }
    }
    
    var topAnchorMultiplier: CGFloat {
      switch self {
      case .Feedback, .Tutorial: return 1
      default: return 0
      }
    }
  }
  
  private func setupView() {
    var constraints: [NSLayoutConstraint] = []
    view.backgroundColor = Config.colorBackground
    
    // scroll view
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    // buttons
    for i in 0..<Button.count {
      if let info = Button(rawValue: i) {
        let button = UIButton()
        button.tag = i
        button.setTitle(info.title, forState: .Normal)
        button.setTitleColor(Config.colorButton, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(button)
        
        constraints.append(button.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor))
        constraints.append(button.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor))
        constraints.append(button.heightAnchor.constraintEqualToConstant(Config.buttonHeight))
        constraints.append(button.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: CGFloat(i)*Config.buttonHeight+Config.buttonPadding+info.topAnchorMultiplier*Config.buttonHeight))
      }
    }
    
    // scroll view
    constraints.append(scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor))
    constraints.append(scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor))
    constraints.append(scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor))
    constraints.append(scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor))
    scrollView.setContentViewSize()
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  
  func buttonPressed(button: UIButton) {
    Util.playSound(systemSound: .Tap)
    Util.animateButtonPress(button: button)
    if let button = Button(rawValue: button.tag) {
      delegate?.settingsButtonPressed(button: button)
    }
  }
}
