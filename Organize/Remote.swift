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
    
    static var user: FIRUser? {
      return FIRAuth.auth()?.currentUser ?? nil
    }
    
    static func signup(controller controller: UIViewController, email: String, password: String, name: String, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      func complete(error error: Int?) {
        loadingModal.hide {
          if let error = error {
            try! FIRAuth.auth()!.signOut()
            completion(error: authError(code: error))
          } else {
            completion(error: nil)
          }
        }
      }
      
      // attempt sign up
      FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
        if let error = error {
          Report.sharedInstance.log("signup attempt: \(error)")
          return complete(error: error.code)
        }
        guard let user = user else {
          Report.sharedInstance.log("signup missing user")
          return complete(error: 17999)
        }
        
        // update profile
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChangesWithCompletion() { error in
          if let error = error {
            Report.sharedInstance.log("sign up update profile: \(error)")
            return complete(error: error.code)
          }
          
          guard let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString else {
            Report.sharedInstance.log("signup get device uuid")
            return complete(error: 17999)
          }
          
          // update database
          let database = FIRDatabase.database().reference()
          let notebook = Notebook(title: Constant.App.name)
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
            "notebooks/\(notebook.id)/created": FIRServerValue.timestamp(),
            "notebooks/\(notebook.id)/updated": FIRServerValue.timestamp(),
            ], withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
              if let error = error {
                Report.sharedInstance.log("signup update user database: \(error)")
                return complete(error: 17999)
              }
              
              // set default notebook
              Notebook.set(data: notebook) { success in
                if !success {
                  Report.sharedInstance.log("signup save default notebook")
                  return complete(error: 17999)
                }
                return complete(error: nil)
              }
          })
        }
      }
    }
    
    static func login(controller controller: UIViewController, email: String, password: String, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      func complete(error error: Int?) {
        loadingModal.hide {
          if let error = error {
            try! FIRAuth.auth()!.signOut()
            completion(error: authError(code: error))
          } else {
            completion(error: nil)
          }
        }
      }
      
      // attempt login
      FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
        if let error = error {
          Report.sharedInstance.log("login attempt: \(error)")
          return complete(error: error.code)
        }
        guard let user = user else {
          Report.sharedInstance.log("login missing user")
          return complete(error: 17999)
        }
        guard let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString else {
          Report.sharedInstance.log("login get device uuid")
          return complete(error: 17999)
        }
        
        // update database (for email/pass changes)
        let database = FIRDatabase.database().reference()
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
              return complete(error: 17999)
            }
            
            // get active notebook id
            database.child("users/\(user.uid)/notebook").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
              guard let remoteNotebookId = snapshot.value as? String else {
                Report.sharedInstance.log("login missing notebook id")
                return complete(error: 17999)
              }
              // get notebook
              database.child("notebooks/\(remoteNotebookId)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let remoteNotebook = snapshot.value as? [String: AnyObject] else {
                  Report.sharedInstance.log("login missing notebook")
                  return complete(error: 17999)
                }
                
                guard let remoteNotebookTitle = remoteNotebook["title"] as? String else {
                  Report.sharedInstance.log("login missing notebook title")
                  return complete(error: 17999)
                }
                
                // download and create notes
                downloadNotes(remoteNotebook: remoteNotebook, completion: { (notes, display) in
                  guard let notes = notes, let display = display else {
                    Report.sharedInstance.log("login downloading and creating notes")
                    return complete(error: 17999)
                  }
                  
                  // create notebook
                  let notebook = Notebook(id: remoteNotebookId, title: remoteNotebookTitle, notes: notes, display: display, history: [])
                  
                  // convert notebook to local
                  Notebook.set(data: notebook) { success in
                    if !success {
                      Report.sharedInstance.log("login save notebook")
                      return complete(error: 17999)
                    }
                    return complete(error: nil)
                  }
                })
              })
            })
        })
      }
    }
    
    static private func downloadNotes(remoteNotebook remoteNotebook: [String: AnyObject], completion: (notes: [Note]?, display: [Note]?) -> ()) {
      guard let noteIds = remoteNotebook["notes"] as? [String], let displayIds = remoteNotebook["display"] as? [String]  else {
        return completion(notes: [], display: [])
      }
      
      var completed = false
      let database = FIRDatabase.database().reference()
      var count = noteIds.count
      var random: [Note] = []
      var notes: [Note] = []
      var display: [Note] = []
      
      func createNote(id id: String, note: [String: AnyObject]) {
        let body = note["body"] as? String
        guard let title = note["title"] as? String,
          let completed = note["completed"] as? Bool,
          let collapsed = note["collapsed"] as? Bool,
          let children = note["children"] as? Int,
          let indent = note["indent"] as? Int else {
            Report.sharedInstance.log("creating note \(id)")
            return completion(notes: nil, display: nil)
        }
        
        var reminder: Reminder?
        if let noteReminder = note["reminder"] as? [String: AnyObject] {
          guard let id = noteReminder["id"] as? String,
            let uid = noteReminder["uid"] as? Double,
            let date = noteReminder["date"] as? Double,
            let type = noteReminder["type"] as? Int else {
              Report.sharedInstance.log("creating reminder")
              return completion(notes: nil, display: nil)
          }
          
          let reminderType = ReminderType(rawValue: type) ?? ReminderType(rawValue: 0)!
          let reminderDate = NSDate(timeIntervalSince1970: date)
          reminder = Reminder(id: id, uid: uid, type: reminderType, date: reminderDate)
        }
        
        let note = Note(id: id, title: title, body: body, completed: completed, collapsed: collapsed, children: children, indent: indent, reminder: reminder)
        random.append(note)
      }
      
      func orderNotesAndDisplay() {
        for id in noteIds {
          for i in 0..<random.count {
            let note = random[i]
            if note.id == id {
              notes.append(note)
              random.removeAtIndex(i)
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
      }
      
      func updateReminders() {
        LocalNotification.sharedInstance.destroy()
        for note in notes {
          if let reminder = note.reminder, let controller = UIApplication.topViewController()  {
            // TODO: notebook reminder func needs to be the same
            // TODO: push notifications accept before download on login
            LocalNotification.sharedInstance.create(controller: controller, body: note.title, action: nil, fireDate: reminder.date, soundName: nil, uid: reminder.uid, completion: nil)
          }
        }
      }
      
      // download notes
      for id in noteIds {
        database.child("notes/\(id)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
          guard let remoteNote = snapshot.value as? [String: AnyObject] else {
            if !completed {
              completed = true
              return completion(notes: nil, display: nil)
            }
            return
          }
          
          // create note
          createNote(id: id, note: remoteNote)
          
          // complete
          count -= 1
          if count == 0 {
            orderNotesAndDisplay()
            updateReminders()
            return completion(notes: notes, display: display)
          }
        })
      }
      
    }
    
    static func resetPassword(controller controller: UIViewController, email: String, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      FIRAuth.auth()?.sendPasswordResetWithEmail(email) { (error) in
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error.code))
          } else {
            completion(error: nil)
          }
        }
      }
    }
    
    static func changeEmail(controller controller: UIViewController, email: String, completion: completionBlock) {
      guard let user = FIRAuth.auth()?.currentUser else {
        return  completion(error: authError(code: 0))
      }
      
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      user.updateEmail(email) { error in
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error.code))
          } else {
            completion(error: nil)
          }
        }
      }
    }
    
    static func changePassword(controller controller: UIViewController, password: String, completion: completionBlock) {
      guard let user = FIRAuth.auth()?.currentUser else {
        return completion(error: authError(code: 0))
      }
      
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      user.updatePassword(password) { error in
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error.code))
          } else {
            completion(error: nil)
          }
        }
      }
    }
    
    static func logout(controller controller: UIViewController, notebook: Notebook, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      
      func complete(error error: Int?) {
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error))
          } else {
            completion(error: nil)
          }
        }
      }
      
      // get user
      guard let user = Remote.Auth.user else {
        Report.sharedInstance.log("logout missing user")
        return complete(error: 17999)
      }
      
      // update database
      let update = upload(notebook: notebook, user: user)
      let database = FIRDatabase.database().reference()
      database.updateChildValues(update, withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
        if let error = error {
          Report.sharedInstance.log("logout update notebook database: \(error)")
          return complete(error: 17999)
        }
        
        // clear local notebook
        Notebook.set(data: Notebook(notes: [])) { success in
          if !success {
            Report.sharedInstance.log("logout save notebook")
            return complete(error: 17999)
          }
          // clear reminders
          LocalNotification.sharedInstance.destroy()
          
          // logout
          try! FIRAuth.auth()!.signOut()
          return complete(error: nil)
        }
      })
    }
    
    static func upload(notebook notebook: Notebook, user: FIRUser) -> [String: AnyObject] {
      // update notebook
      var update: [String: AnyObject] = [:]
      var notes: [String] = []
      var display: [String] = []
      update["notebooks/\(notebook.id)/title"] = notebook.title
      update["notebooks/\(notebook.id)/updated"] = FIRServerValue.timestamp()
      // create new notes
      for note in notebook.notes {
        update["notes/\(note.id)/user"] = user.uid
        update["notes/\(note.id)/notebook"] = notebook.id
        update["notes/\(note.id)/title"] = note.title
        update["notes/\(note.id)/body"] = note.body ?? ""
        update["notes/\(note.id)/completed"] = note.completed
        update["notes/\(note.id)/collapsed"] = note.collapsed
        update["notes/\(note.id)/children"] = note.children
        update["notes/\(note.id)/indent"] = note.indent
        update["notes/\(note.id)/created"] = FIRServerValue.timestamp() // TODO: grab from note create
        update["notes/\(note.id)/updated"] = FIRServerValue.timestamp() // TODO: grab from note update
        // create new reminders
        if let reminder = note.reminder {
          update["notes/\(note.id)/reminder/id"] = reminder.id
          update["notes/\(note.id)/reminder/uid"] = reminder.uid
          update["notes/\(note.id)/reminder/date"] = reminder.date.timeIntervalSince1970
          update["notes/\(note.id)/reminder/type"] = reminder.type.rawValue
          update["notes/\(note.id)/reminder/created"] = FIRServerValue.timestamp() // TODO: grab from reminder created
          update["notes/\(note.id)/reminder/updated"] = FIRServerValue.timestamp() // TODO: grab from reminder updated
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
    
    static func delete(controller controller: UIViewController, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      Remote.Database.User.delete()
      FIRAuth.auth()?.currentUser?.deleteWithCompletion { error in
        loadingModal.hide {
          if let error = error {
            completion(error: error.localizedDescription)
          } else {
            completion(error: nil)
          }
        }
      }
    }
  }
  
  struct Database {
    static let ref = FIRDatabase.database().reference()
    
    struct Device {
      static func update() {
        // called on device open
        let uuid: String = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? "" // changes on app deletion
        let model = UIDevice.currentDevice().modelName
        let version = UIDevice.currentDevice().systemVersion
        let app: String = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        
        ref.child("devices/\(uuid)/").updateChildValues([
          "os": "iOS",
          "model": model,
          "version": version,
          "app": app
          ])
      }
      
      static func updatePushAPN(token token: String) {
        // apn push
        if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
          ref.updateChildValues(["devices/\(uuid)/apn/": token])
        } else {
          Report.sharedInstance.log("missing uuid")
        }
      }
      
      static func updatePushFCM(token token: String) {
        // firebase push
        if let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
          ref.updateChildValues(["devices/\(uuid)/fcm/": token])
        } else {
          Report.sharedInstance.log("missing uuid")
        }
      }
      
      static func open() {
        update()
        access()
      }
      
      static func access() {
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
      static func logout() {
        unlinkDevice()
      }
      
      static func login() {
        if let user = Remote.Auth.user, let email = user.email, let name = user.displayName {
          linkDevice()
          ref.child("users/\(user.uid)").updateChildValues([
            "email": email,
            "name": name,
            "active": true,
            ], withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
          })
          
        }
      }
      
      static func signup() {
        if let user = Remote.Auth.user {
          ref.child("users/\(user.uid)").updateChildValues([
            "created": FIRServerValue.timestamp(),
            ])
          login()
        }
      }
      
      static func createNotebook(id id: String) {
        if let user = Remote.Auth.user {
          ref.updateChildValues(["users/\(user.uid)/notebooks/\(id)": true])
          ref.updateChildValues(["users/\(user.uid)/notebook/": id])
        }
      }
      
      static func delete() {
        if let user = Remote.Auth.user {
          ref.child("users/\(user.uid)").updateChildValues([
            "active": false,
            ])
          unlinkDevice()
        }
      }
      
      static func linkDevice() {
        if let user = Remote.Auth.user, let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
          ref.updateChildValues(["devices/\(uuid)/users/\(user.uid)": true])
          ref.updateChildValues(["users/\(user.uid)/devices/\(uuid)": true])
        }
      }
      
      static func unlinkDevice() {
        if let user = Remote.Auth.user, let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString {
          ref.updateChildValues(["devices/\(uuid)/users/\(user.uid)": false])
          ref.updateChildValues(["users/\(user.uid)/devices/\(uuid)": false])
        }
      }
      
      static func open() {
        access()
      }
      
      static func access() {
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
    
    struct Notebook {
      static func create(id id: String, title: String, notes: [String], display: [String]) {
        if let user = Remote.Auth.user {
          ref.child("notebooks/\(id)").updateChildValues([
            "title": title,
            "tags": [],
            "notes": notes,
            "display": display,
            "user": user.uid,
            "active": true,
            "created": FIRServerValue.timestamp(),
            "updated": FIRServerValue.timestamp(),
            ])
        }
      }
      static func upload(notebook notebook: AnyObject, completion: (success: Bool) -> ()) {
        
      }
    }
    
    struct Note {
      static func create(id id: String, notebook: String, title: String, body: String?, completed: Bool, collapsed: Bool, children: Int, indent: Int) {
        if let user = Remote.Auth.user {
          ref.child("notes/\(id)").updateChildValues([
            "title": title,
            "body": body ?? "",
            "completed": completed,
            "collapsed": collapsed,
            "children": children,
            "indent": indent,
            "notebook": notebook,
            "user": user.uid,
            "active": true,
            "created": FIRServerValue.timestamp(),
            "updated": FIRServerValue.timestamp(),
            ], withCompletionBlock: { (error: NSError?, reference: FIRDatabaseReference) in
              
          })
        }
      }
    }
    
    struct Reminder {
      static func create(id id: String, note: String, date: NSDate, uid: Double, type: Int) {
        if let user = Remote.Auth.user {
          ref.child("reminders/\(id)").setValue([
            "date": date,
            "uid": uid,
            "type": type,
            "user": user.uid,
            "note": note,
            "active": true,
            "created": FIRServerValue.timestamp(),
            "updated": FIRServerValue.timestamp(),
            ])
        }
      }
    }
    
    struct Tag {
      
    }
  }
  
  struct Config {
    
    enum Keys: String {
      case ShowAds
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