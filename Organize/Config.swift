import UIKit

struct Config {
  static let appName: String = "Organize"
  static let appLoadingDelay: Double = 0.4
  
  static let colorButton = UIColor(hex:"#3498db")
  static let colorTitle =  UIColor(hex: "#212121")
  static let colorSubtitle = UIColor(hex: "#757575")
  static let colorBorder = UIColor(hex: "#cdcdcd")
  static let colorShadow = UIColor(hex: "#f5f5f5")
  static let colorBackground = UIColor(hex: "#ffffff")
  static let colorBackdrop = UIColor(hex: "#000000").colorWithAlphaComponent(0.4)
  static let colorStatusBar = UIBarStyle.Default
  
  static let colorRed = UIColor(hex:"#ed5522")
  static let colorGreen = UIColor(hex:"#67d768")
  static let colorYellow = UIColor(hex:"#fed23b")
  static let colorBrown = UIColor(hex:"#d7a678")
  
  //  static let colorButton = UIColor(hex:"#CB6724")
  //  static let colorBackground = UIColor(hex: "#212121")
  //  static let colorBorder = UIColor(hex: "#424242")
  //  static let colorTitle =  UIColor(hex: "#fafafa")
  //  static let colorSubtitle = UIColor(hex: "#757575")
  //  static let colorStatusBar = UIBarStyle.BlackTranslucent
}

enum UserDefaultKey:String {
  case AskedLocalNotification
}

