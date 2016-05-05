import Foundation

class NotebookHistory: NSObject, NSCoding {
  // MARK: - PROPERTIES
  var notes: [Note] = []
  var display: [Note] = []
  
  // MARK: - INIT
  init(notes: [Note]) {
    self.notes = notes
  }
  
  convenience init(notes: [Note], display: [Note]) {
    self.init(notes: notes)
    self.display = display
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let notes = aDecoder.decodeObjectForKey(PropertyKey.notes) as! [Note]
    let display = aDecoder.decodeObjectForKey(PropertyKey.display) as! [Note]
    self.init(notes: notes, display: display)
  }
}

extension NotebookHistory {
  // MARK: - SAVE
  struct PropertyKey {
    static let notes = "notes"
    static let display = "display"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(notes, forKey: PropertyKey.notes)
    aCoder.encodeObject(display, forKey: PropertyKey.display)
  }
}