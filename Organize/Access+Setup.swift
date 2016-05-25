import UIKit

class AccessSetup {
  static let padding: CGFloat = 20
  static let textFieldHeight: CGFloat = 40
  
  private enum KeyboardType {
    case Email
    case Password
    case Default
  }
  
  static func createLogin(controller controller: UIViewController, email: UITextField, password: UITextField, login: UIButton, forgot: UIButton, signup: UIButton) {
    controller.view.addSubview(email)
    controller.view.addSubview(password)
    controller.view.addSubview(login)
    controller.view.addSubview(signup)
    controller.view.addSubview(forgot)
    
    createController(controller: controller)
    
    var constraints: [NSLayoutConstraint] = []
    constraints += createTextField(textField: email, title: "email", view: controller.view, topAnchor: controller.view.topAnchor, type: .Email)
    constraints += createTextField(textField: password, title: "password", view: controller.view, topAnchor: email.bottomAnchor, type: .Password)
    constraints += createButton(button: login, title: "log in", view: controller.view, topAnchor: password.bottomAnchor)
    constraints += createLink(button: forgot, title: "forgot password", view: controller.view, align: .Left, topAnchor: login.bottomAnchor, leadingAnchor: login.leadingAnchor, trailingAnchor: signup.leadingAnchor, widthAnchor: signup.widthAnchor)
    constraints += createLink(button: signup, title: "create account", view: controller.view, align: .Right, topAnchor: login.bottomAnchor, leadingAnchor: forgot.trailingAnchor, trailingAnchor: login.trailingAnchor, widthAnchor: forgot.widthAnchor)
    // performance boost over .active = true
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  static func createSignup(controller controller: UIViewController, email: UITextField, passwordOne: UITextField, passwordTwo: UITextField, signup: UIButton) {
    controller.view.addSubview(email)
    controller.view.addSubview(passwordOne)
    controller.view.addSubview(passwordTwo)
    controller.view.addSubview(signup)
    
    createController(controller: controller)
    
    var constraints: [NSLayoutConstraint] = []
    constraints += createTextField(textField: email, title: "email", view: controller.view, topAnchor: controller.view.topAnchor, type: .Email)
    constraints += createTextField(textField: passwordOne, title: "password", view: controller.view, topAnchor: email.bottomAnchor, type: .Password)
    constraints += createTextField(textField: passwordTwo, title: "password again", view: controller.view, topAnchor: passwordOne.bottomAnchor, type: .Password)
    constraints += createButton(button: signup, title: "sign up", view: controller.view, topAnchor: passwordTwo.bottomAnchor)
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  static func createForgot(controller controller: UIViewController, email: UITextField, forgot: UIButton) {
    controller.view.addSubview(email)
    controller.view.addSubview(forgot)
    
    createController(controller: controller)
    
    var constraints: [NSLayoutConstraint] = []
    constraints += createTextField(textField: email, title: "email", view: controller.view, topAnchor: controller.view.topAnchor, type: .Email)
    constraints += createButton(button: forgot, title: "retrieve password", view: controller.view, topAnchor: email.bottomAnchor)
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  private static func createController(controller controller: UIViewController) {
    // prevent flash of gray when transitioning between controllers
    controller.view.backgroundColor = Constant.Color.background
    // add navigation title
    controller.navigationItem.title = Constant.App.name
    // remove back button text
    controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }
  
  private static func createTextField(textField textField: UITextField, title: String, view: UIView, topAnchor: NSLayoutYAxisAnchor, type: KeyboardType) -> [NSLayoutConstraint] {
    textField.placeholder = title
    textField.borderStyle = .RoundedRect
    textField.tintColor = Constant.Color.button
    textField.keyboardType = type == .Email ? .EmailAddress : .Default
    textField.returnKeyType = .Next
    textField.secureTextEntry = type == .Password ? true : false
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    return [
      textField.topAnchor.constraintEqualToAnchor(topAnchor, constant: padding),
      textField.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: padding),
      textField.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -padding),
      textField.heightAnchor.constraintEqualToConstant(textFieldHeight),
    ]
  }
  
  private static func createButton(button button: UIButton, title: String, view: UIView, topAnchor: NSLayoutYAxisAnchor) -> [NSLayoutConstraint] {
    button.setTitle(title, forState: .Normal)
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = Constant.Color.button
    button.setBackgroundImage(Constant.Color.button.image, forState: .Normal)
    button.setBackgroundImage(Constant.Color.shadow.image, forState: .Highlighted)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return [
      button.topAnchor.constraintEqualToAnchor(topAnchor, constant: padding),
      button.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: padding),
      button.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -padding),
      button.heightAnchor.constraintEqualToConstant(textFieldHeight),
    ]
  }
  
  private static func createLink(button button: UIButton, title: String, view: UIView, align: UIControlContentHorizontalAlignment, topAnchor: NSLayoutYAxisAnchor, leadingAnchor: NSLayoutXAxisAnchor, trailingAnchor: NSLayoutXAxisAnchor, widthAnchor: NSLayoutDimension) -> [NSLayoutConstraint] {
    button.setTitle(title, forState: .Normal)
    button.backgroundColor = Constant.Color.background
    button.contentHorizontalAlignment = align
    button.setTitleColor(Constant.Color.button, forState: .Normal)
    button.setTitleColor(Constant.Color.shadow, forState: .Highlighted)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return [
      button.topAnchor.constraintEqualToAnchor(topAnchor, constant: padding),
      button.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
      button.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
      button.heightAnchor.constraintEqualToConstant(textFieldHeight),
      button.widthAnchor.constraintEqualToAnchor(widthAnchor),
    ]
  }
  
}