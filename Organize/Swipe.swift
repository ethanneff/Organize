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
  
  var animation: SwipeCell.Animation {
    switch self {
    case .Indent, .Unindent: return .Bounce
    default: return .Slide
    }
  }
  
  var color: UIColor {
    switch self {
    case .Complete: return Constant.Color.green
    case .Indent: return Constant.Color.brown
    case .Reminder: return Constant.Color.button
      
    case .Uncomplete: return Constant.Color.subtitle
    case .Unindent: return Constant.Color.brown
    case .Delete: return Constant.Color.red
    }
  }
  
  var position: SwipeCell.Position {
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
    return Util.imageViewWithColor(image: self.image, color: Constant.Color.background)
  }
}