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
      
      // sign up
      loadingModal.show(controller: controller)
      FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
        if let error = error {
          loadingModal.hide {
            completion(error: authError(code: error.code))
          }
        }
        if let user = user {
          // update profile
          let changeRequest = user.profileChangeRequest()
          changeRequest.displayName = name
          changeRequest.commitChangesWithCompletion() { (error) in
            loadingModal.hide {
              if let error = error {
                completion(error: authError(code: error.code))
              } else {
                 Remote.Database.User.signup()
                if let notebookId = Remote.Database.Notebook.create(title: "Organize") {
                  Remote.Database.User.createNotebook(id: notebookId)
                }
                completion(error: nil)
              }
            }
          }
        }
      }
    }
    
    static func login(controller controller: UIViewController, email: String, password: String, completion: completionBlock) {
      let loadingModal = ModalLoading()
      loadingModal.show(controller: controller)
      FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error.code))
          } else {
            Remote.Database.User.login()
            completion(error: nil)
          }
        }
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
        return  completion(error: authError(code: 0))
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
    
    static func logout() {
      Remote.Database.User.logout()
      try! FIRAuth.auth()!.signOut()
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
        print("device create")
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
          ref.child("users/\(user.uid)").updateChildValues([
            "email": email,
            "name": name,
            "active": true,
            ])
          linkDevice()
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
      static func create(title title: String) -> String? {
        if let user = Remote.Auth.user {
          let key = ref.child("notebooks").childByAutoId().key
          ref.child("notebooks/\(key)").updateChildValues([
            "title": title,
            "user": user.uid,
            "tags": [],
            "notes": [],
            "display": [],
            "active": true,
            "created": FIRServerValue.timestamp(),
            "updated": FIRServerValue.timestamp(),
            ])
          return key
        }
        return nil
      }
    }
    
    struct Note {
      static func create(notebook notebook: String, title: String, body: String?, completed: Bool, collapsed: Bool, children: Int, indent: Int) -> String? {
        if let user = Remote.Auth.user {
          let key = ref.child("notes").childByAutoId().key
          ref.child("notes/\(key)").updateChildValues([
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
            ])
          return key
        }
        return nil
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
          print("Config not fetched")
          print("Error \(error)")
          completion(config: nil)
        }
      }
    }
  }
}