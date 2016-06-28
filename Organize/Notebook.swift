import UIKit

class Notebook: NSObject, NSCoding, Copying {
  // MARK: - PROPERTIES
  var title: String = "Organize" {
    didSet {
      updated = NSDate()
      Notebook.set(data: self)
    }
  }
  var id: String
  var notes: [Note] = []
  var display: [Note] = []
  var created: NSDate
  var updated: NSDate
  private var history: [NotebookHistory] = []
  override var description: String {
    var output: String = notes.description + "\n" + display.description
    output += "\n"
    //    output += " history \n"
    //    for element in history {
    //      output += element.notes.description + "\n" + element.display.description + "\n"
    //    }
    return output
  }
  
  // MARK: - INIT
  init(notes: [Note]) {
    self.notes = notes
    self.id = NSUUID().UUIDString
    self.created = NSDate()
    self.updated = NSDate()
  }
  
  convenience init(title: String) {
    self.init(notes: [])
    self.title = title
    self.display = []
    self.history = []
  }
  
  convenience init(title: String, notes: [Note], display: [Note], history: [NotebookHistory]) {
    self.init(notes: notes)
    self.title = title
    self.display = display
    self.history = history
  }
  
  convenience init(id: String, title: String, notes: [Note], display: [Note], history: [NotebookHistory], created: NSDate, updated: NSDate) {
    self.init(notes: notes)
    self.id = id
    self.title = title
    self.display = display
    self.history = history
    self.created = created
    self.updated = updated
  }
  
  // MARK: - COPY
  required init(original: Notebook) {
    id = original.id
    notes = original.notes
    display = original.display
    history = original.history
    created = original.created
    updated = original.updated
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
    // TODO: turn on v3
    //    while history.count >= 20 {
    //      history.removeFirst()
    //    }
    //    history.append(NotebookHistory(notes: self.notes.clone(), display: self.display.clone()))
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
        
        let indexPaths = self.updateBolded(indexPath: indexPath)
        self.reload(indexPaths: indexPaths, tableView: tableView) {
          // save
          Notebook.set(data: self)
          Report.sharedInstance.track(event: "note_create")
        }
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
        Report.sharedInstance.track(event: "note_update")
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
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      if noteParent.note.collapsed {
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
          
          // remove
          noteChild.updated = NSDate()
          self.reminderDelete(note: self.notes[next])
          self.notes.removeAtIndex(next)
        }
      }
      
      // note parent
      self.reminderDelete(note: noteParent.note)
      self.notes.removeAtIndex(noteParent.index)
      
