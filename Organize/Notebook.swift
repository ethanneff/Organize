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
  func indent(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func unindent(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func complete(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func uncomplete(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    
    return []
  }
  
  func delete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // search children
      let parent = self.display[indexPath.row]
      
      if parent.collapsed {
        // find parent data
        var realParentIndex = 0
        for i in 0..<self.notes.count {
          let child = self.notes[i]
          if child === parent {
            realParentIndex = i
            break
          }
        }
        let realParent = self.notes[realParentIndex]
        
        // remove children from real
        while true {
          if realParentIndex+1 >= self.notes.count {
            break
          }
          
          let realChild = self.notes[realParentIndex+1]
          if realChild.indent <= realParent.indent {
            break
          }
          self.notes.removeAtIndex(realParentIndex+1)
        }
      }
      
      // remove parent from real
      self.notes.removeAtIndex(indexPath.row)
      
      // remove parent from display
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
      var realParentIndex = 0
      for i in 0..<self.notes.count {
        let child = self.notes[i]
        if child === displayParent {
          realParentIndex = i
          break
        }
      }
      let realParent = self.notes[realParentIndex]
      
      // note children
      var children: [Note] = []
      for i in realParentIndex+1..<self.notes.count {
        let child = self.notes[i]
        if child.indent <= realParent.indent {
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
  
  
  // MARK: PRIVATE METHODS
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