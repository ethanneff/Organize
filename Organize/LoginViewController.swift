import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  // MARK: properties
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let loginButton: UIButton = UIButton()
  let facebookButton: UIButton = UIButton()
  let googleButton: UIButton = UIButton()
  let signupButton: UIButton = UIButton()
  let forgotButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  
  // MARK: load
  override func loadView() {
    super.loadView()
    setupView()
    setupGestures()
    createListeners()
  }
  
  private func setupView() {
    bottomConstraint = AccessSetup.createLogin(controller: self, email: emailTextField, password: passwordTextField, login: loginButton, forgot: forgotButton, signup: signupButton)
    loginButton.addTarget(self, action: #selector(attemptLogin(_:)), forControlEvents: .TouchUpInside)
    signupButton.addTarget(self, action: #selector(showSignup(_:)), forControlEvents: .TouchUpInside)
    forgotButton.addTarget(self, action: #selector(showForgot(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func setupGestures() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
    
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  // MARK: deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  
  // MARK: keyboard
  private func createListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  func keyboardNotification(notification: NSNotification) {
    if let bottomConstraint = bottomConstraint {
      Util.handleKeyboardScrollView(keyboardNotification: notification, scrollViewBottomConstraint: bottomConstraint, view: view)
    }
  }
  
  
  private func keyboardHeight(notification notification: NSNotification) -> CGFloat {
    if let info  = notification.userInfo, let value  = info[UIKeyboardFrameEndUserInfoKey] {
      let rawFrame = value.CGRectValue
      let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
      return keyboardFrame.height
    }
    return 0
  }
  
  // MARK: buttons
  func attemptLogin(button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button) {
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func showSignup(button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button) {
      self.clearTextFields()
      self.navigationController?.pushViewController(SignupViewController(), animated: true)
    }
  }
  
  func showForgot(button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button) {
      self.clearTextFields()
      self.navigationController?.pushViewController(ForgotViewController(), animated: true)
    }
  }
  
  private func clearTextFields() {
    emailTextField.text = ""
    passwordTextField.text = ""
  }
}
