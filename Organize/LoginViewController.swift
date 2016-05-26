import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
  // MARK: properties
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let loginButton: UIButton = UIButton()
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
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  // MARK: deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  
  // MARK: keyboard
  private func createListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    bottomConstraint!.constant = -keyboardHeight(notification: notification)
    print(bottomConstraint)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    bottomConstraint!.constant = 0
    print(bottomConstraint)
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
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func showSignup(button: UIButton) {
    clearTextFields()
    navigationController?.pushViewController(SignupViewController(), animated: true)
  }
  
  func showForgot(button: UIButton) {
    clearTextFields()
    navigationController?.pushViewController(ForgotViewController(), animated: true)
  }
  
  private func clearTextFields() {
    emailTextField.text = ""
    passwordTextField.text = ""
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}
