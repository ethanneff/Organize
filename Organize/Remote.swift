//
//  Remote.swift
//  Organize
//
//  Created by Ethan Neff on 5/28/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation
import Firebase

class Remote {
  static let sharedInstance = Remote()
  
  struct Auth {
    func signup(email email: String, password: String) {
      FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
        print(user, error)
      }
    }
    
     func login(email email: String, password: String) {
      FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
        print(user, error)
      }
    }
    
    func logout() {
      try! FIRAuth.auth()!.signOut()
    }
  }

  struct Database {
    let ref = FIRDatabase.database().reference()
    
    
    struct User {
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