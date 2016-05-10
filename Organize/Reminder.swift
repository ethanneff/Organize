import UIKit

class Reminder: NSObject, NSCoding {
  // MARK: - PROPERTIES
  let id: Int
  var type: ReminderType
  var date: NSDate
  
  override var description: String {
    return "\(id) \(type) \(date)"
  }
  
  // MARK: - INIT
  init(id: Int, type: ReminderType, date: NSDate) {
    self.id = id
    self.type = type
    self.date = date
  }
  
  convenience init(type: ReminderType, date: NSDate?) {
    let id = Int(NSDate().timeIntervalSince1970 * 100000)
    let date = type.date(date: date)
    
    self.init(id: id, type: type, date: date)
  }
  
  
  // MARK: - SAVE
  struct PropertyKey {
    static let id: String = "id"
    static let type: String = "type"
    static let date: String = "date"
    
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(type.rawValue, forKey: PropertyKey.type)
    aCoder.encodeObject(date, forKey: PropertyKey.date)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! Int
    let type = ReminderType(rawValue: aDecoder.decodeObjectForKey(PropertyKey.type) as! Int)!
    let date = aDecoder.decodeObjectForKey(PropertyKey.date) as! NSDate
    
    self.init(id: id, type: type, date: date)
  }
}

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
  
  var imageView: UIImageView {
    return Util.imageViewWithColor(image: self.image, color: Config.colorButton)
  }
  
  func date(date date: NSDate?) -> NSDate {
    // configurable hours
    let paramLater: Double = 2
    let paramMorning: Double = 24 + 8
    let paramEvening: Double = 12 + 6
    // -1 day because working off tomorrow morning's value
    let paramWeek: Double = 6
    let paramMonth: Double = 29
    let paramSomeday: Double = 59
    
    let now: NSDate = NSDate()
    let today: NSDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    let dayOfWeek: Double = Double(NSCalendar.currentCalendar().components(.Weekday, fromDate: today).weekday)
    
    // 2 hours
    let later = now.dateByAddingTimeInterval(60*60*(paramLater))
    
    // at 6pm or 2 hours from now if already after 6pm
    let evening = now.compare(today.dateByAddingTimeInterval(60*60*(paramEvening))) == .OrderedDescending ? later : today.dateByAddingTimeInterval(60*60*(paramEvening))
    
    // 8am tomorrow
    let tomorrow = today.dateByAddingTimeInterval(60*60*(paramMorning))
    
    // saturday at 8am or 2hours if already on weekend
    let weekend = (dayOfWeek == 7 || dayOfWeek == 1) ? later : tomorrow.dateByAddingTimeInterval(60*60*24*(6-dayOfWeek))
    
    // 7 days from now or monday if weekend
    let week = tomorrow.dateByAddingTimeInterval(60*60*24*(paramWeek))
    
    // 30 days
    let month = tomorrow.dateByAddingTimeInterval(60*60*24*(paramMonth))
    
    // 60 days
    let someday = tomorrow.dateByAddingTimeInterval(60*60*24*(paramSomeday))
    
    switch self {
    case .Later: return later
    case .Evening: return evening
    case .Tomorrow: return tomorrow
    case .Weekend: return weekend
    case .Week: return week
    case .Month: return month
    case .Someday: return someday
    case .None: return now
    case .Date: return date ?? now
    }
  }
}