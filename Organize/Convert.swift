//
//  Convert.swift
//  Organize
//
//  Created by Ethan Neff on 6/14/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation
import Firebase

class Convert {
  typealias successful = (success: Bool) -> ()
  static let database = FIRDatabase.database().reference()
  
  static func upload(notebook data: Notebook, completion: successful) {
    // user
    guard let user = Remote.Auth.user else {
      // no user
      return completion(success: false)
    }
    
    // notebook id
    database.child("users/\(user.uid)/notebook").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
      if let notebookId = snapshot.value as? String {
        // notebook
        database.child("notebooks/\(notebookId)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
          if let notebook = snapshot.value {
            print(notebook)
            // delete old data
            //            if let notes = notebook["notes"] {
            //              database.child("notes/\(notes)").setValue(nil)
            // database.child("reminder/\(notes)").setValue(nil)
            //            }
            
            
            // assemble and push new data
            var notes: [String] = []
            for note in data.notes {
              notes.append(note.id)
              if let reminder = note.reminder {
                Remote.Database.Reminder.create(id: reminder.id, note: note.id, date: reminder.date, uid: reminder.uid, type: reminder.type.rawValue)
              }
              Remote.Database.Note.create(id: note.id, notebook: notebookId, title: note.title, body: note.body, completed: note.completed, collapsed: note.collapsed, children: note.children, indent: note.indent)
            }
            
            var display: [String] = []
            for note in data.display {
              display.append(note.id)
            }
            Remote.Database.Notebook.create(id: data.id, title: data.title, notes: notes, display: display)
            
          } else {
            // no notebook read
            print("notebook read")
            return completion(success: false)
          }
          
        }) { error in
          print("notebook pull \(error)")
          // no notebook pull
          return completion(success: false)
        }
      } else {
        // no notebook id read
        print("notebook id read")
        return completion(success: false)
      }
    }) { error in
      // no notebook id pull
      print("notebook id read \(error)")
      return completion(success: false)
    }
  }
  
  static func download(completion: successful) {
    //    let notebook = Notebook(title: "test", notes: [], display: [], history: [])
    //    Notebook.set(data: notebook)
    //    completion(success:true)
  }
}