import UIKit

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

protocol Collapsable {
  var collapsed: Bool { get set }
  var children: Int { get set }
}

protocol Remindable {
  var reminder: Reminder? { get set }
}

class Note: NSObject, NSCoding, Copying, Nameable, Indentable, Completable, Collapsable, Remindable {
  // MARK: - PROPERTIES
  var title: String
  var body: String?
  var completed: Bool = false
  var collapsed: Bool = false
  var children: Int = 0
  var indent: Int = 0
  var reminder: Reminder?
  override var description: String {
    return "\(title) \(reminder)"
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
  
  convenience init(title: String, body: String?, completed: Bool, collapsed: Bool, children: Int, indent: Int, reminder: Reminder?) {
    self.init(title: title)
    self.body = body
    self.completed = completed
    self.collapsed = collapsed
    self.children = children
    self.indent = indent
    self.reminder = reminder
  }
  
  // MARK: - REMINDER
  func createReminder(controller controller: UIViewController, reminderType: ReminderType, date: NSDate?) {
    deleteReminder()
    reminder = Reminder(type: reminderType, date: date)
    LocalNotification.sharedInstance.create(controller: controller, body: title, action: nil, fireDate: date, soundName: nil, uid: reminder!.id, completion: nil)
  }
  
  func deleteReminder() {
    if let id = reminder?.id {
      LocalNotification.sharedInstance.delete(uid: id)
    }
    reminder = nil
  }
  
  // MARK: - COPY
  required init(original: Note) {
    title = original.title
    body = original.body
    completed = original.completed
    collapsed = original.collapsed
    children = original.children
    indent = original.indent
    reminder = original.reminder
  }
  
  // MARK: - SAVE
  struct PropertyKey {
    static let title: String = "title"
    static let body: String = "body"
    static let completed: String = "completed"
    static let collapsed: String = "collapsed"
    static let children: String = "children"
    static let indent: String = "indent"
    static let reminder: String = "reminder"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(body, forKey: PropertyKey.body)
    aCoder.encodeObject(completed, forKey: PropertyKey.completed)
    aCoder.encodeObject(collapsed, forKey: PropertyKey.collapsed)
    aCoder.encodeObject(children, forKey: PropertyKey.children)
    aCoder.encodeObject(indent, forKey: PropertyKey.indent)
    aCoder.encodeObject(reminder, forKey: PropertyKey.reminder)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    let body = aDecoder.decodeObjectForKey(PropertyKey.body) as? String
    let completed = aDecoder.decodeObjectForKey(PropertyKey.completed) as! Bool
    let collapsed = aDecoder.decodeObjectForKey(PropertyKey.collapsed) as! Bool
    let children = aDecoder.decodeObjectForKey(PropertyKey.children) as! Int
    let indent = aDecoder.decodeObjectForKey(PropertyKey.indent) as! Int
    let reminder = aDecoder.decodeObjectForKey(PropertyKey.reminder) as? Reminder
    self.init(title: title, body: body, completed: completed, collapsed: collapsed, children: children, indent: indent, reminder: reminder)
  }
}