      // display parent
      self.remove(indexPaths: [indexPath], tableView: tableView) {
        let indexPaths = self.updateBolded(indexPath: indexPath)
        self.reload(indexPaths: indexPaths, tableView: tableView) {
          // save
          Notebook.set(data: self)
          Report.sharedInstance.track(event: "note_delete")
        }
      }
    }
  }
  
  func deleteCompleted(tableView tableView: UITableView) {
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
          note.updated = NSDate()
          self.reminderDelete(note: self.notes[index])
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
    
    // remove
    self.remove(indexPaths: indexPaths, tableView: tableView) {
      let indexPaths = self.correctBoldedAndCollapsed()
      self.reload(indexPaths: indexPaths, tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
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
      // display parent (selected row)
      var indexPaths: [NSIndexPath] = [indexPath]
      let displayParent = self.display[indexPath.row]
      
      // early exit
      if !increase && displayParent.indent == 0 {
        return
      }
      
      // history
      self.historySave()
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      
      // note children
      if noteParent.note.collapsed {
        self.setNoteChild(noteParent: noteParent, indent: true, increase: increase, completed: nil)
      }
      
      // display parent
      noteParent.note.indent += (increase) ? 1 : (noteParent.note.indent == 0) ? 0 : -1
      indexPaths += self.updateBolded(indexPath: indexPath)
      self.reload(indexPaths: indexPaths, tableView: tableView) {
        // save
        Notebook.set(data: self)
      }
    }
  }
  
  // MARK: - COMPLETE
  func complete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // early exit
      if displayParent.completed {
        return
      }
      
      // history
      self.historySave()
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      noteParent.note.completed = true
      self.reminderDelete(note: noteParent.note)
      
      // note child
      var noteChildIndex = self.notes.count
      for i in noteParent.index+1..<self.notes.count {
        let noteChild = self.notes[i]
        if noteChild.indent <= noteParent.note.indent {
          noteChildIndex = i
          break
        }
        noteChild.completed = true
        noteChild.updated = NSDate()
        self.reminderDelete(note: noteChild)
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
              Report.sharedInstance.track(event: "note_complete")
            }
          }
        }
      }
    }
  }
  
  func uncomplete(indexPath indexPath: NSIndexPath, tableView: UITableView) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // early exit
      if !displayParent.completed {
        return
      }
      
      // history
      self.historySave()
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      noteParent.note.completed = false
      
      // note child
      var noteChildIndex = self.notes.count
      for i in noteParent.index+1..<self.notes.count {
        let noteChild = self.notes[i]
        if noteChild.indent <= noteParent.note.indent {
          noteChildIndex = i
          break
        }
        noteChild.completed = false
        noteChild.collapsed = false
        noteChild.children = 0
        noteChild.updated = NSDate()
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
              Report.sharedInstance.track(event: "note_uncomplete")
            }
          }
        }
      }
    }
  }
  
  var hasCompleted: Bool {
    for note in self.notes {
      if note.completed {
        return true
      }
    }
    return false
  }
  
  // MARK: - REORDER
  func reorderBeforeLift(indexPath indexPath: NSIndexPath, tableView: UITableView, completion: () -> ()) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // collapse (callback to prevent saving until after the reorder finishes)
      self.collapse(indexPath: indexPath, tableView: tableView)
      { children in
        // has to be main thread
        Util.threadMain {
          completion()
        }
      }
    }
  }
  
  func reorderAfterLift(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) {
    Util.threadBackground {
      // needed to handle when pulling a collapsed from the bottom and the tableview is shifted upwards
      func complete() {
        Util.threadMain {
          completion()
        }
      }
      
      if toIndexPath.row == fromIndexPath.row {
        complete()
        return
      }
      
      let direction = fromIndexPath.row > toIndexPath.row ? 1 : 0
      self.display.insert(self.display[fromIndexPath.row], atIndex: toIndexPath.row)
      self.display.removeAtIndex(fromIndexPath.row+direction)
      complete()
    }
  }
  
  func reorderDuringMove(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) {
    Util.threadBackground  {
      // needed to prevent re-appearing of lifted cell after tableview scrolls out of focus
      swap(&self.display[fromIndexPath.row], &self.display[toIndexPath.row])
      // has to be main thread
      Util.threadMain {
        completion()
      }
    }
  }
  
  func reorderAfterDrop(fromIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, tableView: UITableView, completion: () -> ()) {
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
        
        // complete
        func complete(section section: [Note], index: Int) {
          // insert
          self.notes.insertContentsOf(section, at: index)
          // bold
          var indexPaths: [NSIndexPath] = []
          indexPaths += self.updateBolded(indexPath: fromIndexPath)
          indexPaths += self.updateBolded(indexPath: toIndexPath)
          self.reload(indexPaths: indexPaths, tableView: tableView) {
            // save
            Notebook.set(data: self)
            // has to be main thread for reorder finish animation
            Util.threadMain {
              completion()
            }
          }
        }
        
        // notes insert section at first
        if toIndexPath.row == 0 {
          complete(section: section, index: 0)
          return
        }
        
        // notes insert section at last location (find location [notePrev])
        let prev = toIndexPath.row-1
        let displayPrev = self.display[prev]
        var notePrev = self.getNoteParent(displayParent: displayPrev)
        
        // find children for last one
        if displayPrev.collapsed {
          for i in prev+1..<self.notes.count {
            let child = self.notes[i]
            if child.indent <= notePrev.note.indent {
              break
            }
            notePrev.index = i
          }
        }
        
        complete(section: section, index: notePrev.index+1)
        return
      }
    }
  }
  
  // MARK: - COLLAPSE
  func collapse(indexPath indexPath: NSIndexPath, tableView: UITableView, completion: ((children: Int) -> ())? = nil) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // complete
      func complete(children children: Int) {
        if let completion = completion {
          // handle complete swipe and reorder lift
          completion(children: children)
        } else {
          // save
          Notebook.set(data: self)
        }
      }
      
      // early exit
      if displayParent.collapsed {
        complete(children: 0)
        return
      }
      
      // history
      if let _ = completion {} else {
        // don't save on complete or reorder because more processing needs to happen first
        self.historySave()
      }
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      noteParent.note.collapsed = true
      
      // note children
      let next = noteParent.index+1
      if next >= self.notes.count {
        // return collapsing on last note
        complete(children: 0)
        return
      } else {
        // return if no children
        let child = self.notes[next]
        if child.indent <= noteParent.note.indent {
          complete(children: 0)
          return
        }
      }
      
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
          complete(children: count)
          return
        }
      }
    }
  }
  
  func uncollapse(indexPath indexPath: NSIndexPath, tableView: UITableView, completion: (() -> ())? = nil) {
    Util.threadBackground {
      // display parent
      let displayParent = self.display[indexPath.row]
      
      // complete
      func complete() {
        if let completion = completion {
          // handle uncomplete swipe and reorder drop
          completion()
        } else {
          // save
          Notebook.set(data: self)
        }
      }
      
      // early exit
      if !displayParent.collapsed {
        complete()
        return
      }
      
      // history
      if let _ = completion {} else {
        self.historySave()
      }
      
      // note parent
      let noteParent = self.getNoteParent(displayParent: displayParent)
      noteParent.note.collapsed = false
      noteParent.note.children = 0
      
      // note children
      let noteChildren = self.setNoteChild(noteParent: noteParent, indent: nil, increase: nil, completed: nil)
      let displayNext = indexPath.row+1 >= self.display.count ? displayParent : self.display[indexPath.row+1]
      var indexPaths: [NSIndexPath] = []
      var children: [Note] = []
      var parent: (found: Bool, indent: Int) = (false, 0)
      for child in noteChildren {
        // prevent collapse parent, indent below grab
        if child.note == displayNext {
          break
        }
        
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
      
      
      // display children
      self.insert(indexPaths: indexPaths, tableView: tableView, data: children.reverse()) {
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          complete()
          return
        }
      }
    }
  }
  
  func collapseAll(tableView tableView: UITableView) {
    Util.threadBackground {
      // notes (if statements b/c buttons outside of cells)
      if self.notes.count > 0 {
        // history
        self.historySave()
        
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
  func reminder(indexPath indexPath: NSIndexPath, controller: UIViewController, tableView: UITableView, reminderType: ReminderType, date: NSDate?, completion: (success: Bool, create: Bool) -> ()) {
    Util.threadBackground {
      // history
      self.historySave()
      
      // create
      func create(note note: Note) {
        // create
        note.reminder = Reminder(type: reminderType, date: date)
        // notification
        LocalNotification.sharedInstance.create(controller: controller, body: note.title, action: nil, fireDate: note.reminder!.date, soundName: nil, uid: note.reminder!.uid) { success in
          if !success {
            self.reminderDelete(note: note)
          }
          complete(success: success, create: true)
        }
      }
      
      // complete
      func complete(success success: Bool, create: Bool) {
        // update
        self.reload(indexPaths: [indexPath], tableView: tableView) {
          // save
          Notebook.set(data: self)
          completion(success: success, create: create)
        }
      }
      
      // logic
      let note = self.display[indexPath.row]
      note.updated = NSDate()
      if reminderType == .Date {
        if date != nil {
          self.reminderDelete(note: note)
          create(note: note)
        } else {
          self.reminderDelete(note: note)
          complete(success: true, create: false)
        }
      } else {
        if let reminder = note.reminder {
          if reminderType != reminder.type {
            self.reminderDelete(note: note)
            create(note: note)
          } else {
            self.reminderDelete(note: note)
            complete(success: true, create: false)
          }
        } else {
          self.reminderDelete(note: note)
          create(note: note)
        }
      }
    }
  }
  
  private func reminderDelete(note note: Note) {
    // uses the same background thread of parent
    if let reminder = note.reminder {
      LocalNotification.sharedInstance.delete(uid: reminder.uid)
    }
    note.reminder = nil
  }
  
  // MARK: - HELPER METHODS
  private func correctBoldedAndCollapsed() -> [NSIndexPath] {
    var indexPaths: [NSIndexPath] = []
    
    func unbold(display display: Note, index: Int) {
      display.collapsed = false
      display.bolded = false
      display.children = 0
      indexPaths += [NSIndexPath(forRow: index, inSection: 0)]
    }
    
    for i in 0..<self.display.count {
      let display = self.display[i]
      
      if display.collapsed || display.bolded {
        let note = self.getNoteParent(displayParent: display)
        let next = note.index+1
        
        if next == self.notes.count {
          unbold(display: display, index: i)
        }
        
        if next < self.notes.count {
          let child = self.notes[next]
          if child.indent <= note.note.indent {
            unbold(display: display, index: i)
          }
        }
      }
    }
    return indexPaths
  }
  
  private func updateBolded(indexPath indexPath: NSIndexPath) -> [NSIndexPath] {
    let note = self.display[indexPath.row]
    var indexPaths: [NSIndexPath] = []
    if indexPath.row != 0 {
      let prev = indexPath.row-1
      let parent = self.display[prev]
      if parent.indent < note.indent {
        // bold parent
        if !parent.bolded {
          parent.bolded = true
          indexPaths += [NSIndexPath(forRow: prev, inSection: 0)]
        }
      } else {
        // unbold parent
        if parent.bolded {
          parent.bolded = false
          indexPaths += [NSIndexPath(forRow: prev, inSection: 0)]
        }
      }
    }
    let next = indexPath.row+1
    if !note.collapsed && next < self.display.count {
      let child = self.display[next]
      if child.indent > note.indent {
        // bold note
        if !note.bolded {
          note.bolded = true
          indexPaths += [NSIndexPath(forRow: indexPath.row, inSection: 0)]
        }
      } else {
        // unbold note
        if note.bolded {
          note.bolded = false
          indexPaths += [NSIndexPath(forRow: indexPath.row, inSection: 0)]
        }
      }
    }
    return indexPaths
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
      
      noteChild.note.updated = NSDate()
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
    static let id = "id"
    static let title = "title"
    static let notes = "notes"
    static let display = "display"
    static let history = "history"
    static let created = "created"
    static let updated = "updated"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(notes, forKey: PropertyKey.notes)
    aCoder.encodeObject(display, forKey: PropertyKey.display)
    aCoder.encodeObject(history, forKey: PropertyKey.history)
    aCoder.encodeObject(created, forKey: PropertyKey.created)
    aCoder.encodeObject(updated, forKey: PropertyKey.updated)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as! String
    let notes = aDecoder.decodeObjectForKey(PropertyKey.notes) as! [Note]
    let display = aDecoder.decodeObjectForKey(PropertyKey.display) as! [Note]
    let history = aDecoder.decodeObjectForKey(PropertyKey.history) as! [NotebookHistory]
    let created = aDecoder.decodeObjectForKey(PropertyKey.created) as! NSDate
    let updated = aDecoder.decodeObjectForKey(PropertyKey.updated) as! NSDate
    self.init(id: id, title: title, notes: notes, display: display, history: history, created: created, updated: updated)
  }
  
  // MARK: - ACCESS
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
    print(data)
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
    return loadDefaultDemo()
  }
  
  private static func loadDefaultTesting() -> Notebook {
    // create notebook
    let notebook = Notebook(notes: [])
    
    // notes
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
    
    // clear history and reminders
    notebook.history.removeAll()
    LocalNotification.sharedInstance.destroy()
    
    return notebook
  }
  
  private static func loadDefaultDemo() -> Notebook {
    // create notebook
    let notebook = Notebook(notes: [])
    
    // notes
    notebook.notes.append(Note(title: "Active", body: nil, completed: false, collapsed: false, children: 0, indent: 0, reminder: nil))
    notebook.notes.append(Note(title: "Get groceries", body: nil, completed: false, collapsed: false, children: 0, indent: 1, reminder: nil))
    notebook.notes.append(Note(title: "Sandwich", body: nil, completed: false, collapsed: false, children: 0, indent: 2, reminder: nil))
    notebook.notes.append(Note(title: "Bread", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    notebook.notes.append(Note(title: "Jelly", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    notebook.notes.append(Note(title: "Bananas", body: nil, completed: false, collapsed: false, children: 0, indent: 2, reminder: nil))
    notebook.notes.append(Note(title: "Finish book", body: nil, completed: false, collapsed: false, children: 0, indent: 1, reminder: nil))
    notebook.notes.append(Note(title: "Clean out garage", body: nil, completed: true, collapsed: true, children: 0, indent: 1, reminder: nil))
    notebook.notes.append(Note(title: "Archive", body: nil, completed: false, collapsed: false, children: 0, indent: 0, reminder: nil))
    notebook.notes.append(Note(title: "Favorite Font Types", body: nil, completed: false, collapsed: true, children: 4, indent: 1, reminder: nil))
    notebook.notes.append(Note(title: "Product Sans", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    notebook.notes.append(Note(title: "Open Sans", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    notebook.notes.append(Note(title: "San Francisco", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    notebook.notes.append(Note(title: "Helvetica Neue", body: nil, completed: false, collapsed: false, children: 0, indent: 3, reminder: nil))
    
    // copy the references to display view
    notebook.display = notebook.notes
    
    // clear history and reminders
    notebook.history.removeAll()
    LocalNotification.sharedInstance.destroy()
    
    // removed collapsed
    notebook.display.removeAtIndex(13)
    notebook.display.removeAtIndex(12)
    notebook.display.removeAtIndex(11)
    notebook.display.removeAtIndex(10)
    
    return notebook
  }
}