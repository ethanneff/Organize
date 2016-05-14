import UIKit

class Notebook: NSObject, NSCoding, Copying {
  // MARK: - PROPERTIES
  var notes: [Note] = []
  var display: [Note] = []
  var history: [NotebookHistory] = []
  override var description: String {
    let output: String = notes.description + "\n" + display.description + "\n" // + "\n history \n"
    //    for element in history {
    //      output += element.notes.description + "\n" + element.display.description + "\n"
    //    }
    //
    return output
  }
  
  
  // MARK: - INIT
  init(notes: [Note]) {
    self.notes = notes
  }
  
  convenience init(notes: [Note], display: [Note], history: [NotebookHistory]) {
    self.init(notes: notes)
    self.display = display
    self.history = history
  }
  
  
  // MARK: - COPY
  required init(original: Notebook) {
    notes = original.notes
    display = original.display
    history = original.history
  }
  
  
  // MARK: - UNDO
  func undo(tableView tableView: UITableView) {
    historyLoad(tableView: tableView)
  }
  
  func historyClear() {
    Util.threadBackground {
      self.history.removeAll()
      Notebook.set(data: self)
    }
  }
  
  private func historySave() {
    // already on background thread
    while history.count >= 20 {
      history.removeFirst()
    }
    history.append(NotebookHistory(notes: self.notes.clone(), display: self.display.clone()))
  }
  
  private func historyLoad(tableView tableView: UITableView) {
    Util.threadBackground {
      if self.history.count > 0 {
        let undo = self.history.removeLast()
        self.notes = undo.notes
        self.display = undo.display
        Util.threadMain {
          tableView.reloadData()
        }
        Notebook.set(data: self)
      }
    }
  }
  
  
  
  // MARK: - CREATE
  func create(indexPath indexPath: NSIndexPath, tableView: UITableView, note: Note) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // note
      note.indent = indexPath.row == 0 ? 0 : self.display[indexPath.row-1].indent+1
      self.notes.insert(note, atIndex: indexPath.row)
      
