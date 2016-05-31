import UIKit

class AccessBusinessLogic {
  enum ErrorMessage {
    case Success
    case FirstNameInvalid
    case LastNameInvalid
    case EmailInvalid
    case EmailMissing
    case EmailExists
    case PasswordInvalid
    case PasswordIncorrect
    
    var message: String {
      switch self {
      case .Success: return "Success"
      case .FirstNameInvalid: return "Invalid first name"
      case .LastNameInvalid: return "Invalid last name"
      case .EmailInvalid: return "Invalid email"
      case .EmailExists: return "Email already in use"
      case .EmailMissing: return "Email does not exist"
      case .PasswordInvalid: return "Passwords must be longer than 6 with uppercase, lowercase, and numbers"
      case .PasswordIncorrect: return "Incorrect password"
      }
    }
  }
  
  static func displayError(controller controller: UIViewController, error: ErrorMessage, completion: () -> ()) {
    let ac = UIAlertController(title: error.message, message: nil, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .Default) { action in
      completion()
      })
    controller.presentViewController(ac, animated: true, completion: nil)
  }
  
  static func textFieldClearAndSelect(textField textField: UITextField) {
    textField.text = ""
    textField.becomeFirstResponder()
  }
  
  static func validateLogin(emailTextField emailTextField: UITextField, passwordTextField: UITextField) -> ErrorMessage {
    let email = textFieldToString(textField: emailTextField)
    let password = textFieldToString(textField: passwordTextField)
    
    if !email.isEmail {
      return .EmailInvalid
    }
    
    if !password.isPassword  {
      return .PasswordInvalid
    }
    
    return .Success
  }
  
  static func validateSignup(firstName firstName: UITextField, lastName: UITextField, email: UITextField, password: UITextField) -> ErrorMessage {
    let firstName: String = textFieldToString(textField: firstName)
    let lastName: String = textFieldToString(textField: lastName)
    let email: String = textFieldToString(textField: email)
    let password: String = textFieldToString(textField: password)
    
    if firstName.isEmpty {
      return .FirstNameInvalid
    }
    if lastName.isEmpty {
      return .LastNameInvalid
    }
    
    if !email.isEmail {
      return .EmailInvalid
    }
    
    if !password.isPassword  {
      return .PasswordInvalid
    }
    
    return .Success
  }
  
  static func validateForgot(emailTextField emailTextField: UITextField) -> ErrorMessage {
    let email = textFieldToString(textField: emailTextField)
    if let user = getUser(email: email) {
      user.email = "TODO"
      // TODO: todo send email with password
      return .Success
    } else {
      return .EmailInvalid
    }
  }
  
  private static func emailExists(email email: String) -> Bool {
    return false
  }
  
  private static func validEmailAndPassword(email email: String, password: String) -> Bool {
    return true
  }
  
  private static func textFieldToString(textField textField: UITextField) -> String {
    return textField.text!.trim
  }
  
  static func createUser(emailTextField emailTextField: UITextField, passwordTextField: UITextField) {
    //    let email = textFieldToString(textField: emailTextField)
    //    let password = textFieldToString(textField: passwordTextField)
    
  }
  
  private static func getUser(email email: String) -> User? {
    return nil
  }
  
  static func loginUser(emailTextField emailTextField: UITextField, passwordTextField: UITextField) -> Bool {
    //    let email = textFieldToString(textField: emailTextField)
    //    let password = textFieldToString(textField: passwordTextField)
    
    return true
  }
  
}