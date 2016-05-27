import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
  // MARK: - properties
  let emailTextField: UITextField = UITextField()
  let passwordOneTextField: UITextField = UITextField()
  let passwordTwoTextField: UITextField = UITextField()
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
    bottomConstraint = AccessSetup.createSignup(controller: self, email: emailTextField, passwordOne: passwordOneTextField, passwordTwo: passwordTwoTextField, signup: signupButton)
    signupButton.addTarget(self, action: #selector(attemptSignup), forControlEvents: .TouchUpInside)
  }
  
  private func setupKeyboard() {
    emailTextField.becomeFirstResponder()
    emailTextField.delegate = self
    passwordOneTextField.delegate = self
    passwordTwoTextField.delegate = self
    UITextField.setTapOrder(fields: [emailTextField, passwordOneTextField, passwordTwoTextField])
  }
  
  // MARK: - buttons
  func attemptSignup() {
    let error = AccessBusinessLogic.validateSignup(emailTextField: emailTextField, passwordOneTextField: passwordOneTextField, passwordTwoTextfield: passwordTwoTextField)
    if error == .Success {
      AccessBusinessLogic.createUser(emailTextField: emailTextField, passwordTextField: passwordOneTextField)
      dismissViewControllerAnimated(true, completion: nil)
    } else {
      AccessBusinessLogic.displayError(controller: self, error: error) {
        switch error {
        case .PasswordInvalid: self.textFieldClearAndSelect(textField: self.passwordOneTextField)
        case .PasswordAgain: self.textFieldClearAndSelect(textField: self.passwordTwoTextField)
        default: self.textFieldClearAndSelect(textField: self.emailTextField)
        }
      }
    }
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
    if let email = emailTextField.text?.trim, let passwordOne = passwordOneTextField.text?.trim, let passwordTwo = passwordTwoTextField.text?.trim {
      if email.length > 0 && passwordOne.length > 0 && passwordTwo.length > 0 {
        attemptSignup()
      }
    }
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
