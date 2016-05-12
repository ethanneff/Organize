import UIKit

class ForgotViewController: UIViewController {
  
  let emailTextField: UITextField = UITextField()
  let forgotButton: UIButton = UIButton()
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    AccessSetup.createForgot(controller: self, email: emailTextField, forgot: forgotButton)
    forgotButton.addTarget(self, action: #selector(attemptForgot(_:)), forControlEvents: .TouchUpInside)
    emailTextField.becomeFirstResponder()
  }
  
  func attemptForgot(button: UIButton) {
  }
}
