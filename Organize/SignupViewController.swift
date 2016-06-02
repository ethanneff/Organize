import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
  // MARK: - properties
  let firstNameTextField: UITextField = UITextField()
  let lastNameTextField: UITextField = UITextField()
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let signupButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  weak var previousController: LoginViewController?
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    setupView()
    setupKeyboard()
    listenKeyboard()
  }
  
  private func setupView() {
    bottomConstraint = AccessSetup.createSignup(controller: self, firstName: firstNameTextField, lastName: lastNameTextField, email: emailTextField, password: passwordTextField, signup: signupButton)
    signupButton.addTarget(self, action: #selector(attemptSignup(_:)), forControlEvents: .TouchUpInside)
  }
  
  // MARK: - appear
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    firstNameTextField.becomeFirstResponder()
  }
  
  // MARK: - buttons
  internal func attemptSignup(button: UIButton) {
    buttonPressed(button: button)
    
    let firstName: String = firstNameTextField.text!.trim
    let lastName: String  = lastNameTextField.text!.trim
    let email: String  = emailTextField.text!.trim
    let password: String  = passwordTextField.text!.trim
    let fullName = (firstName + lastName).trim
    
    if firstName.isEmpty {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.FirstNameInvalid.message, textField: firstNameTextField)
    }
    
    if lastName.isEmpty {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.LastNameInvalid.message, textField: lastNameTextField)
    }
    
    if !email.isEmail {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.EmailInvalid.message, textField: emailTextField)
    }
    
    if !password.isPassword {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.PasswordInvalid.message, textField: passwordTextField)
    }
    
    Remote.Auth.signup(controller: self, email: email, password: password, name: fullName) { (error) in
      if let error = error {
        return AccessBusinessLogic.displayErrorAlert(controller: self, message: error, textField: nil)
      }
      self.navigateToMenu()
    }
  }
  
  // MARK: - helper
  private func buttonPressed(button button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
  }
  
  private func navigateToMenu() {
    Report.sharedInstance.track(event: "signup")
    self.previousController?.recentlySignedUp = true
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    previousController = nil
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  // MARK: - keyboard
  private func setupKeyboard() {
    firstNameTextField.delegate = self
    lastNameTextField.delegate = self
    emailTextField.delegate = self
    passwordTextField.delegate = self
    UITextField.setTabOrder(fields: [firstNameTextField, lastNameTextField, emailTextField, passwordTextField])
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField === passwordTextField {
      attemptSignup(signupButton)
    }
    return true
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
