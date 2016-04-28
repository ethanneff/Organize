import Foundation


protocol Nameable {
  var title: String { get set }
  var body: String? { get set }
}

protocol Indentable {
  var indent: Int { get set }
}

protocol Completable {
  var completed: Bool { get set }
}

protocol Remindable {
  var reminderType: ReminderType { get set }
  var reminderDate: NSDate? { get set }
}

class Note: NSObject, NSCoding, Nameable, Indentable, Completable, Remindable {
  // MARK: - PROPERTIES
  var title: String
  var body: String?
  var completed: Bool = false
  var indent: Int = 0
  var reminderType: ReminderType = .None
  var reminderDate: NSDate?
  override var description: String {
    return "\(title)"
  }
  
  // MARK: - INIT
  init(title: String) {
    self.title = title
  }
  
  convenience init(title: String, body: String?) {
    self.init(title: title)
    self.body = body
  }
  
  convenience init(title: String, indent: Int) {
    self.init(title: title)
    self.indent = indent
  }
  
  convenience init(title: String, body: String?, indent: Int) {
    self.init(title: title, body: body)
    self.indent = indent
  }
  
  convenience init(title: String, body: String?, completed: Bool, indent: Int) {
    self.init(title: title, body: body, indent: indent)
    self.completed = completed
  }
  
  convenience init(title: String, body: String?, completed: Bool, indent: Int, reminderType: ReminderType, reminderDate: NSDate?) {
    self.init(title: title)
    self.body = body
    self.completed = completed
    self.indent = indent
    self.reminderType = reminderType
    self.reminderDate = reminderDate
  }
  
  // MARK: - SAVE
  struct PropertyKey {
    static let title: String = "title"
    static let body: String = "body"
    static let completed: String = "completed"
    static let indent: String = "indent"
    static let reminderType: String = "reminderType"
    static let reminderDate: String = "reminderDate"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(body, forKey: PropertyKey.body)
    aCoder.encodeObject(completed, forKey: PropertyKey.completed)
    aCoder.encodeObject(indent, forKey: PropertyKey.indent)
    aCoder.encodeObject(reminderType.rawValue, forKey: PropertyKey.reminderType)
    aCoder.encodeObject(reminderDate, forKey: PropertyKey.reminderDate)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    let body = aDecoder.decodeObjectForKey(PropertyKey.body) as? String
    let completed = aDecoder.decodeObjectForKey(PropertyKey.completed) as! Bool
    let indent = aDecoder.decodeObjectForKey(PropertyKey.indent) as! Int
    let reminderType = ReminderType(rawValue: aDecoder.decodeObjectForKey(PropertyKey.reminderType) as! Int)!
    let reminderDate = aDecoder.decodeObjectForKey(PropertyKey.reminderDate) as? NSDate
    self.init(title: title, body: body, completed: completed, indent: indent, reminderType: reminderType, reminderDate: reminderDate)
  }
}