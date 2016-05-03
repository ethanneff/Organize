import UIKit

class Notebook: NSObject, NSCoding {
  // MARK: - PROPERTIES
  var notes: [Note] = []
  var display: [Note] = []
  override var description: String {
    return notes.description + "\n" + display.description
  }
  
  
  // MARK: - INIT
  init(notes: [Note]) {
    self.notes = notes
  }
  
  convenience init(notes: [Note], display: [Note]) {
    self.init(notes: notes)
    self.display = display
  }
  
  // MARK: - PUBLIC METHODS
  func indent(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    self.indent(indexPath: indexPath, tableView: tableView, increase: true)
  }
  
  func unindent(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    self.indent(indexPath: indexPath, tableView: tableView, increase: false)
  }
  
  func complete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      displayParent.completed = true
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note child
      var noteChild = (note: noteParent.note, index: noteParent.index)
      for i in noteParent.index+1..<self.notes.count {
        noteChild = (note: self.notes[i], index: i)
        if noteChild.note.indent <= noteParent.note.indent {
          break
        }
        noteChild.note.completed = true
      }
      
      // note insert
      var noteInsert = (note: noteParent.note, index: noteParent.index)
      for i in noteParent.index+1..<self.notes.count {
        noteInsert = (note: self.notes[i], index: i)
        if noteInsert.note.indent < noteParent.note.indent {
          break
        }
      }
      
      // display insert
      var displayInsert = (note: displayParent, index: indexPath.row)
      for i in indexPath.row+1..<self.display.count {
        displayInsert = (note: self.display[i], index: i)
        if displayInsert.note.indent < displayInsert.note.indent {
          break
        }
      }
      
      print(displayInsert)
      
      // note relocate
      for _ in noteParent.index..<noteChild.index {
        let note = self.notes.removeAtIndex(noteParent.index)
        self.notes.insert(note, atIndex: noteInsert.index)
      }
      
      // display relocate
      let displayIndexPath = NSIndexPath(forRow: displayInsert.index+1, inSection: indexPath.section)
      self.insert(indexPaths: [displayIndexPath], tableView: tableView, data: [displayParent])
      
      // display collapse
      self.collapse(indexPath: indexPath, tableView: tableView)
      
      // display remove
      self.remove(indexPaths: [indexPath], tableView: tableView)
      
      self.reload(indexPaths: [indexPath], tableView: tableView)
      
