//
//  Remote.swift
//  Organize
//
//  Created by Ethan Neff on 5/28/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation
import Firebase

struct Remote {
  
  typealias completionBlock = (error: String?) -> ()
  static private let database = FIRDatabase.database().reference()
  
  struct Auth {
    // TODO: make background threads
    private static func authError(code code: Int) -> String {
      switch code {
      // TODO: word better
      case 17000: return "Invalid custom token"
      case 17002: return "Custom token mismatch"
      case 17004: return "Invalid credentials"
      case 17005: return "User disabled"
      case 17006: return "Operation not allowed"
      case 17007: return "Email already in use"
      case 17008: return "Invalid email"
      case 17009: return "Invalid password"
      case 17010: return "Too many requests"
      case 17011: return "No account with this email"
      case 17012: return "Account exists with different credentials"
      case 17014: return "Requires re-login"
      case 17015: return "Provider already linked"
      case 17016: return "No such Provider"
      case 17017: return "Invalid user token"
      case 17020: return "No internet connection"
      case 17021: return "User token expired"
      case 17023: return "Invalid API key"
      case 17024: return "User mismatch"
      case 17025: return "Credential already in use"
      case 17026: return "Weak password"
      case 17028: return "App not authorized"
      case 17995: return "Keychain error"
      case 17999: return "Internal Error"
      default: return "Unknown error"
      }
    }
    
    // MARK: - public
    static var user: FIRUser? {
      return FIRAuth.auth()?.currentUser ?? nil
    }
    
    static func signup(controller controller: UIViewController, email: String, password: String, name: String, completion: completionBlock) {
      let logout = true
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      createSignup(email: email, password: password) { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        
        createProfile(user: user, displayName: name) { (error) in
          if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
          
          readDeviceUUID { (error, uuid) in
            if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
            
            let notebook = Notebook(title: Constant.App.name)
            updateDatabaseSignup(user: user, email: email, name: name, uuid: uuid, notebook: notebook) { (error) in
              if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
              
              updateLocalNotebook(notebook: notebook) { (error) in
                if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                
                return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
              }
            }
          }
        }
      }
    }
    
