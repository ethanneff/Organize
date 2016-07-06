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

protocol Boldable {
  var bolded: Bool { get set }
}

class Note: NSObject, NSCoding, Copying, Nameable, Indentable, Completable, Collapsable, Remindable, Boldable {
  // MARK: - PROPERTIES
  var id: String
  var title: String
  var body: String?
  var bolded: Bool
  var completed: Bool
  var collapsed: Bool
  var children: Int
  var indent: Int
  var reminder: Reminder?
  var created: NSDate
  var updated: NSDate
  override var description: String {
    return "\(title)"
  }
  
  // MARK: - INIT
  init(title: String) {
    self.title = title
    self.id = NSUUID().UUIDString
    self.bolded = false
    self.completed = false
    self.collapsed = false
    self.children = 0
    self.indent = 0
    self.created = NSDate()
    self.updated = NSDate()
  }
  
  convenience init(title: String, body: String?) {
    self.init(title: title)
    self.body = body
  }
  
  convenience init(title: String, indent: Int) {
    self.init(title: title)
    self.indent = indent
  }
  
  convenience init(title: String, indent: Int, bolded: Bool) {
    self.init(title: title)
    self.indent = indent
    self.bolded = bolded
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
  
  convenience init(id: String, title: String, body: String?, bolded: Bool, completed: Bool, collapsed: Bool, children: Int, indent: Int, reminder: Reminder?, created: NSDate, updated: NSDate) {
    self.init(title: title)
    self.id = id
    self.body = body
    self.bolded = bolded
    self.completed = completed
    self.collapsed = collapsed
    self.children = children
    self.indent = indent
    self.reminder = reminder
    self.created = created
    self.updated = updated
  }
  
  // MARK: - COPY
  required init(original: Note) {
    id = original.id
    title = original.title
    body = original.body
    bolded = original.bolded
    completed = original.completed
    collapsed = original.collapsed
    children = original.children
    indent = original.indent
    reminder = original.reminder
    created = original.created
    updated = original.updated
  }
  
  // MARK: - SAVE
  struct PropertyKey {
    static let id: String = "id"
    static let title: String = "title"
    static let body: String = "body"
    static let bolded: String = "bolded"
    static let completed: String = "completed"
    static let collapsed: String = "collapsed"
    static let children: String = "children"
    static let indent: String = "indent"
    static let reminder: String = "reminder"
    static let created: String = "created"
    static let updated: String = "updated"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(body, forKey: PropertyKey.body)
    aCoder.encodeObject(bolded, forKey: PropertyKey.bolded)
    aCoder.encodeObject(completed, forKey: PropertyKey.completed)
    aCoder.encodeObject(collapsed, forKey: PropertyKey.collapsed)
    aCoder.encodeObject(children, forKey: PropertyKey.children)
    aCoder.encodeObject(indent, forKey: PropertyKey.indent)
    aCoder.encodeObject(reminder, forKey: PropertyKey.reminder)
    aCoder.encodeObject(created, forKey: PropertyKey.created)
    aCoder.encodeObject(updated, forKey: PropertyKey.updated)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    let body = aDecoder.decodeObjectForKey(PropertyKey.body) as? String
    let bolded = aDecoder.decodeObjectForKey(PropertyKey.bolded) as! Bool
    let completed = aDecoder.decodeObjectForKey(PropertyKey.completed) as! Bool
    let collapsed = aDecoder.decodeObjectForKey(PropertyKey.collapsed) as! Bool
    let children = aDecoder.decodeObjectForKey(PropertyKey.children) as! Int
    let indent = aDecoder.decodeObjectForKey(PropertyKey.indent) as! Int
    let reminder = aDecoder.decodeObjectForKey(PropertyKey.reminder) as? Reminder
    let created = aDecoder.decodeObjectForKey(PropertyKey.created) as! NSDate
    let updated = aDecoder.decodeObjectForKey(PropertyKey.updated) as! NSDate
    self.init(id: id, title: title, body: body, bolded: bolded, completed: completed, collapsed: collapsed, children: children, indent: indent, reminder: reminder, created: created, updated: updated)
  }
}