      Util.playSound(systemSound: .MailSent)
    }
  }
  
  func uncomplete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      displayParent.completed = false
      self.reload(indexPaths: [indexPath], tableView: tableView)
      
    }
  }
  
  func delete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      if displayParent.collapsed {
        // note parent
        let noteParent = self.getNoteParent(displayParent: displayParent)
        
        // while because removing
        while true {
          let next = noteParent.index+1
          if next >= self.notes.count {
            break
          }
          
          // note child
          let noteChild = self.notes[next]
          if noteChild.indent <= noteParent.note.indent {
            break
          }
          self.notes.removeAtIndex(next)
        }
      }
      
      // note parent
      self.notes.removeAtIndex(indexPath.row)
      
      // display parent
      self.remove(indexPaths: [indexPath], tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
      
      // sound
      Util.playSound(systemSound: .MailSent)
    }
  }
  
  func collapse(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      displayParent.collapsed = true
      
      // temp for background threading
      var temp = self.display
      var count = 0
      let next = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
      var children: [NSIndexPath] = []
      // while because removing
      while true {
        if next.row >= temp.count {
          break
        }
        let displayChild = temp[next.row]
        if displayChild.indent <= displayParent.indent {
          break
        }
        
        // display child
        temp.removeAtIndex(next.row)
        displayChild.collapsed = true
        count += 1
        count += displayChild.children
        
        children.append(next)
      }
      
      // display child
      self.remove(indexPaths: children, tableView: tableView) {
        // display parent
        displayParent.children = count
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          // save
          Notebook.set(data: self)
        }
      }
    }
  }
  
  func uncollapse(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      displayParent.collapsed = false
      displayParent.children = 0
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note children
      let noteChildren = self.setNoteChild(noteParent: noteParent, indent: nil, increase: nil, collapsed: false, children: 0)
      
      // display children
      var indexPaths: [NSIndexPath] = []
      var children: [Note] = []
      for child in noteChildren.reverse() {
        let next = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
        indexPaths.append(next)
        children.append(child.note)
      }
      
      self.insert(indexPaths: indexPaths, tableView: tableView, data: children) {
        // save
        Notebook.set(data: self)
      }
    }
    
    
    self.reload(indexPaths: [indexPath], tableView: tableView)
  }
  
  func add(indexPath indexPath: NSIndexPath, tableView: UITableView, note: Note) {
    print(note)
  }
  
  // MARK: - PRIVATE HELPER METHODS
  private func indent(indexPath indexPath: NSIndexPath, tableView: UITableView, increase: Bool) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // note parent
      if displayParent.collapsed {
        let noteParent = self.getNoteParent(displayParent: displayParent)
        
        // note children
        self.setNoteChild(noteParent: noteParent, indent: true, increase: increase, collapsed: nil, children: nil)
      }
      
      // display parent
      displayParent.indent += (increase) ? 1 : (displayParent.indent == 0) ? 0 : -1
      self.reload(indexPaths: [indexPath], tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
      
      // sound
      Util.playSound(systemSound: .SMSSent)
    }
  }
  
  private func setNoteChild(noteParent noteParent: (note: Note, index: Int), indent: Bool?, increase: Bool?, collapsed: Bool?, children: Int?) -> [(note: Note, index: Int)] {
    var noteChildren: [(note: Note, index: Int)] = []
    for i in noteParent.index+1..<self.notes.count {
      let noteChild = (note: self.notes[i], index: i)
      if noteChild.note.indent <= noteParent.note.indent {
        break
      }
      if let _ = indent, increase = increase {
        noteChild.note.indent += (increase) ? 1 : (noteParent.note.indent == 0) ? 0 : -1
      }
      if let collapsed = collapsed {
        noteChild.note.collapsed = collapsed
      }
      if let children = children {
        noteChild.note.children = children
      }
      
      noteChildren.append(noteChild)
    }
    return noteChildren
  }
  
  private func getNoteParent(displayParent displayParent: Note) -> (index: Int, note: Note) {
    var noteParentIndex = 0
    for i in 0..<self.notes.count {
      let child = self.notes[i]
      if child === displayParent {
        noteParentIndex = i
        break
      }
    }
    return (index: noteParentIndex, note: self.notes[noteParentIndex])
  }
  
  
  // MARK: - TABLEVIEW + DISPLAY MODIFICATION
  private func remove(indexPaths indexPaths: [NSIndexPath], tableView: UITableView, completion: (() -> ())? = nil) {
    Util.threadMain {
      for indexPath in indexPaths {
        self.display.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      }
      if let completion = completion {
        completion()
      }
    }
  }
  
  private func reload(indexPaths indexPaths: [NSIndexPath], tableView: UITableView, completion: (() -> ())? = nil) {
    Util.threadMain {
      for indexPath in indexPaths {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      }
      if let completion = completion {
        completion()
      }
    }
  }
  
  private func insert(indexPaths indexPaths: [NSIndexPath], tableView: UITableView, data: [Note], completion: (() -> ())? = nil) {
    Util.threadMain {
      for i in 0..<indexPaths.count {
        self.display.insert(data[i], atIndex: indexPaths[i].row)
        tableView.insertRowsAtIndexPaths([indexPaths[i]], withRowAnimation: .Fade)
      }
      if let completion = completion {
        completion()
      }
    }
  }
  
  
  // MARK: - SAVE
  struct PropertyKey {
    static let notes = "notes"
    static let display = "display"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(notes, forKey: PropertyKey.notes)
    aCoder.encodeObject(display, forKey: PropertyKey.display)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let notes = aDecoder.decodeObjectForKey(PropertyKey.notes) as! [Note]
    let display = aDecoder.decodeObjectForKey(PropertyKey.display) as! [Note]
    self.init(notes: notes, display: display)
  }
  
  // MARK: - ACCESS
  // TODO: move into own class... get (filename), set (filename, data), list of file (users -> notebooks -> notes)
  // TODO: saved based on notebook-timestamp
  // TODO: figure out how to save between threads (after the last one)
  static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("notebook")
  
  static func get(completion completion: (notebook: Notebook?) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(Notebook.ArchiveURL.path!) as? Notebook {
        completion(notebook: data)
      } else {
        completion(notebook: nil)
      }
    })
  }
  
  static func set(data data: Notebook, completion: ((success: Bool) -> ())? = nil) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: Notebook.ArchiveURL.path!)
      if !isSuccessfulSave {
        if let completion = completion {
          completion(success: false)
        }
      } else {
        if let completion = completion {
          completion(success: true)
        }
      }
    })
  }
  
  static func getDefault() -> Notebook {
    let notebook = Notebook(notes: [])
    notebook.notes.append(Note(title: "0", indent: 0))
    notebook.notes.append(Note(title: "1", indent: 1))
    notebook.notes.append(Note(title: "2", indent: 1))
    notebook.notes.append(Note(title: "3", indent: 2))
    notebook.notes.append(Note(title: "4", indent: 3))
    notebook.notes.append(Note(title: "5", indent: 0))
    notebook.notes.append(Note(title: "6", indent: 1))
    notebook.notes.append(Note(title: "7", indent: 2))
    notebook.notes.append(Note(title: "8", indent: 2))
    notebook.notes.append(Note(title: "9", indent: 0))
    notebook.notes.append(Note(title: "10", indent: 0))
    notebook.notes.append(Note(title: "11", indent: 1))
    notebook.notes.append(Note(title: "12", indent: 1))
    notebook.notes.append(Note(title: "13", indent: 2))
    notebook.notes.append(Note(title: "14", indent: 3))
    notebook.notes.append(Note(title: "15", indent: 0))
    notebook.notes.append(Note(title: "16", indent: 1))
    notebook.notes.append(Note(title: "17", indent: 2))
    notebook.notes.append(Note(title: "18", indent: 2))
    notebook.notes.append(Note(title: "19", indent: 0))
    
    // copy the references to display view
    notebook.display = notebook.notes
    return notebook
  }
}