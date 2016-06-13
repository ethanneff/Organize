import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  // MARK: - properties
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let loginButton: UIButton = UIButton()
  let facebookButton: UIButton = UIButton()
  let googleButton: UIButton = UIButton()
  let signupButton: UIButton = UIButton()
  let forgotButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  var recentlySignedUp: Bool = false
  lazy var signupController: SignupViewController = SignupViewController()
  lazy var forgotController: ForgotViewController = ForgotViewController()
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    setupView()
    setupKeyboard()
    listenKeyboard()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if let _ = Remote.Auth.user {
      dismissViewControllerAnimated(false, completion: nil)
    }
  }
  
  private func setupView() {
    bottomConstraint = AccessSetup.createLogin(controller: self, email: emailTextField, password: passwordTextField, login: loginButton, forgot: forgotButton, signup: signupButton)
    loginButton.addTarget(self, action: #selector(attemptLogin(_:)), forControlEvents: .TouchUpInside)
    signupButton.addTarget(self, action: #selector(showSignup(_:)), forControlEvents: .TouchUpInside)
    forgotButton.addTarget(self, action: #selector(showForgot(_:)), forControlEvents: .TouchUpInside)
  }
  
  // MARK: - deinit
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  // MARK: - keyboard
  private func setupKeyboard() {
    emailTextField.delegate = self
    passwordTextField.delegate = self
    UITextField.setTabOrder(fields: [emailTextField, passwordTextField])
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
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField === passwordTextField {
      attemptLogin(loginButton)
    }
    return true
  }
  
  
  // MARK: - buttons
  internal func attemptLogin(button: UIButton) {
    buttonPressed(button: button)
    
    // validate
    let email: String  = emailTextField.text!.trim
    let password: String  = passwordTextField.text!.trim
    
    if !email.isEmail {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.EmailInvalid.message, textField: emailTextField)
    }
    
    if password.isEmpty {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.PasswordMissing.message, textField: emailTextField)
    }
    
    // login
    Remote.Auth.login(controller: self, email: emailTextField.text!, password: passwordTextField.text!) { error in
      if let error = error {
        return AccessBusinessLogic.displayErrorAlert(controller: self, message: error, textField: self.emailTextField)
      }
      // save
      self.navigateToMenu()
    }
  }
  
  internal func showSignup(button: UIButton) {
    buttonPressed(button: button)
    clearTextFields()
    signupController.previousController = self
    navigationController?.pushViewController(signupController, animated: true)
  }
  
  internal func showForgot(button: UIButton) {
    buttonPressed(button: button)
    clearTextFields()
    navigationController?.pushViewController(forgotController, animated: true)
  }
  
  // MARK: - helper
  private func navigateToMenu() {
    Report.sharedInstance.track(event: "login")
    dismissViewControllerAnimated(false, completion: nil)
  }
  
  private func buttonPressed(button button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button)
  }
  
  private func clearTextFields() {
    emailTextField.text = ""
    passwordTextField.text = ""
  }
}
