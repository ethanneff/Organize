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

  func complete(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func uncomplete(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func delete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      if displayParent.collapsed {
        // note parent
        let noteParent = self.getNoteParent(displayParent: displayParent)
        
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
      self.remove(indexPath: indexPath, tableView: tableView)
      
      // sound
      Util.playSound(systemSound: .MailSent)
    }
  }
  
  func collapse(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // note parent
      let parent = self.display[indexPath.row]
      parent.collapsed = true
      
      // temp for background threading
      var temp = self.display
      var count = 0
      let next = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
      // while because removing
      while true {
        if next.row >= temp.count {
          break
        }
        let child = temp[next.row]
        if child.indent <= parent.indent {
          break
        }
        // note child
        temp.removeAtIndex(next.row)
        child.collapsed = true
        count += 1
        count += child.children
        
        // display child
        self.remove(indexPath: next, tableView: tableView)
      }
      // display parent
      parent.children = count
      self.reload(indexPath: indexPath, tableView: tableView)
    }
  }
  
  func uncollapse(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      displayParent.collapsed = false
      displayParent.children = 0
      self.reload(indexPath: indexPath, tableView: tableView)
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note children
      var children: [Note] = []
      for i in noteParent.index+1..<self.notes.count {
        let child = self.notes[i]
        if child.indent <= noteParent.note.indent {
          break
        }
        child.collapsed = false
        child.children = 0
        children.append(child)
      }
      
      // display children
      let next = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
      for child in children.reverse() {
        self.insert(indexPath: next, tableView: tableView, data: child)
      }
    }
  }
  
  func add(indexPath indexPath: NSIndexPath, tableView: UITableView, note: Note) {
    print(note)
  }
  
  // MARK: - PRIVATE HELPER METHODS
  private func indent(indexPath indexPath: NSIndexPath, tableView: UITableView, increase: Bool) {
    Util.threadBackground {
      // note parent
      let parent = self.display[indexPath.row]
      
      // find parent data
      if parent.collapsed {
        var realParentIndex = 0
        for i in 0..<self.notes.count {
          let child = self.notes[i]
          if child === parent {
            realParentIndex = i
            break
          }
        }
        let realParent = self.notes[realParentIndex]
        
        // note children
        for i in realParentIndex+1..<self.notes.count {
          let child = self.notes[i]
          if child.indent <= realParent.indent {
            break
          }
          child.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
        }
      }
      
      // display parent
      parent.indent += (increase) ? 1 : (parent.indent == 0) ? 0 : -1
      self.reload(indexPath: indexPath, tableView: tableView)
      
      // sound
      Util.playSound(systemSound: .SMSSent)
    }
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
    return (noteParentIndex, self.notes[noteParentIndex])
  }
  
  
  // MARK: - TABLEVIEW MODIFICATION
  private func remove(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadMain {
      self.display.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  private func reload(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadMain {
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  private func insert(indexPath indexPath: NSIndexPath, tableView: UITableView, data: Note) {
    Util.threadMain {
      self.display.insert(data, atIndex: indexPath.row)
      tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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