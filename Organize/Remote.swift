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
  
  struct Auth {
    static let loadingModal: ModalLoading = ModalLoading()
    
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
    
    static var currentUser: FIRUser? {
      if let user = FIRAuth.auth()?.currentUser {
        for profile in user.providerData {
          print(profile)
          //          let providerID = profile.providerID
          //          let uid = profile.uid;  // Provider-specific UID
          //          let name = profile.displayName
          //          let email = profile.email
          //          let photoURL = profile.photoURL
        }
        return user
      } else {
        return nil
      }
    }
    
    static func signup(controller controller: UIViewController, email: String, password: String, name: String, completion: (error: String?) -> ()) {
      loadingModal.show(controller: controller)
      
      FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
        if let error = error {
          loadingModal.hide {
            completion(error: authError(code: error.code))
          }
        }
        if let user = user {
          let changeRequest = user.profileChangeRequest()
          changeRequest.displayName = name
          changeRequest.commitChangesWithCompletion() { (error) in
            loadingModal.hide {
              if let error = error {
                completion(error: authError(code: error.code))
              } else {
                completion(error: nil)
              }
            }
          }
        }
      }
    }
    
    static func login(controller controller: UIViewController, email: String, password: String, completion: (error: String?) -> ()) {
      loadingModal.show(controller: controller)
      FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
        loadingModal.hide {
          if let error = error {
            completion(error: authError(code: error.code))
          } else {
            completion(error: nil)
          }
        }
      }
    }
    
    static func resetPassword(controller controller: UIViewController, email: String, completion: (error: String?) -> ()) {
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
    
    static func changePassword() {
      
    }
    
    static func changeEmail() {
      
    }
    
    static func logout() {
      try! FIRAuth.auth()!.signOut()
    }
    
    static func delete(controller controller: UIViewController, completion: (error: String?) -> ()) {
      loadingModal.show(controller: controller)
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
    
    struct User {
      let ref = FIRDatabase.database().reference()
      
      func create() {
        
      }
      func update() {
        
      }
      func delete() {
        
      }
    }
    
    struct Note {
      
    }
    
    struct Notebook {
      
    }
    
    struct Tag {
      
    }
    
    
  }
  
}