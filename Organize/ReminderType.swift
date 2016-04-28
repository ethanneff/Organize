import UIKit

enum ReminderType: Int {
  case None
  case Later
  case Evening
  case Tomorrow
  case Weekend
  case Week
  case Month
  case Someday
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
    case .Later: return UIImage(named: "icon-clock")!
    case .Evening: return UIImage(named: "icon-moon")!
    case .Tomorrow: return UIImage(named: "icon-cup")!
    case .Weekend: return UIImage(named: "icon-weather-sun")!
    case .Week: return UIImage(named: "icon-cabinet-files")!
    case .Month: return UIImage(named: "icon-calendar")!
    case .Someday: return UIImage(named: "icon-weather-rain")!
    case .None: return UIImage(named: "icon-close-small")!
    case .Date: return UIImage(named: "icon-list")!
    }
  }
  
  var imageView: UIImageView  {
    let imageView = UIImageView(image: self.image)
    imageView.image = imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
    return imageView
  }
}