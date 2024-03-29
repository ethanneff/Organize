import UIKit

protocol SettingsDelegate: class {
  func settingsButtonPressed(button button: SettingViewController.Button)
}

class SettingViewController: UIViewController {
  // MARK: - properties
  weak var menu: SettingsDelegate?
  weak var delegate: SettingsDelegate?
  var buttons: [Int: Button] = [:]
  
  struct Button {
    let button: UIButton
    let detail: Detail
  }
  
  enum Detail: Int {
    case Notebook
    case NotebookTitle
    case NotebookChange
    case NotebookUncollapse
    case NotebookCollapse
    case NotebookHideReminder
    case NotebookDeleteCompleted
    
    case App
    case AppTutorial
    case AppColor
    case AppTimer
    case AppFeedback
    case AppShare
    
    case Cloud
    case CloudUpload
    case CloudDownload
    
    case Account
    case AccountAchievements
    case AccountEmail
    case AccountPassword
    case AccountDelete
    case AccountLogout
    
    case Upgrade
    case UpgradeBuy
    
    static var count: Int {
      return UpgradeBuy.hashValue+1
    }
    
    var header: Bool {
      switch self {
      case .Notebook, .App, .Cloud, .Account, .Upgrade: return true
      default: return false
      }
    }
    
    var active: Bool {
      switch self {
      case .NotebookChange, .NotebookHideReminder, .AccountAchievements, .Upgrade, .UpgradeBuy, .Cloud, .CloudUpload, .CloudDownload: return false
      default: return true
      }
    }
    
    var highlighted: Bool {
      switch self {
      case .UpgradeBuy: return true
      default: return false
      }
    }
    
    var title: String {
      switch self {
      case .Notebook: return "Notebook"
      case .NotebookTitle: return "Change title"
      case .NotebookChange: return "Change notebook"
      case .NotebookCollapse: return "Collapse all"
      case .NotebookUncollapse: return "Expand all"
      case .NotebookHideReminder: return Constant.UserDefault.get(key: Constant.UserDefault.Key.IsRemindersHidden) as? Bool ?? false ? "Hide reminders" : "Show reminders"
      case .NotebookDeleteCompleted: return "Delete completed"
        
      case .App: return "App"
      case .AppTutorial: return "View tutorial"
      case .AppTimer: return Constant.UserDefault.get(key: Constant.UserDefault.Key.IsTimerActive) as? Bool ?? false ? "Modify timer" : "Activate timer"
      case .AppColor: return "Change color"
      case .AppFeedback: return "Send feedback"
      case .AppShare: return "Share with a friend"
        
      case .Cloud: return "Cloud"
      case .CloudUpload: return "Upload"
      case .CloudDownload: return "Download"
        
      case .Account: return "Account"
      case .AccountAchievements: return "View achievements"
      case .AccountEmail: return "Change email"
      case .AccountPassword: return "Change password"
      case .AccountDelete: return "Delete account"
      case .AccountLogout: return "Logout"
        
      case .Upgrade: return "Upgrade"
      case .UpgradeBuy: return "Buy the dev a coffee"
      }
    }
  }
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    var constraints: [NSLayoutConstraint] = []
    view.backgroundColor = Constant.Color.background
    
    // scroll view
    let scrollView = UIScrollView()
    var scrollViewContentSizeHeight: CGFloat = Constant.Button.padding
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    // buttons
    var prev: UIButton = UIButton()
    for i in 0..<Detail.count {
      if let detail = Detail(rawValue: i) {
        let button = UIButton()
        let enabled: Bool = detail.header ? false : true
        let color: UIColor = detail.header ? Constant.Color.border : Constant.Color.button
        let topItem: UIView = i == 0 ? scrollView : prev
        let topAttribute: NSLayoutAttribute = i == 0 ? .Top : .Bottom
        let topConstant: CGFloat = i == 0 ? Constant.Button.padding : detail.header ? Constant.Button.padding*2 : 0
        
        button.tag = detail.rawValue
        button.hidden = !detail.active
        button.backgroundColor = Constant.Color.background
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitle(detail.title, forState: .Normal)
        button.setTitleColor(color, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
        button.enabled = enabled
        button.contentHorizontalAlignment = detail.header ? .Center : .Left
        button.titleLabel?.font = .systemFontOfSize(Constant.Button.fontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        buttons[detail.rawValue] = Button(button: button, detail: detail)
        if !detail.active {
          continue
        }
        scrollView.addSubview(button)
        
        constraints.append(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding*2))
        constraints.append(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding*2))
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
  
  // MARK: - button
  func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    if let button = buttons[button.tag] {
      delegate?.settingsButtonPressed(button: button)
    }
  }
}
