//
//  Constants.swift
//  Organize
//
//  Created by Ethan Neff on 5/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit
import GoogleMobileAds

struct Constant {}

// MARK: - app
extension Constant {
  struct App {
    static let name: String = "Organize"
    static let id: String = "1116178818"
    static let loadingDelay: Double = release ? 0.2 : 0
    static let release: Bool = true
    static let logging: Bool = true
    static let email: String = "ethan.neff@eneff.com"
    static let deepLink: String = "eneff.organize"
    static let deepLinkUrl: String = "https://yp4ut.app.goo.gl/4D6z"
    static let firebaseAppId: String = "ca-app-pub-4503899421913794~1486671265"
    static let firebaseBannerAdUnitID: String = "ca-app-pub-4503899421913794/4160936069"
    static let firebaseTestDevices = release ? [] : ["890bce2d489474fd09494eaad9f55aab", kGADSimulatorID]
    static let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.IsDarkMode) as? Bool ?? false
  }
}

// MARK: - nsuserdefaults
extension Constant {
  struct UserDefault {
    enum Key: String {
      // notifications
      case IsLocalNotificationPermissionAsked
      
      // color
      case IsDarkMode
      
      // settings labels
      case IsRemindersHidden
      case IsTimerActive
      
      // review
      case FeedbackApp
      case ReviewApp
      case ReviewCount
      
      // timer
      case PomodoroState
      case PomodoroSeconds
      case PomodoroNotifications
      
      // app
      case AppOpenDate
      case AppCloseDate
      case AppFirstOpen
    }
    
    static func get(key key: UserDefault.Key) -> AnyObject? {
      return NSUserDefaults.standardUserDefaults().valueForKey(key.rawValue)
    }
    
    static func set(key key: UserDefault.Key, val: AnyObject) {
      NSUserDefaults.standardUserDefaults().setValue(val, forKey: key.rawValue)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func remove(key key: UserDefault.Key) {
      NSUserDefaults.standardUserDefaults().removeObjectForKey(key.rawValue)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
}

// MARK: - color
extension Constant {
  struct Color {
    // FIXME: this should be a class.sharedInstance
    // toggle should change properties, then save
    // get at beginning
    // no enum because need .color at end
    private enum Item {
      case Button
      case Title
      case Border
      case Background
    }
    
    static var button = Constant.Color.getColor(.Button)
    static var title = Constant.Color.getColor(.Title)
    static var border = Constant.Color.getColor(.Border)
    static var background = Constant.Color.getColor(.Background)
    static var statusBar = Constant.Color.getStatusBar()
    static var statusBarStyle = Constant.Color.getStatusBarStyle()
    
    static let selected = UIColor(hex: "#f5f5f5")
    static let backdrop = UIColor(hex: "#000000").colorWithAlphaComponent(0.4)
    
    static let red = UIColor(hex:"#ed5522")
    static let green = UIColor(hex:"#67d768")
    static let yellow = UIColor(hex:"#fed23b")
    static let brown = UIColor(hex:"#d7a678")
    static let blue = UIColor(hex:"#3498db")
    static let gray = UIColor(hex: "#757575")
    
    static func toggleColor() {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.IsDarkMode) as? Bool ?? false
      Constant.UserDefault.set(key: Constant.UserDefault.Key.IsDarkMode, val: !darkMode)
      
      button = Constant.Color.getColor(.Button)
      title = Constant.Color.getColor(.Title)
      border = Constant.Color.getColor(.Border)
      background = Constant.Color.getColor(.Background)
      statusBar = Constant.Color.getStatusBar()
      statusBarStyle = Constant.Color.getStatusBarStyle()
    }
    
    private static func getColor(item: Item) -> UIColor {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.IsDarkMode) as? Bool ?? false
      switch item {
      case .Button: return darkMode ? UIColor(hex:"#CB6724") : UIColor(hex:"#3498db")
      case .Title: return darkMode ? UIColor(hex: "#ffffff").colorWithAlphaComponent(1.0) : UIColor(hex: "#212121")
      case .Border: return darkMode ? UIColor(hex: "#787878").colorWithAlphaComponent(0.7) : UIColor(hex: "#cdcdcd")
      case .Background: return darkMode ? UIColor(hex: "#212121") : UIColor(hex: "#ffffff")
      }
    }
    
    private static func getStatusBar() -> UIBarStyle {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.IsDarkMode) as? Bool ?? false
      let barStyle: UIBarStyle = darkMode ? .BlackTranslucent : .Default
      
      return barStyle
    }
    
    private static func getStatusBarStyle() -> UIStatusBarStyle {
      let darkMode: Bool = Constant.UserDefault.get(key: Constant.UserDefault.Key.IsDarkMode) as? Bool ?? false
      let statusBarStyle: UIStatusBarStyle = darkMode ? .LightContent : .Default
      return statusBarStyle
    }
  }
}


// MARK: - font
extension Constant {
  struct Font {
    static let button: CGFloat = 17
    static let title: CGFloat = 14
    static let subtitle: CGFloat = 11
    static let caption: CGFloat = 8
  }
}

