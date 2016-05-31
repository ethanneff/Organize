import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
  // MARK: - properties
  let firstNameTextField: UITextField = UITextField()
  let lastNameTextField: UITextField = UITextField()
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let signupButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    setupView()
    setupKeyboard()
    listenKeyboard()
  }
  
  // MARK: - create
  private func setupView() {
    bottomConstraint = AccessSetup.createSignup(controller: self, firstName: firstNameTextField, lastName: lastNameTextField, email: emailTextField, password: passwordTextField, signup: signupButton)
    signupButton.addTarget(self, action: #selector(attemptSignup), forControlEvents: .TouchUpInside)
  }
  
  private func setupKeyboard() {
    firstNameTextField.becomeFirstResponder()
    firstNameTextField.delegate = self
    lastNameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
    UITextField.setTapOrder(fields: [firstNameTextField, lastNameTextField, emailTextField, passwordTextField])
  }
  
  // MARK: - buttons
  func attemptSignup() {
    dismissKeyboard()
    displayLoading(message: "Creating account")
    //    showActivityIndicatory(view)
    return
    
    //    let firstName: String = firstNameTextField.text!.trim
    //    let lastName: String  = lastNameTextField.text!.trim
    //    let email: String  = emailTextField.text!.trim
    //    let password: String  = passwordTextField.text!.trim
    //    let fullName = (firstName + lastName).trim
    //
    //    if firstName.isEmpty {
    //      return displayError(message: "Invalid first name", textField: firstNameTextField)
    //    }
    //
    //    if lastName.isEmpty {
    //      return displayError(message: "Invalid last name", textField: lastNameTextField)
    //    }
    //
    //    if !email.isEmail {
    //      return displayError(message: "Invalid email", textField: emailTextField)
    //    }
    //
    //    if !password.isPassword {
    //      return displayError(message: "Passwords must be longer than 6 with uppercase, lowercase, and number characters", textField: passwordTextField)
    //    }
    //
    //    Remote.Auth.signup(email: email, password: password, name: fullName) { (error) in
    //      if let error = error {
    //        return self.displayError(message: error, textField: nil)
    //      }
    //      self.dismissViewControllerAnimated(true, completion: nil)
    //    }
  }
  
  
  func displayError(message message: String, textField: UITextField?) {
    let ac = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .Default) { action in
      if let textField = textField {
        textField.becomeFirstResponder()
      }
      })
    presentViewController(ac, animated: true, completion: nil)
  }
  
  func displayLoading(message message: String) {
    let message = message + "\n\n\n"
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let indicator = UIActivityIndicatorView()
    alert.view.addSubview(indicator)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    indicator.color = Constant.Color.button
    indicator.startAnimating()
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: alert.view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: alert.view, attribute: .CenterY, multiplier: 1, constant: 0),
      ])

    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  // MARK: - keyboard
  func textFieldDidEndEditing(textField: UITextField) {
    //    if let email = emailTextField.text?.trim, let passwordOne = passwordOneTextField.text?.trim, let passwordTwo = passwordTwoTextField.text?.trim {
    //      if email.length > 0 && passwordOne.length > 0 && passwordTwo.length > 0 {
    //        attemptSignup()
    //      }
    //    }
  }
  
  private func textFieldClearAndSelect(textField textField: UITextField) {
    textField.text = ""
    textField.becomeFirstResponder()
  }
  
  private func listenKeyboard() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  internal func dismissKeyboard() {
    view.endEditing(true)
  }
  
  internal func keyboardNotification(notification: NSNotification) {
    if let bottomConstraint = bottomConstraint {
      Util.handleKeyboardScrollView(keyboardNotification: notification, scrollViewBottomConstraint: bottomConstraint, view: view)
    }
  }
}
