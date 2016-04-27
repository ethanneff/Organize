import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
  // MARK: properties
  let emailTextField: UITextField = UITextField()
  let passwordOneTextField: UITextField = UITextField()
  let passwordTwoTextField: UITextField = UITextField()
  let signupButton: UIButton = UIButton()
  
  // MARK: load
  override func loadView() {
    super.loadView()
    setupView()
    setupKeyboard()
  }
  
  // MARK: create
  private func setupView() {
    AccessSetup.createSignup(controller: self, email: emailTextField, passwordOne: passwordOneTextField, passwordTwo: passwordTwoTextField, signup: signupButton)
    signupButton.addTarget(self, action: #selector(attemptSignup), forControlEvents: .TouchUpInside)
  }
  
  private func setupKeyboard() {
    emailTextField.becomeFirstResponder()
    emailTextField.delegate = self
    passwordOneTextField.delegate = self
    passwordTwoTextField.delegate = self
    UITextField.setTapOrder(fields: [emailTextField, passwordOneTextField, passwordTwoTextField])
  }
  
  // MARK: button
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
  
  // MARK: keyboard
  func textFieldDidEndEditing(textField: UITextField) {
    if let email = emailTextField.text?.trim, let passwordOne = passwordOneTextField.text?.trim, let passwordTwo = passwordTwoTextField.text?.trim {
      if email.length > 0 && passwordOne.length > 0 && passwordTwo.length > 0 {
        attemptSignup()
      }
    }
  }
  
  func textFieldClearAndSelect(textField textField: UITextField) {
    textField.text = ""
    textField.becomeFirstResponder()
  }
}
