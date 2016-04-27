import UIKit

enum ReminderType:Int {
  case Later
  case Evening
  case Tomorrow
  case Weekend
  case Week
  case Month
  case Someday
  case None
  case Date
  
  var increment: NSDate? {
    switch self {
    case .Later: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Evening: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Tomorrow: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Weekend: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Week: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Month: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .Someday: return NSDate().dateByAddingTimeInterval(60*60*2)
    case .None: return nil
    case .Date: return NSDate().dateByAddingTimeInterval(60*60*2)
    }
  }
  
  var title: String {
    switch self {
    case .Later: return "Later Today"
    case .Evening: return "This Evening"
    case .Tomorrow: return "Tomorrow"
    case .Weekend: return "This Weekend"
    case .Week: return "Next Week"
    case .Month: return "In a Month"
    case .Someday: return "Someday"
    case .None: return "Cancel"
    case .Date: return "Pick Date"
    }
  }
  
  var image: UIImage {
    switch self {
    case .Later: return UIImage(named: "appbar.clock")!
    case .Evening: return UIImage(named: "appbar.moon")!
    case .Tomorrow: return UIImage(named: "appbar.cup")!
    case .Weekend: return UIImage(named: "appbar.weather.sun")!
    case .Week: return UIImage(named: "appbar.cabinet.files")!
    case .Month: return UIImage(named: "appbar.calendar")!
    case .Someday: return UIImage(named: "appbar.weather.rain")!
    case .None: return UIImage(named: "appbar.close")!
    case .Date: return UIImage(named: "appbar.list")!
    }
  }
  
  var imageView: UIImageView  {
    let imageView = UIImageView(image: self.image)
    imageView.image = imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
    return imageView
  }
}