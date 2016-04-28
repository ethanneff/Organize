import UIKit

enum SwipeType: Int {
  case Complete
  case Uncomplete
  case Indent
  case Unindent
  case Reminder
  case Delete
  
  static var count: Int {
    return SwipeType.Delete.hashValue + 1
  }
  
  var animation: CellSwipe.Animation {
    switch self {
    case .Indent, .Unindent: return .Bounce
    default: return .Slide
    }
  }
  
  var color: UIColor {
    switch self {
    case .Complete: return Config.colorGreen
    case .Indent: return Config.colorBrown
    case .Reminder: return Config.colorButton
      
    case .Uncomplete: return Config.colorSubtitle
    case .Unindent: return Config.colorBrown
    case .Delete: return Config.colorRed
    }
  }
  
  var position: CellSwipe.Position {
    switch self {
    case .Complete: return .Left1
    case .Indent: return .Left2
    case .Reminder:return .Left3
      
    case .Uncomplete: return .Right1
    case .Unindent: return .Right2
    case .Delete: return .Right3
    }
  }
  
  var image: UIImage {
    switch self {
    case .Complete: return UIImage(named: "icon-check")!
    case .Indent: return UIImage(named: "icon-arrow-right")!
    case .Reminder: return UIImage(named: "icon-clock")!
      
    case .Uncomplete: return UIImage(named: "icon-close-small")!
    case .Unindent: return UIImage(named: "icon-arrow-left")!
    case .Delete: return UIImage(named: "icon-delete")!
    }
  }
  
  var icon: UIImageView {
    return Util.imageViewWithColor(image: self.image, color: Config.colorBackground)
  }
}