// MARK: - image
extension Constant {
  struct Image {
    static let user: UIImage = UIImage(named: "icon-user")!
    static let add: UIImage = UIImage(named: "icon-add")!
  }
}

// MARK: - buttons
extension Constant {
  struct Button {
    static let radius: CGFloat = 5
    static let height: CGFloat = 40
    static let padding: CGFloat = 10
    static let widthMultiplier: CGFloat = 0.4
    static func widthConstant(padding padding: CGFloat) -> CGFloat {
      return padding * -1.8 + 185
    }
    
    static func create(title title: String?, bold: Bool, small: Bool, background: Bool, shadow: Bool) -> UIButton {
      let button: UIButton = UIButton()
      button.tag = Int(!bold) // bold for cancel = 0
      button.layer.cornerRadius = radius
      button.clipsToBounds = true
      button.contentHorizontalAlignment = .Center
      button.setTitle(title, forState: .Normal)
      button.backgroundColor = background ? Constant.Color.button : Constant.Color.background
      button.tintColor = background ? Constant.Color.background : Constant.Color.button
      button.setTitleColor(background ? Constant.Color.background : Constant.Color.button, forState: .Normal)
      button.titleLabel?.font = bold ? .boldSystemFontOfSize(small ? Constant.Font.title :  Constant.Font.button) : .systemFontOfSize(small ? Constant.Font.title :  Constant.Font.button)
      button.translatesAutoresizingMaskIntoConstraints = false
      
      guard shadow else { return button }
      button.layer.shadowColor = Constant.Color.title.CGColor
      button.layer.shadowOffset = CGSizeMake(0, 2)
      button.layer.shadowOpacity = 0.2
      button.layer.shadowRadius = 2
      button.layer.masksToBounds = false
      return button
    }
  }
}


// MARK: - views
extension Constant {
  struct View {
    static func create() -> UIView {
      let view = UILabel()
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
    }
  }
}

// MARK: - labels
extension Constant {
  struct Label {
    static func create(title title: String?, primary: Bool, alignment: NSTextAlignment) -> UILabel {
      let label = UILabel()
      label.text = title
      label.textAlignment = alignment
      label.textColor = primary ? Constant.Color.title : Constant.Color.border
      label.font = primary ? .boldSystemFontOfSize(Constant.Font.title) : .boldSystemFontOfSize(Constant.Font.subtitle)
      label.numberOfLines = 0
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
    }
  }
}

// MARK: - Textview
extension Constant {
  struct TextView {
    static func create(title title: String?, primary: Bool, alignment: NSTextAlignment) -> UITextView {
      let textView = UITextView()
      textView.text = title
      textView.editable = false
      textView.textColor = primary ? Constant.Color.title : Constant.Color.border
      textView.font = primary ? .systemFontOfSize(Constant.Font.title) : .systemFontOfSize(Constant.Font.subtitle)
      textView.textAlignment = alignment
      textView.translatesAutoresizingMaskIntoConstraints = false
      
      return textView
    }
  }
}

// MARK: - ImageView
extension Constant {
  struct ImageView {
    static func create(image image: UIImage?) -> UIImageView {
      let imageView = UIImageView()
      imageView.contentMode = .ScaleAspectFit
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.image = image ?? Constant.Image.user
      
      let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
      imageView.addSubview(indicator)
      indicator.translatesAutoresizingMaskIntoConstraints = false
      var constraints = [NSLayoutConstraint]()
      constraints.append(NSLayoutConstraint(item: indicator, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Top, multiplier: 1, constant: 0))
      constraints.append(NSLayoutConstraint(item: indicator, attribute: .Bottom, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 0))
      constraints.append(NSLayoutConstraint(item: indicator, attribute: .Leading, relatedBy: .Equal, toItem: imageView, attribute: .Leading, multiplier: 1, constant: 0))
      constraints.append(NSLayoutConstraint(item: indicator, attribute: .Trailing, relatedBy: .Equal, toItem: imageView, attribute: .Trailing, multiplier: 1, constant: 0))
      NSLayoutConstraint.activateConstraints(constraints)
      
      return imageView
    }
  }
}


// MARK: - tableview
extension Constant {
  struct TableView {
    static func create() -> UITableView {
      let tableView = UITableView()
      
      // constants
      tableView.translatesAutoresizingMaskIntoConstraints = false
      
      // full length separator
      tableView.contentInset = UIEdgeInsetsZero
      tableView.separatorInset = UIEdgeInsetsZero
      tableView.scrollIndicatorInsets = UIEdgeInsetsZero
      tableView.layoutMargins = UIEdgeInsetsZero
      if #available(iOS 9.0, *) {
        tableView.cellLayoutMarginsFollowReadableWidth = false
      }
      
      // white background
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      
      // top line
      let px = 1 / UIScreen.mainScreen().scale
      let frame = CGRectMake(0, 0, tableView.frame.size.width, px)
      let line: UIView = UIView(frame: frame)
      line.backgroundColor = tableView.separatorColor
      tableView.tableHeaderView = line
      
      return tableView
    }
  }
}