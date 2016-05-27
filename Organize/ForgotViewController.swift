import UIKit

class ForgotViewController: UIViewController {
  // MARK: - properties
  let emailTextField: UITextField = UITextField()
  let forgotButton: UIButton = UIButton()
  var bottomConstraint: NSLayoutConstraint?
  
  // MARK: - load
  override func loadView() {
    super.loadView()
    print("loadview")
    setupView()
    listenKeyboard()
  }
  
  private func setupView() {
    AccessSetup.createForgot(controller: self, email: emailTextField, forgot: forgotButton)
    forgotButton.addTarget(self, action: #selector(attemptForgot(_:)), forControlEvents: .TouchUpInside)
    emailTextField.becomeFirstResponder()
  }
  
  // MARK: - buttons
  func attemptForgot(button: UIButton) {
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
