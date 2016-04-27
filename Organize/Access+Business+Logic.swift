import UIKit

class AccessBusinessLogic {
  enum ErrorMessage {
    case Success
    case EmailInvalid
    case EmailMissing
    case EmailExists
    case PasswordInvalid
    case PasswordIncorrect
    case PasswordAgain
    
    var message: String {
      switch self {
      case .Success: return "success"
      case .EmailInvalid: return "invalid email"
      case .EmailExists: return "email already in use"
      case .EmailMissing: return "email does not exist"
      case .PasswordInvalid: return "passwords must be longer than 6 with uppercase, lowercase, and number characters"
      case .PasswordIncorrect: return "incorrect password"
      case .PasswordAgain: return "both password fields must be the same"
      }
    }
  }
  
  static func displayError(controller controller: UIViewController, error: ErrorMessage, completion: () -> ()) {
    // TODO: make custom alert modal instead of alert view
    let ac = UIAlertController(title: "Error", message: error.message, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .Default) { action in
      completion()
      })
    controller.presentViewController(ac, animated: true, completion: nil)
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
    
    if !emailExists(email: email) {
      return .EmailMissing
    }
    
    if !validEmailAndPassword(email: email, password: password) {
      return .PasswordIncorrect
    }
    
    return .Success
  }
  
  static func validateSignup(emailTextField emailTextField: UITextField, passwordOneTextField: UITextField, passwordTwoTextfield: UITextField) -> ErrorMessage {
    let email = textFieldToString(textField: emailTextField)
    let passwordOne = textFieldToString(textField: passwordOneTextField)
    let passwordTwo = textFieldToString(textField: passwordTwoTextfield)
    
    if !email.isEmail {
      return .EmailInvalid
    }
    
    if emailExists(email: email) {
      return .EmailExists
    }
    
    if !passwordOne.isPassword  {
      return .PasswordInvalid
    }
    
    if passwordOne != passwordTwo {
      return .PasswordAgain
    }
    
    return .Success
  }
  
  static func validateForgot(emailTextField emailTextField: UITextField) -> ErrorMessage {
    let email = textFieldToString(textField: emailTextField)
    if let user = getUser(email: email) {
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
    let email = textFieldToString(textField: emailTextField)
    let password = textFieldToString(textField: passwordTextField)
    
  }
  
  private static func getUser(email email: String) -> User? {
    return nil
  }
  
  static func loginUser(emailTextField emailTextField: UITextField, passwordTextField: UITextField) -> Bool {
    let email = textFieldToString(textField: emailTextField)
    let password = textFieldToString(textField: passwordTextField)
    
    return true
  }
  
}