    static func login(controller controller: UIViewController, email: String, password: String, completion: completionBlock) {
      let logout = true
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      createLogin(email: email, password: password) { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        
        readDeviceUUID { (error, uuid) in
          if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
          
          updateDatabaseLogin(email: email, user: user, uuid: uuid) { (error) in
            if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
            
            readDatabaseNotebookId(user: user) { (error, notebookId) in
              if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
              
              readDatabaseNotebook(notebookId: notebookId) { (error, notebook) in
                if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                
                readDatabaseNotebookNotes(notebook: notebook) { (error, notes) in
                  if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                  
                  convertNotesRemoteToLocal(notebook: notebook, notes: notes) { (error, notes, display) in
                    if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                    
                    convertNotebookRemoteToLocal(notebook: notebook, notes: notes, display: display) { (error, notebook) in
                      if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                      
                      updateLocalNotebook(notebook: notebook) { (error) in
                        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                        
                        return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    
    static func logout(controller controller: UIViewController, notebook: Notebook, completion: completionBlock) {
      let logout = true
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      if !Util.hasNetworkConnection {
        return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: 17020))
      }
      
      readUser { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        let update = convertNotebookLocalToRemote(notebook: notebook, user: user)
        
        updateDatabase(data: update) { (error) in
          if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
          let notebook =  Notebook(notes: [])
          
          updateLocalNotebook(notebook: notebook) { (error) in
            if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
            
            LocalNotification.sharedInstance.destroy()
            signOut()
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
          }
        }
      }
    }
    
    static func signOut() {
      try! FIRAuth.auth()!.signOut()
    }
    
    static func resetPassword(controller controller: UIViewController, email: String, completion: completionBlock) {
      let logout = true
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      FIRAuth.auth()?.sendPasswordResetWithEmail(email) { (error) in
        if let error = error {
          return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: error.code))
        } else {
          return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
        }
      }
    }
    
    static func changeEmail(controller controller: UIViewController, email: String, completion: completionBlock) {
      let logout = false
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      readUser { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        
        user.updateEmail(email) { error in
          if let error = error {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: error.code))
          } else {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
          }
        }
      }
    }
    
    static func changePassword(controller controller: UIViewController, password: String, completion: completionBlock) {
      let logout = false
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      readUser { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        
        user.updatePassword(password) { error in
          if let error = error {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: error.code))
          } else {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
          }
        }
      }
    }
    
    static func delete(controller controller: UIViewController, completion: completionBlock) {
      let logout = false
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      if !Util.hasNetworkConnection {
        return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: 17020))
      }
      
      readUser { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        let delete: [String: AnyObject] = ["users/\(user.uid)/active": false]
        
        updateDatabase(data: delete) { (error) in
          if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        }
        
        FIRAuth.auth()?.currentUser?.deleteWithCompletion { error in
          if let error = error {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: error.code))
          } else {
            return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
          }
        }
      }
    }
    
    static func upload(notebook notebook: Notebook, completion: completionBlock? = nil) {
      readUser { (error, user) in
        if let error = error {
          Report.sharedInstance.log("upload get user error: \(error)")
          if let completion = completion {
            return completion(error: error)
          }
        }
        
        let user = user!
        let update = convertNotebookLocalToRemote(notebook: notebook, user: user)
        
        updateDatabase(data: update) { (error) in
          if let error = error {
            Report.sharedInstance.log("upload update database error: \(error)")
            if let completion = completion {
              return completion(error: error)
            }
            
          }
          if let completion = completion {
            return completion(error: nil)
          }
        }
      }
    }
    
    static func download(controller controller: UIViewController, completion: completionBlock) {
      let logout = false
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      if !Util.hasNetworkConnection {
        return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: authError(code: 17020))
      }
      
      readUser { (error, user) in
        if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
        let user = user!
        
        readDeviceUUID { (error, uuid) in
          if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
          
          readDatabaseNotebookId(user: user) { (error, notebookId) in
            if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
            
            readDatabaseNotebook(notebookId: notebookId) { (error, notebook) in
              if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
              
              readDatabaseNotebookNotes(notebook: notebook) { (error, notes) in
                if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                
                convertNotesRemoteToLocal(notebook: notebook, notes: notes) { (error, notes, display) in
                  if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                  
                  convertNotebookRemoteToLocal(notebook: notebook, notes: notes, display: display) { (error, notebook) in
                    if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                    
                    updateLocalNotebook(notebook: notebook) { (error) in
                      if let error = error { return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: error) }
                      
                      return finish(loadingModal: loadingModal, logout: logout, completion: completion, error: nil)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    
    // MARK: - create
    static private func createSignup(email email: String, password: String, completion: (error: String?, user: FIRUser?) -> ()) {
      FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
        if let error = error {
          Report.sharedInstance.log("get signup attempt: \(error)")
          completion(error: authError(code: error.code), user: user)
        } else if user == nil {
          Report.sharedInstance.log("get signup user")
          completion(error: authError(code: 17999), user: user)
        } else {
          completion(error: nil, user: user)
        }
      }
    }
    
    static private func createProfile(user user: FIRUser, displayName: String, completion: (error: String?) -> ()) {
      let changeRequest = user.profileChangeRequest()
      changeRequest.displayName = displayName
      changeRequest.commitChangesWithCompletion() { error in
        if let error = error {
          Report.sharedInstance.log("sign up update profile: \(error)")
          completion(error: authError(code: error.code))
        } else {
          completion(error: nil)
        }
      }
    }
    
    static private func createLogin(email email: String, password: String, completion: (error: String?, user: FIRUser?) -> ()) {
      FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
        if let error = error {
          Report.sharedInstance.log("get login attempt: \(error)")
          completion(error: authError(code: error.code), user: user)
        } else if user == nil {
          Report.sharedInstance.log("get login user")
          completion(error: authError(code: 17999), user: user)
        } else {
          completion(error: nil, user: user)
        }
      }
    }
    
    // MARK: - read
    static private func readDeviceUUID(completion: (error: String?, uuid: String) -> ()) {
      if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
        completion(error: nil, uuid: uuid)
      } else {
        Report.sharedInstance.log("get device uuid")
        completion(error: authError(code: 17999), uuid: "")
      }
    }
    
    static private func readUser(completion: (error: String?, user: FIRUser?) -> ()) {
      if let user = Remote.Auth.user {
        completion(error: nil, user: user)
      } else {
        Report.sharedInstance.log("missing user")
        completion(error: authError(code: 17999), user: nil)
      }
    }
    
    // MARK: - database
    static private func updateDatabase(data data: [String: AnyObject], completion: (error: String?) -> ()) {
      database.updateChildValues(data, withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
        if let error = error {
          Report.sharedInstance.log("update database: \(error)")
          completion(error: authError(code: 17999))
        } else {
          completion(error: nil)
        }
      })
    }
    
    static private func updateDatabaseSignup(user user: FIRUser, email: String, name: String, uuid: String, notebook: Notebook, completion: (error: String?) -> ()) {
      database.updateChildValues([
        // user
        "users/\(user.uid)/email": email,
        "users/\(user.uid)/name": name,
        "users/\(user.uid)/active": true,
        "users/\(user.uid)/notebook": notebook.id,
        "users/\(user.uid)/notebooks/\(notebook.id)": true,
        "users/\(user.uid)/updated": FIRServerValue.timestamp(),
        "users/\(user.uid)/created": FIRServerValue.timestamp(),
        // devices
        "users/\(user.uid)/devices/\(uuid)": true,
        "devices/\(uuid)/users/\(user.uid)": true,
        // notebook
        "notebooks/\(notebook.id)/title": notebook.title,
        "notebooks/\(notebook.id)/tags": [],
        "notebooks/\(notebook.id)/notes": [],
        "notebooks/\(notebook.id)/display": [],
        "notebooks/\(notebook.id)/user": user.uid,
        "notebooks/\(notebook.id)/active": true,
        "notebooks/\(notebook.id)/created": notebook.created.timeIntervalSince1970,
        "notebooks/\(notebook.id)/updated": notebook.updated.timeIntervalSince1970,
        ], withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
          if let error = error {
            Report.sharedInstance.log("signup update user database: \(error)")
            completion(error: authError(code: 17999))
          } else {
            completion(error: nil)
          }
      })
    }
    
    static private func updateDatabaseLogin(email email: String, user: FIRUser, uuid: String, completion: (error: String?) -> ()) {
      database.updateChildValues([
        // user
        "users/\(user.uid)/email": email,
        "users/\(user.uid)/active": true,
        "users/\(user.uid)/updated": FIRServerValue.timestamp(),
        // devices
        "users/\(user.uid)/devices/\(uuid)": true,
        "devices/\(uuid)/users/\(user.uid)": true,
        ], withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
          if let error = error {
            Report.sharedInstance.log("login update user database: \(error)")
            completion(error: authError(code: 17999))
          } else {
            completion(error: nil)
          }
      })
    }
    
    static private func readDatabaseNotebookId(user user: FIRUser, completion: (error: String?, notebookId: String) -> ()) {
      database.child("users/\(user.uid)/notebook").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        if let remoteNotebookId = snapshot.value as? String {
          completion(error: nil, notebookId: remoteNotebookId)
        } else {
          Report.sharedInstance.log("missing notebook id")
          completion(error: authError(code: 17999), notebookId: "")
        }
      })
    }
    
    static private func readDatabaseNotebook(notebookId notebookId: String, completion: (error: String?, notebook: [String: AnyObject]) -> ()) {
      database.child("notebooks/\(notebookId)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        if var notebook = snapshot.value as? [String: AnyObject] {
          notebook["id"] = notebookId
          completion(error: nil, notebook: notebook)
        } else {
          Report.sharedInstance.log("missing notebook")
          completion(error: authError(code: 17999), notebook: [:])
        }
      })
    }
    
    static private func readDatabaseNotebookNotes(notebook notebook: [String: AnyObject], completion: (error: String?, notes: [[String: AnyObject]]) -> ()) {
      guard let noteIds = notebook["notes"] as? [String] else {
        return completion(error: nil, notes: [])
      }
      
      // download notes
      var count: Int = noteIds.count
      var error: Bool = false
      var notes: [[String: AnyObject]] = []
      for id in noteIds {
        database.child("notes/\(id)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
          // catch error (only report once)
          guard var note = snapshot.value as? [String: AnyObject] else {
            if !error {
              error = true
              Report.sharedInstance.log("missing note")
              return completion(error: authError(code: 17999), notes: [])
            }
            return
          }
          
          // save note
          note["id"] = id
          notes.append(note)
          
          // complete
          count -= 1
          if count == 0 {
            return completion(error: nil, notes: notes)
          }
        })
      }
    }
    
    static private func updateLocalNotebook(notebook notebook: Notebook, completion: completionBlock) {
      Notebook.set(data: notebook) { success in
        if !success {
          Report.sharedInstance.log("save notebook")
          completion(error: authError(code: 17999))
        } else {
          completion(error: nil)
        }
      }
    }
    
    // MARK: - finish
    static private func finish(loadingModal loadingModal: ModalLoading, logout: Bool, completion: completionBlock, error: String?) {
      loadingModal.hide {
        if let error = error {
          if logout {
            try! FIRAuth.auth()!.signOut()
          }
          completion(error: error)
        } else {
          completion(error: nil)
        }
      }
    }
    
    // MARK: - convert
    static private func convertNotesRemoteToLocal(notebook notebook: [String: AnyObject], notes: [[String: AnyObject]], completion: (error: String?, notes: [Note], display: [Note]) -> ()) {
      // quick exit
      guard let noteIds = notebook["notes"] as? [String], let displayIds = notebook["display"] as? [String] else {
        return completion(error: nil, notes: [], display: [])
      }
      
      // dictionary to Note
      var unorganized: [Note] = []
      for note in notes {
        let body = note["body"] as? String
        guard let id = note["id"] as? String,
          let title = note["title"] as? String,
          let bolded = note["bolded"] as? Bool,
          let completed = note["completed"] as? Bool,
          let collapsed = note["collapsed"] as? Bool,
          let children = note["children"] as? Int,
          let indent = note["indent"] as? Int,
          let created = note["created"] as? Double,
          let updated = note["updated"] as? Double else {
            Report.sharedInstance.log("creating note")
            return completion(error: authError(code: 17999), notes: [], display: [])
        }
        
        var reminder: Reminder?
        if let noteReminder = note["reminder"] as? [String: AnyObject] {
          guard let id = noteReminder["id"] as? String,
            let uid = noteReminder["uid"] as? Double,
            let date = noteReminder["date"] as? Double,
            let type = noteReminder["type"] as? Int,
            let created = note["created"] as? Double,
            let updated = note["updated"] as? Double else {
              Report.sharedInstance.log("creating reminder")
              return completion(error: authError(code: 17999), notes: [], display: [])
          }
          
          let reminderType = ReminderType(rawValue: type) ?? ReminderType(rawValue: 0)!
          reminder = Reminder(id: id, uid: uid, type: reminderType, date: NSDate(timeIntervalSince1970: date), created: NSDate(timeIntervalSince1970: created), updated: NSDate(timeIntervalSince1970: updated))
        }
        
        let note = Note(id: id, title: title, body: body, bolded: bolded, completed: completed, collapsed: collapsed, children: children, indent: indent, reminder: reminder, created: NSDate(timeIntervalSince1970: created), updated: NSDate(timeIntervalSince1970: updated))
        unorganized.append(note)
      }
      
      // unorganize to note and display
      var notes: [Note] = []
      var display: [Note] = []
      
      for id in noteIds {
        for i in 0..<unorganized.count {
          let note = unorganized[i]
          if note.id == id {
            notes.append(note)
            unorganized.removeAtIndex(i)
            break
          }
        }
      }
      
      var found = 0
      for id in displayIds {
        for i in found..<notes.count {
          let note = notes[i]
          if note.id == id {
            found += 1
            display.append(note)
            break
          }
        }
      }
      
      // update local reminders
      LocalNotification.sharedInstance.destroy()
      for note in notes {
        if let reminder = note.reminder, let controller = UIApplication.topViewController()  {
          // TODO: push notifications accept before download on login
          LocalNotification.sharedInstance.create(controller: controller, body: note.title, action: nil, fireDate: reminder.date, soundName: nil, uid: reminder.uid, completion: nil)
        }
      }
      
      return completion(error: nil, notes: notes, display: display)
    }
    
    static private func convertNotebookRemoteToLocal(notebook notebook: [String: AnyObject], notes: [Note], display: [Note], completion: (error: String?, notebook: Notebook) -> ()) {
      guard let title = notebook["title"] as? String,
        let id = notebook["id"] as? String,
        let created = notebook["created"] as? Double,
        let updated = notebook["updated"] as? Double else {
          Report.sharedInstance.log("missing notebook info")
          return completion(error: authError(code: 17999), notebook: Notebook(title: ""))
      }
      
      let notebook = Notebook(id: id, title: title, notes: notes, display: display, history: [], created: NSDate(timeIntervalSince1970: created), updated: NSDate(timeIntervalSince1970: updated))
      return completion(error: nil, notebook: notebook)
    }
    
    static private func convertNotebookLocalToRemote(notebook notebook: Notebook, user: FIRUser) -> [String: AnyObject] {
      // update notebook
      var update: [String: AnyObject] = [:]
      var notes: [String] = []
      var display: [String] = []
      update["notebooks/\(notebook.id)/title"] = notebook.title
      update["notebooks/\(notebook.id)/updated"] = notebook.updated.timeIntervalSince1970
      // create new notes
      for note in notebook.notes {
        update["notes/\(note.id)/user"] = user.uid
        update["notes/\(note.id)/notebook"] = notebook.id
        update["notes/\(note.id)/title"] = note.title
        update["notes/\(note.id)/body"] = note.body ?? ""
        update["notes/\(note.id)/bolded"] = note.bolded
        update["notes/\(note.id)/completed"] = note.completed
        update["notes/\(note.id)/collapsed"] = note.collapsed
        update["notes/\(note.id)/children"] = note.children
        update["notes/\(note.id)/indent"] = note.indent
        update["notes/\(note.id)/created"] = note.created.timeIntervalSince1970
        update["notes/\(note.id)/updated"] = note.updated.timeIntervalSince1970
        // create new reminders
        if let reminder = note.reminder {
          update["notes/\(note.id)/reminder/id"] = reminder.id
          update["notes/\(note.id)/reminder/uid"] = reminder.uid
          update["notes/\(note.id)/reminder/date"] = reminder.date.timeIntervalSince1970
          update["notes/\(note.id)/reminder/type"] = reminder.type.rawValue
          update["notes/\(note.id)/reminder/created"] = reminder.created.timeIntervalSince1970
          update["notes/\(note.id)/reminder/updated"] = reminder.updated.timeIntervalSince1970
        } else {
          update["notes/\(note.id)/reminder"] = false
        }
        // create note array
        notes.append(note.id)
      }
      for note in notebook.display {
        // create display array
        display.append(note.id)
      }
      update["notebooks/\(notebook.id)/notes"] = notes
      update["notebooks/\(notebook.id)/display"] = display
      
      return update
    }
  }
  
  struct Device {
    
    static func open() {
      update()
      access()
    }
    
    static func updatePushAPN(token token: String) {
      // apn push
      if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
        database.updateChildValues(["devices/\(uuid)/apn/": token])
      }
    }
    
    static func updatePushFCM(token token: String) {
      // firebase push
      if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
        database.updateChildValues(["devices/\(uuid)/fcm/": token])
      }
    }
    
    static private func update() {
      // called on device open
      let uuid: String = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? "" // changes on app deletion
      let model = UIDevice.currentDevice().modelName
      let version = UIDevice.currentDevice().systemVersion
      let app: String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
      
      database.child("devices/\(uuid)/").updateChildValues([
        "os": "iOS",
        "model": model,
        "version": version,
        "app": app
        ])
    }
    
    static private func access() {
      if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
        let accessedRef = FIRDatabase.database().referenceWithPath("devices/\(uuid)/accessed")
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
          accessedRef.onDisconnectSetValue(FIRServerValue.timestamp())
        })
      }
    }
  }
  
  struct User {
    
    static func open() {
      access()
    }
    
    static private func access() {
      if let user = Remote.Auth.user, let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
        let myConnectionsRef = FIRDatabase.database().referenceWithPath("users/\(user.uid)/connections")
        let accessedRef = FIRDatabase.database().referenceWithPath("users/\(user.uid)/accessed")
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
          let connected = snapshot.value as? Bool
          if connected != nil && connected! {
            let con = myConnectionsRef.child(uuid)
            con.setValue(true)
            con.onDisconnectRemoveValue()
            accessedRef.onDisconnectSetValue(FIRServerValue.timestamp())
          }
        })
      }
    }
  }
  
  struct Config {
    
    enum Keys: String {
      case ShowAds
      case ShowReview
    }
    
    static func fetch(completion: (config: FIRRemoteConfig?) -> ()) {
      let remoteConfig: FIRRemoteConfig = FIRRemoteConfig.remoteConfig()
      remoteConfig.configSettings = FIRRemoteConfigSettings(developerModeEnabled: Constant.App.release ? false : true)!
      
      let expirationDuration: Double = remoteConfig.configSettings.isDeveloperModeEnabled ? 0 : 60*60
      remoteConfig.fetchWithExpirationDuration(expirationDuration) { (status, error) in
        if (status == .Success) {
          remoteConfig.activateFetched()
          completion(config: remoteConfig)
        } else {
          Report.sharedInstance.log("Config not fetched \(error)")
          completion(config: nil)
        }
      }
    }
  }
}