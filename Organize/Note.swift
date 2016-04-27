import Foundation


protocol Nameable {
  var title: String { get set }
  var body: String { get set }
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

class Note: Nameable, Indentable, Completable, Remindable {
  var title: String
  var body: String
  var completed: Bool = false
  var indent: Int = 0
  var reminderType: ReminderType = .None
  var reminderDate: NSDate?
  
  init(title: String, body: String) {
    self.title = title
    self.body = body
  }
}