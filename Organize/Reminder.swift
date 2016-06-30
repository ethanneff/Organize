import UIKit

class Reminder: NSObject, NSCoding {
  // MARK: - PROPERTIES
  var id: String
  var uid: String
  var type: ReminderType
  var date: NSDate
  var created: NSDate
  var updated: NSDate
  
  override var description: String {
    return "\(uid) \(type) \(date)"
  }
  
  // MARK: - INIT
  init(uid: String, type: ReminderType, date: NSDate) {
    self.id = NSUUID().UUIDString
    self.uid = uid
    self.type = type
    self.date = date
    self.created = NSDate()
    self.updated = NSDate()
  }
  
  convenience init(id: String, uid: String, type: ReminderType, date: NSDate, created: NSDate, updated: NSDate) {
    self.init(uid: uid, type: type, date: date)
    self.id = id
    self.created = created
    self.updated = updated
  }
  
  convenience init(type: ReminderType, date: NSDate?) {
    let uid = NSUUID().UUIDString
    let date = type.date(date: date)
    
    self.init(uid: uid, type: type, date: date)
  }
  
  // MARK: - DEINIT
  deinit {
    LocalNotification.sharedInstance.delete(uid: uid)
  }
  
  // MARK: - SAVE
  struct PropertyKey {
    static let id: String = "id"
    static let uid: String = "uid"
    static let type: String = "type"
    static let date: String = "date"
    static let created: String = "created"
    static let updated: String = "updated"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(uid, forKey: PropertyKey.uid)
    aCoder.encodeObject(type.rawValue, forKey: PropertyKey.type)
    aCoder.encodeObject(date, forKey: PropertyKey.date)
    aCoder.encodeObject(created, forKey: PropertyKey.created)
    aCoder.encodeObject(updated, forKey: PropertyKey.updated)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let uid = aDecoder.decodeObjectForKey(PropertyKey.uid) as! String
    let type = ReminderType(rawValue: aDecoder.decodeObjectForKey(PropertyKey.type) as! Int)!
    let date = aDecoder.decodeObjectForKey(PropertyKey.date) as! NSDate
    let created = aDecoder.decodeObjectForKey(PropertyKey.created) as! NSDate
    let updated = aDecoder.decodeObjectForKey(PropertyKey.updated) as! NSDate
    
    self.init(id: id, uid: uid, type: type, date: date, created: created, updated: updated)
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
  
  func imageView(color color: UIColor) ->  UIImageView {
    return Util.imageViewWithColor(image: self.image, color: color)
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