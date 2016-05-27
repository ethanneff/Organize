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
    case NotebookHeader
    case ChangeTitle
//    case ChangeNotebook
    case CollapseAll
    case UncollapseAll
    case DeleteAll
    
    case SettingsHeader
    case ViewTutorial
    case ToggleSound
    case ToggleColor
    
    case SocialHeader
    case SendFeedback
    case ShareApp
  
    case AccountHeader
    case UpdateAccount
    case Logout
    
    static var count: Int {
      return Logout.hashValue+1
    }
    
    var header: Bool {
      switch self {
      case .NotebookHeader, .SocialHeader, .SettingsHeader, .AccountHeader: return true
      default: return false
      }
    }
    
    var title: String {
      switch self {
      case .NotebookHeader: return "Notebook"
      case .ChangeTitle: return "Change title"
      case .CollapseAll: return "Collapse all"
      case .UncollapseAll: return "Expand all"
      case .DeleteAll: return "Delete completed"
        
      case .SettingsHeader: return "Settings"
      case .ViewTutorial: return "View tutorial"
      case .ToggleSound: return "Toggle sound" // TODO: based on appstate
      case .ToggleColor: return "Toggle color" // TODO: based on app state
        
      case .SocialHeader: return "Social"
      case .SendFeedback: return "Send feedback"
      case .ShareApp: return "Share the app"
        
      case .AccountHeader: return "Account"
      case .UpdateAccount: return "Update"
      case .Logout: return "Logout"
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
        let button = UIButton()
        let enabled: Bool = info.header ? false : true
        let color: UIColor = info.header ? Constant.Color.border : Constant.Color.button
        
        let topItem: UIView = i == 0 ? scrollView : prev
        let topAttribute: NSLayoutAttribute = i == 0 ? .Top : .Bottom
        let topConstant: CGFloat = i == 0 ? Constant.Button.padding : info.header ? Constant.Button.height : 0
        
        button.tag = i
        button.setTitle(info.title, forState: .Normal)
        button.setTitleColor(color, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        button.enabled = enabled
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
    Util.playSound(systemSound: .Tap)
    Util.animateButtonPress(button: button)
    if let button = Button(rawValue: button.tag) {
      delegate?.settingsButtonPressed(button: button)
    }
  }
}
