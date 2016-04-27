import UIKit

class LoginViewController: UIViewController {
  // MARK: properties
  let emailTextField: UITextField = UITextField()
  let passwordTextField: UITextField = UITextField()
  let loginButton: UIButton = UIButton()
  let signupButton: UIButton = UIButton()
  let forgotButton: UIButton = UIButton()
  
  // MARK: load
  override func loadView() {
    super.loadView()
    setupView()
    setupGestures()
  }
  
  private func setupView() {
    AccessSetup.createLogin(controller: self, email: emailTextField, password: passwordTextField, login: loginButton, forgot: forgotButton, signup: signupButton)
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
  
  // MARK: buttons
  func attemptLogin(button: UIButton) {
    print("login")
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  func showSignup(button: UIButton) {
    navigationController?.pushViewController(SignupViewController(), animated: true)
  }
  
  func showForgot(button: UIButton) {
    navigationController?.pushViewController(ForgotViewController(), animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}
