import UIKit


protocol SettingsDelegate: class {
  func settingsButtonPressed(button button: SettingViewController.Button)
}

class SettingViewController: UIViewController {
  
  weak var delegate: SettingsDelegate?
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  enum Button: Int  {
    case Collapse
    case Uncollapse
    case Delete
    
    static var count: Int {
      return Delete.hashValue+1
    }
    
    var title: String {
      switch self {
      case .Collapse: return "Collapse all"
      case .Uncollapse: return "Expand all"
      case .Delete: return "Delete collapsed"
      }
    }
  }
  
  private func setupView() {
    view.backgroundColor = Config.colorBackground
    
    createButtons()
  }
  
  func createButtons() {
    var constraints: [NSLayoutConstraint] = []
    for i in 0..<Button.count {
      let info = Button(rawValue: i)
      print(info)
      let button = UIButton()
      button.tag = i
      button.setTitle(info?.title, forState: .Normal)
      button.setTitleColor(Config.colorButton, forState: .Normal)
      button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(button)
      
      constraints.append(button.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor))
      constraints.append(button.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor))
      constraints.append(button.heightAnchor.constraintEqualToConstant(Config.buttonHeight))
      constraints.append(button.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: CGFloat(i)*Config.buttonHeight+Config.buttonPadding))
    }
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    if let button = Button(rawValue: button.tag) {
      delegate?.settingsButtonPressed(button: button)
    }
  }
}
