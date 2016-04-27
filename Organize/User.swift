import Foundation

class User: NSObject, NSCoding {
  // PROPERTIES
  var email: String
  var password: String
  override var description: String {
    return "\(email)"
  }
  
  // INIT
  init?(email: String, password: String) {
    self.email = email
    self.password = password
    
    super.init()
    
    if email.isEmpty || password.isEmpty {
      return nil
    }
  }
  
  // SAVE
  struct PropertyKey {
    static let email = "email"
    static let password = "password"
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(email, forKey: PropertyKey.email)
    aCoder.encodeObject(password, forKey: PropertyKey.password)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let email = aDecoder.decodeObjectForKey(PropertyKey.email) as! String
    let password = aDecoder.decodeObjectForKey(PropertyKey.password) as! String
    self.init(email: email, password: password)
  }
  
  // ACCESS
  static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
  // TODO: save as user.email
  // TODO: get user.email from nsUserDefaults
  static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("user")
  
  static func get(completion completion: (user: User?) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? User {
        completion(user: data)
      } else {
        completion(user: nil)
      }
    })
  }
  
  static func set(data data: User, completion: (success: Bool) -> ()) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
      let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(data, toFile: User.ArchiveURL.path!)
      if !isSuccessfulSave {
        completion(success: false)
      } else {
        completion(success: true)
      }
    })
  }
}