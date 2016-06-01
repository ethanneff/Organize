import UIKit

class ForgotViewController: UIViewController {
  // MARK: - properties
  let emailTextField: UITextField = UITextField()
  let forgotButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    setupView()
    listenKeyboard()
  }
  
  private func setupView() {
    AccessSetup.createForgot(controller: self, email: emailTextField, forgot: forgotButton)
    forgotButton.addTarget(self, action: #selector(attemptForgot(_:)), forControlEvents: .TouchUpInside)
  }
  
  // MARK: - appear
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    emailTextField.becomeFirstResponder()
  }
  
  // MARK: - buttons
  func attemptForgot(button: UIButton) {
    buttonPressed(button: button)
    
    // validate
    let email: String  = emailTextField.text!.trim
    
    if !email.isEmail {
      return AccessBusinessLogic.displayErrorAlert(controller: self, message: AccessBusinessLogic.ErrorMessage.EmailInvalid.message, textField: emailTextField)
    }
    
    // reset
    Remote.Auth.reset(controller: self, email: email) { (error) in
      if let error = error {
        AccessBusinessLogic.displayErrorAlert(controller: self, message: error, textField: self.emailTextField)
      } else {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
  }
  
  private func buttonPressed(button button: UIButton) {
    dismissKeyboard()
    Util.animateButtonPress(button: button)
  }
  
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
  }
  
  // MARK: - keyboard
  private func listenKeyboard() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func keyboardNotification(notification: NSNotification) {
    if let bottomConstraint = bottomConstraint {
      Util.handleKeyboardScrollView(keyboardNotification: notification, scrollViewBottomConstraint: bottomConstraint, view: view)
    }
  }
}