      // display
      self.insert(indexPaths: [indexPath], tableView: tableView, data: [note]) {
        // save
        Notebook.set(data: self)
      }
    }
  }
  
  // MARK: - UPDATE
  func update(indexPath indexPath: NSIndexPath, tableView: UITableView, note: Note) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // display parent
      self.display[indexPath.row] = note
      self.reload(indexPaths: [indexPath], tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
    }
  }
  
  
  
  // MARK: - DELETE
  func delete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // history
      self.historySave()
      
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
    }
  }
  
  func deleteAll(tableView tableView: UITableView) {
    Util.threadBackground {
      // save
      self.historySave()
      
      // notes
      var index = 0
      while true {
        if index >= self.notes.count {
          break
        }
        let note = self.notes[index]
        if note.completed {
          self.notes.removeAtIndex(index)
          continue
        }
        index += 1
      }
    }
    
    // display
    var indexPaths: [NSIndexPath] = []
    for i in 0..<self.display.count {
      let display = self.display[i]
      if display.completed {
        let indexPath = NSIndexPath(forRow: i, inSection: 0)
        indexPaths.insert(indexPath, atIndex: 0)
      }
    }
    self.remove(indexPaths: indexPaths, tableView: tableView) {
      Notebook.set(data: self)
    }
  }
  
  
  // MARK: - INDENT
  func indent(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    self.indent(indexPath: indexPath, tableView: tableView, increase: true)
  }
  
  func unindent(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    self.indent(indexPath: indexPath, tableView: tableView, increase: false)
  }
  
  private func indent(indexPath indexPath: NSIndexPath, tableView: UITableView, increase: Bool) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // note parent
      if displayParent.collapsed {
        let noteParent = self.getNoteParent(displayParent: displayParent)
        
        // note children
        self.setNoteChild(noteParent: noteParent, indent: true, increase: increase, completed: nil)
      }
      
      // display parent
      displayParent.indent += (increase) ? 1 : (displayParent.indent == 0) ? 0 : -1
      self.reload(indexPaths: [indexPath], tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
    }
  }
  
  
  // MARK: - COMPLETE
  func complete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // display parent
      let displayParent = self.display[indexPath.row]
      
      if displayParent.completed {
        return
      }
      
      displayParent.completed = true
      displayParent.reminder = nil
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note child
      var noteChildIndex = self.notes.count
      for i in noteParent.index+1..<self.notes.count {
        let noteChild = self.notes[i]
        if noteChild.indent <= noteParent.note.indent {
          noteChildIndex = i
          break
        }
        noteChild.completed = true
        noteChild.reminder = nil
      }
      
      // note insert
      var noteInsertIndex = self.notes.count
      for i in noteParent.index..<self.notes.count {
        let noteInsert = self.notes[i]
        if noteInsert.indent < noteParent.note.indent {
          noteInsertIndex = i
          break
        }
      }
      
      // display insert
      var displayInsertIndex = self.display.count
      for i in indexPath.row..<self.display.count {
        let displayInsert = self.display[i]
        if displayInsert.indent < displayParent.indent {
          displayInsertIndex = i
          break
        }
      }
      
      // note relocate
      for _ in noteParent.index..<noteChildIndex {
        let note = self.notes.removeAtIndex(noteParent.index)
        self.notes.insert(note, atIndex: noteInsertIndex-1)
      }
      
      // display relocate
      var displayIndexPath = NSIndexPath(forRow: displayInsertIndex, inSection: indexPath.section)
      self.insert(indexPaths: [displayIndexPath], tableView: tableView, data: [displayParent]) {
        self.collapse(indexPath: indexPath, tableView: tableView) { children in
          self.remove(indexPaths: [indexPath], tableView: tableView) {
            displayIndexPath = NSIndexPath(forRow: displayInsertIndex-children-1, inSection: indexPath.section)
            self.reload(indexPaths: [displayIndexPath], tableView: tableView) {
              // save
              Notebook.set(data: self)
            }
          }
        }
      }
    }
  }
  
  func uncomplete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // display parent
      let displayParent = self.display[indexPath.row]
      
      if !displayParent.completed {
        return
      }
      
      displayParent.completed = false
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note child
      var noteChildIndex = self.notes.count
      for i in noteParent.index+1..<self.notes.count {
        let noteChild = self.notes[i]
        if noteChild.indent <= noteParent.note.indent {
          noteChildIndex = i
          break
        }
        noteChild.completed = false
      }
      
      // note insert
      var noteInsertIndex = 0
      for i in (0..<noteParent.index).reverse() {
        let noteInsert = self.notes[i]
        if noteInsert.indent < noteParent.note.indent {
          noteInsertIndex = i+1
          break
        }
      }
      
      // display insert
      var displayInsertIndex = 0
      for i in (0..<indexPath.row).reverse() {
        let displayInsert = self.display[i]
        if displayInsert.indent < displayParent.indent {
          displayInsertIndex = i+1
          break
        }
      }
      
      // note relocate
      var count = 0
      for _ in noteParent.index..<noteChildIndex {
        let note = self.notes.removeAtIndex(noteParent.index+count)
        self.notes.insert(note, atIndex: noteInsertIndex+count)
        count += 1
      }
      
      // display relocate
      self.collapse(indexPath: indexPath, tableView: tableView) { children in
        let displayIndexPath = NSIndexPath(forRow: displayInsertIndex, inSection: indexPath.section)
        self.insert(indexPaths: [displayIndexPath], tableView: tableView, data: [displayParent]) {
          let newIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
          self.remove(indexPaths: [newIndexPath], tableView: tableView) {
            self.uncollapse(indexPath: displayIndexPath, tableView: tableView) {
              // save
              Notebook.set(data: self)
            }
          }
        }
      }
    }
  }
  
  // MARK: - REORDER
  func reorderBeforeLift(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // collapse
      self.collapse(indexPath: indexPath, tableView: tableView) { children in
        // callback to prevent saving until after the reorder finishes
      }
    }
  }
  
  func reorderDuringMove(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    Util.threadBackground {
      // needed to prevent re-appearing of lifted cell after tableview scrolls out of focus
      swap(&self.display[fromIndexPath.row], &self.display[toIndexPath.row])
    }
  }
  
  
  
  func reorderAfterDrop(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // uncollapse
      self.uncollapse(indexPath: toIndexPath, tableView: tableView) {
        // display parent
        let displayParent = self.display[toIndexPath.row]
        
        // note parent
        let noteParent = self.getNoteParent(displayParent: displayParent)
        
        // note section
        var section: [Note] = []
        let parent = self.notes.removeAtIndex(noteParent.index)
        section.append(parent)
        while true {
          let next = noteParent.index
          if next >= self.notes.count {
            break
          }
          let child = self.notes[next]
          if child.indent <= noteParent.note.indent {
            break
          }
          // remove
          section.append(self.notes.removeAtIndex(next))
        }
        
        // insert
        func insert(section section: [Note], index: Int) {
          // insert and save
          self.notes.insertContentsOf(section, at: index)
          Notebook.set(data: self)
        }
        
        // insert section at start
        if toIndexPath.row == 0 {
          insert(section: section, index: 0)
          return
        }
        
        // insert section at end
        let displayPrev = self.display[toIndexPath.row-1]
        var notePrev = self.getNoteParent(displayParent: displayPrev)
        if notePrev.index+1 >= self.notes.count {
          insert(section: section, index: notePrev.index+1)
          return
        }
        
        // insert section at mid
        let next = notePrev.index+1
        if next > notePrev.note.indent {
          // find last child
          for i in next..<self.notes.count {
            let child = self.notes[i]
            if child.indent <= notePrev.note.indent {
              break
            }
            notePrev.index = i
          }
        }

        insert(section: section, index: notePrev.index+1)
      }
    }
  }
  
  
  // MARK: - COLLAPSE
  func collapse(indexPath indexPath: NSIndexPath, tableView: UITableView, completion: ((children: Int) -> ())? = nil) {
    Util.threadBackground {
      // history
      if let _ = completion {} else {
        // don't save on complete or reorder because more processing needs to happen first
        self.historySave()
      }
      
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // return if already collapsed
      if displayParent.collapsed {
        if let completion = completion {
          completion(children: 0)
        }
        return
      }
      
      let noteParent = self.getNoteParent(displayParent: displayParent)
      let next = noteParent.index+1
      if next >= self.notes.count {
        // return collapsing on last note
        return
      } else {
        // return if no children
        let child = self.notes[next]
        if child.indent <= noteParent.note.indent {
          return
        }
      }
      
      // collapse
      displayParent.collapsed = true
      
      // temp for background threading
      var temp = self.display
      var count = 0
      let nextIndexPath = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
      var children: [NSIndexPath] = []
      // while because removing
      while true {
        if nextIndexPath.row >= temp.count {
          break
        }
        let displayChild = temp[nextIndexPath.row]
        if displayChild.indent <= displayParent.indent {
          break
        }
        
        // display child
        temp.removeAtIndex(nextIndexPath.row)
        count += 1
        count += displayChild.children
        
        children.append(nextIndexPath)
      }
      
      // display child
      self.remove(indexPaths: children, tableView: tableView) {
        // display parent
        displayParent.children = count
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          if let completion = completion {
            // handle complete and reorder
            completion(children: count)
          } else {
            // save
            Notebook.set(data: self)
          }
        }
      }
    }
  }
  
  func uncollapse(indexPath indexPath: NSIndexPath, tableView: UITableView, completion: (() -> ())? = nil) {
    Util.threadBackground {
      // history
      if let _ = completion {} else {
        self.historySave()
      }
      
      // display parent
      let displayParent = self.display[indexPath.row]
      
      if !displayParent.collapsed {
        if let completion = completion {
          completion()
        }
        return
      }
      
      displayParent.collapsed = false
      displayParent.children = 0
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note children
      let noteChildren = self.setNoteChild(noteParent: noteParent, indent: nil, increase: nil, completed: nil)
      
      // display children
      var indexPaths: [NSIndexPath] = []
      var children: [Note] = []
      var parent: (found: Bool, indent: Int) = (false, 0)
      for child in noteChildren {
        // don't unindent sub collapsed sections
        if parent.found {
          if child.note.indent > parent.indent {
            continue
          } else {
            parent.found = false
          }
        }
        
        if child.note.collapsed {
          parent = (true, child.note.indent)
        }
        
        // add
        let next = NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section)
        indexPaths.append(next)
        children.append(child.note)
      }
      
      self.insert(indexPaths: indexPaths, tableView: tableView, data: children.reverse()) {
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          if let completion = completion {
            // handle uncomplete
            completion()
          } else {
            // save
            Notebook.set(data: self)
          }
        }
      }
    }
  }
  
  func collapseAll(tableView tableView: UITableView) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // notes
      if self.notes.count > 0 {
        for i in 0..<self.notes.count {
          let note = self.notes[i]
          // n^2 find children
          var children = 0
          for j in i+1..<self.notes.count {
            let child = self.notes[j]
            if child.indent <= note.indent {
              break
            }
            children += 1
          }
          note.children = children
          
          // collapse only if children
          let next = i+1
          if next < self.notes.count {
            let nextNote = self.notes[next]
            if nextNote.indent > note.indent {
              note.collapsed = true
            }
          }
        }
      }
      
      // display
      if self.display.count > 0 {
        var collapsePaths: [NSIndexPath] = []
        var reloadPaths: [NSIndexPath] = []
        var parent = self.display[0]
        var count = 0
        for i in 0..<self.display.count {
          let note = self.display[i]
          if note.indent > parent.indent {
            let indexPath = NSIndexPath(forRow: i-count, inSection: 0)
            collapsePaths.append(indexPath)
            count += 1
          } else {
            parent = note
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            reloadPaths.append(indexPath)
          }
        }
        
        // tableview
        self.reload(indexPaths: reloadPaths, tableView: tableView) {
          self.remove(indexPaths: collapsePaths, tableView: tableView) {
            // save
            Notebook.set(data: self)
          }
        }
      }
    }
  }
  
  func uncollapseAll(tableView tableView: UITableView) {
    Util.threadBackground {
      if self.notes.count > 0 {
        // history
        self.historySave()
        
        func updateNote(note note: Note) {
          note.collapsed = false
          note.children = 0
        }
        
        // notes
        var insert = 0
        var indexPaths: [NSIndexPath] = []
        var displayNotes: [Note] = []
        var reloadNotes: [NSIndexPath] = []
        for i in 0..<self.display.count {
          let displayParent = self.display[i]
          let noteParent = self.notes[i+insert]
          
          // update
          if displayParent.collapsed {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            reloadNotes.append(indexPath)
            updateNote(note: displayParent)
          }
          
          // match
          if displayParent === noteParent {
            continue
          }
          
          // mising
          var displacement = 0
          let indexPath = NSIndexPath(forRow: i+insert, inSection: 0)
          for j in i+insert..<self.notes.count {
            let noteParent = self.notes[j]
            if displayParent === noteParent {
              break
            }
            indexPaths.append(indexPath)
            displayNotes.insert(noteParent, atIndex: displayNotes.count-displacement)
            updateNote(note: noteParent)
            insert += 1
            displacement += 1
          }
        }
        
        // end
        if self.display.count + displayNotes.count < self.notes.count {
          for i in (0..<self.notes.count).reverse() {
            let noteParent = self.notes[i]
            if noteParent == self.display[self.display.count-1] {
              break
            }
            
            let indexPath = NSIndexPath(forRow: self.display.count+insert, inSection: 0)
            indexPaths.append(indexPath)
            displayNotes.append(noteParent)
            updateNote(note: noteParent)
          }
        }
        
        // display
        self.reload(indexPaths: reloadNotes, tableView: tableView) {
          self.insert(indexPaths: indexPaths, tableView: tableView, data: displayNotes) {
            // save
            Notebook.set(data: self)
          }
        }
      }
    }
  }
  
  // MARK: - REMINDER
  func reminder(indexPath indexPath: NSIndexPath?, controller: UIViewController, tableView: UITableView, reminderType: ReminderType, date: NSDate?, completion: (success: Bool, create: Bool) -> ()) {
    Util.threadBackground {
      guard let indexPath = indexPath else {
        return
      }
      
      // history
      self.historySave()
      
      
      func update(create create: Bool) {
        // display
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          // save
          Notebook.set(data: self)
          completion(success: true, create: create)
        }
      }
      
      // helper functions
      func create(note note: Note) {
        // delete and create reminder
        note.reminder = nil
        note.reminder = Reminder(type: reminderType, date: date)
        
        // create notification
        LocalNotification.sharedInstance.create(controller: controller, body: note.title, action: nil, fireDate: date, soundName: nil, uid: note.reminder!.id) { success in
          if success {
            update(create: true)
          } else {
            note.reminder = nil
            completion(success: success, create: true)
          }
        }
      }
      
      func delete(note note: Note) {
        // delete reminder and notification
        note.reminder = nil
        update(create: false)
      }
      
      // reminder
      let note = self.display[indexPath.row]
      if let reminder = note.reminder where reminderType == reminder.type {
        // has same reminder
        if reminderType != .Date {
          delete(note: note)
        } else {
          // remove same date
          if reminder.date == date {
            delete(note: note)
          } else {
            create(note: note)
          }
        }
      } else {
        // has no reminder
        create(note: note)
      }
    }
  }
  
  
  
  // MARK: - HELPER METHODS
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
  
  private func setNoteChild(noteParent noteParent: (note: Note, index: Int), indent: Bool? = nil, increase: Bool? = nil, completed: Bool? = nil) -> [(note: Note, index: Int)] {
    var noteChildren: [(note: Note, index: Int)] = []
    for i in noteParent.index+1..<self.notes.count {
      let noteChild = (note: self.notes[i], index: i)
      if noteChild.note.indent <= noteParent.note.indent {
        break
      }
      if let _ = indent, increase = increase {
        noteChild.note.indent += (increase) ? 1 : (noteParent.note.indent == 0) ? 0 : -1
      }
      if let completed = completed {
        noteChild.note.completed = completed
      }
      
      noteChildren.append(noteChild)
    }
    return noteChildren
  }
  
  
  // MARK: - TABLEVIEW AND DISPLAY MODIFICATION
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
  private struct PropertyKey {
    static let notes = "notes"
    static let display = "display"
    static let history = "history"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(notes, forKey: PropertyKey.notes)
    aCoder.encodeObject(display, forKey: PropertyKey.display)
    aCoder.encodeObject(history, forKey: PropertyKey.history)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let notes = aDecoder.decodeObjectForKey(PropertyKey.notes) as! [Note]
    let display = aDecoder.decodeObjectForKey(PropertyKey.display) as! [Note]
    let history = aDecoder.decodeObjectForKey(PropertyKey.history) as! [NotebookHistory]
    self.init(notes: notes, display: display, history: history)
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
  
  
  // MARK: - DEFAULT
  static func getDefault() -> Notebook {
    let notebook = Notebook(notes: [])
    notebook.notes.append(Note(title: "0", indent: 0))
    notebook.notes.append(Note(title: "1", indent: 1))
    notebook.notes.append(Note(title: "2", indent: 2))
    notebook.notes.append(Note(title: "3", indent: 1))
    notebook.notes.append(Note(title: "4", indent: 2))
    notebook.notes.append(Note(title: "5", indent: 3))
    notebook.notes.append(Note(title: "6", indent: 1))
    notebook.notes.append(Note(title: "7", indent: 0))
    notebook.notes.append(Note(title: "8", indent: 1))
    notebook.notes.append(Note(title: "9", indent: 1))
    notebook.notes.append(Note(title: "10", indent: 0))
    notebook.notes.append(Note(title: "11", indent: 1))
    notebook.notes.append(Note(title: "12", indent: 1))
    notebook.notes.append(Note(title: "13", indent: 2))
    notebook.notes.append(Note(title: "14", indent: 3))
    notebook.notes.append(Note(title: "15", indent: 4))
    notebook.notes.append(Note(title: "16", indent: 5))
    notebook.notes.append(Note(title: "17", indent: 6))
    notebook.notes.append(Note(title: "18", indent: 5))
    notebook.notes.append(Note(title: "19", indent: 4))
    
    // copy the references to display view
    notebook.display = notebook.notes
    notebook.history.removeAll()
    return notebook
  }
}


