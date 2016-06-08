import UIKit

protocol SettingsDelegate: class {
  func settingsButtonPressed(button button: SettingViewController.Button)
}

class SettingViewController: UIViewController {
  
  weak var menu: SettingsDelegate?
  weak var delegate: SettingsDelegate?
  lazy var scrollView: UIScrollView = UIScrollView()
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  enum Button: Int  {
    case Notebook
    case NotebookTitle
    case NotebookNotebook
    case NotebookCollapse
    case NotebookUncollapse
    case NotebookDeleteCompleted
    
    case Settings
    case SettingsTutorial
    case SettingsSound
    case SettingsColor
    
    case Social
    case SocialFeedback
    case SocialShare
    
    case Account
    case AccountEmail
    case AccountPassword
    case AccountDelete
    case AccountLogout
    
    static var count: Int {
      return AccountLogout.hashValue+1
    }
    
    var header: Bool {
      switch self {
      case .Notebook, .Social, .Settings, .Account: return true
      default: return false
      }
    }
    
    var active: Bool {
      switch self {
      case .NotebookNotebook, .SettingsSound, .SettingsColor, .SocialShare, .Social: return false
      default: return true
      }
    }
    
    var title: String {
      switch self {
      case .Notebook: return "Notebook"
      case .NotebookTitle: return "Change title"
      case .NotebookNotebook: return "Change notebook"
      case .NotebookCollapse: return "Collapse all"
      case .NotebookUncollapse: return "Expand all"
      case .NotebookDeleteCompleted: return "Delete completed"
        
      case .Settings: return "App"
      case .SettingsTutorial: return "View tutorial"
      case .SettingsSound: return "Toggle sound" // TODO: based on appstate
      case .SettingsColor: return "Toggle color" // TODO: based on app state
        
      case .Social: return "Social"
      case .SocialFeedback: return "Send feedback"
      case .SocialShare: return "Share the app"
        
      case .Account: return "Account"
      case .AccountEmail: return "Change email"
      case .AccountPassword: return "Change password"
      case .AccountDelete: return "Delete account"
      case .AccountLogout: return "Logout"
      }
    }
  }
  
  private func setupView() {
    var constraints: [NSLayoutConstraint] = []
    view.backgroundColor = Constant.Color.background
    
    // scroll view
    var scrollViewContentSizeHeight: CGFloat = Constant.Button.padding
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    // buttons
    var prev: UIButton = UIButton()
    for i in 0..<Button.count {
      if let info = Button(rawValue: i) {
        if !info.active {
          continue
        }
        let button = UIButton()
        let enabled: Bool = info.header ? false : true
        let color: UIColor = info.header ? Constant.Color.border : Constant.Color.button
        
        let topItem: UIView = i == 0 ? scrollView : prev
        let topAttribute: NSLayoutAttribute = i == 0 ? .Top : .Bottom
        let topConstant: CGFloat = i == 0 ? Constant.Button.padding : info.header ? Constant.Button.padding*2 : 0
        
        button.tag = i
        button.setTitle(info.title, forState: .Normal)
        button.setTitleColor(color, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        button.enabled = enabled
        button.titleLabel?.font = UIFont.systemFontOfSize(17)
        button.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(button)
        
        constraints.append(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topConstant))
        scrollViewContentSizeHeight += topConstant + Constant.Button.height
        
        prev = button
      }
    }
    
    // scroll view
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
    scrollView.contentSize = CGSize(width: 0, height: scrollViewContentSizeHeight)
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  func buttonPressed(button: UIButton) {
    // TODO: change title (notebook needs new property title)
    //    parentViewController?.navigationItem.title = "hello"
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
    if let button = Button(rawValue: button.tag) {
      delegate?.settingsButtonPressed(button: button)
    }
  }
}
