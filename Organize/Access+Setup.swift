import UIKit

class AccessSetup {
  // MARK: - custom return types
  private enum KeyboardType {
    case Email
    case Password
    case Default
  }
  
  private struct ScrollViewObject {
    let view: UIScrollView
    var constraints: [NSLayoutConstraint]
    var bottom: NSLayoutConstraint
    var height: CGFloat
  }
  
  private struct TextFieldObject {
    let view: UITextField
    let constraints: [NSLayoutConstraint]
    let height: CGFloat
  }
  
  private struct ButtonObject {
    let view: UIButton
    let constraints: [NSLayoutConstraint]
    let height: CGFloat
  }
  
  private struct ButtonDoubleObject {
    let view: UIView
    let button1: UIButton
    let button2: UIButton
    let constraints: [NSLayoutConstraint]
    let height: CGFloat
  }
  
  private struct TextFieldDoubleObject {
    let view1: UIButton
    let view2: UIButton
    let constraints: [NSLayoutConstraint]
    let height: CGFloat
  }
  
  // MARK: - public functions
  static func createLogin(controller controller: UIViewController, email: UITextField, password: UITextField, login: UIButton, forgot: UIButton, signup: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewObject = createScrollViewObject(parent: controller.view)
    let emailObject: TextFieldObject = createTextFieldObject(textField: email, title: "email", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Email)
    let passwordObject: TextFieldObject = createTextFieldObject(textField: password, title: "password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false, keyboardType: .Password)
    let loginObject: ButtonObject = createButtonObject(button: login, title: "log in", view: controller.view, topItem: passwordObject.view, topAttribute: .Bottom, first: false)
    let forgotSignupObject: ButtonDoubleObject = createButtonDoubleObject(button1: forgot, button1Title: "reset password", button2: signup, button2Title: "create account", view: controller.view, topItem: loginObject.view, topAttribute: .Bottom, align: true, first: false)
    
    // views
    controller.view.addSubview(scrollViewObject.view)
    scrollViewObject.view.addSubview(emailObject.view)
    scrollViewObject.view.addSubview(passwordObject.view)
    scrollViewObject.view.addSubview(loginObject.view)
    scrollViewObject.view.addSubview(forgotSignupObject.view)
    
    // heights
    scrollViewObject.height += emailObject.height
    scrollViewObject.height += passwordObject.height
    scrollViewObject.height += loginObject.height
    scrollViewObject.height += forgotSignupObject.height
    scrollViewObject.view.contentSize = CGSize(width: 0, height: scrollViewObject.height)
    
    // constraints
    scrollViewObject.constraints += scrollViewObject.constraints
    scrollViewObject.constraints += emailObject.constraints
    scrollViewObject.constraints += passwordObject.constraints
    scrollViewObject.constraints += loginObject.constraints
    scrollViewObject.constraints += forgotSignupObject.constraints
    NSLayoutConstraint.activateConstraints(scrollViewObject.constraints)
    
    return scrollViewObject.bottom
  }
  
  
  static func createSignup(controller controller: UIViewController, email: UITextField, passwordOne: UITextField, passwordTwo: UITextField, signup: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewObject = createScrollViewObject(parent: controller.view)
    let emailObject: TextFieldObject = createTextFieldObject(textField: email, title: "email", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Email)
    let passwordOneObject: TextFieldObject = createTextFieldObject(textField: passwordOne, title: "password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false, keyboardType: .Password)
    let passwordTwoObject: TextFieldObject = createTextFieldObject(textField: passwordTwo, title: "confirm password", view: controller.view, topItem: passwordOneObject.view, topAttribute: .Bottom, first: false, keyboardType: .Password)
    let signupObject: ButtonObject = createButtonObject(button: signup, title: "sign up", view: controller.view, topItem: passwordTwoObject.view, topAttribute: .Bottom, first: false)
    
    // views
    controller.view.addSubview(scrollViewObject.view)
    scrollViewObject.view.addSubview(emailObject.view)
    scrollViewObject.view.addSubview(passwordOneObject.view)
    scrollViewObject.view.addSubview(passwordTwoObject.view)
    scrollViewObject.view.addSubview(signupObject.view)
    
    // heights
    scrollViewObject.height += emailObject.height
    scrollViewObject.height += passwordOneObject.height
    scrollViewObject.height += passwordTwoObject.height
    scrollViewObject.height += signupObject.height
    scrollViewObject.view.contentSize = CGSize(width: 0, height: scrollViewObject.height)
    
    // constraints
    scrollViewObject.constraints += scrollViewObject.constraints
    scrollViewObject.constraints += emailObject.constraints
    scrollViewObject.constraints += passwordOneObject.constraints
    scrollViewObject.constraints += passwordTwoObject.constraints
    scrollViewObject.constraints += signupObject.constraints
    NSLayoutConstraint.activateConstraints(scrollViewObject.constraints)
    
    return scrollViewObject.bottom
  }
  
  static func createForgot(controller controller: UIViewController, email: UITextField, forgot: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewObject = createScrollViewObject(parent: controller.view)
    let emailObject: TextFieldObject = createTextFieldObject(textField: email, title: "email", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Email)
    let forgotObject: ButtonObject = createButtonObject(button: forgot, title: "reset password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false)
    
    // views
    controller.view.addSubview(scrollViewObject.view)
    scrollViewObject.view.addSubview(emailObject.view)
    scrollViewObject.view.addSubview(forgotObject.view)
    
    // heights
    scrollViewObject.height += emailObject.height
    scrollViewObject.height += forgotObject.height
    scrollViewObject.view.contentSize = CGSize(width: 0, height: scrollViewObject.height)
    
    // constraints
    scrollViewObject.constraints += scrollViewObject.constraints
    scrollViewObject.constraints += emailObject.constraints
    scrollViewObject.constraints += forgotObject.constraints
    NSLayoutConstraint.activateConstraints(scrollViewObject.constraints)
    
    return scrollViewObject.bottom
  }
  
  // MARK: - private functions
  private static func padding(first first: Bool) -> CGFloat {
    return first ? Constant.Button.padding : Constant.Button.padding*2
  }
  
  private static func createController(controller controller: UIViewController) {
    // prevent flash of gray when transitioning between controllers
    controller.view.backgroundColor = Constant.Color.background
    
    // add navigation title
    controller.navigationItem.title = Constant.App.name
    
    // remove back button text
    controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }
  
  private static func createScrollViewObject(parent parent: UIView) -> ScrollViewObject {
    // scrollview
    let view: UIScrollView = UIScrollView()
    let bottom: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: 0)
    let height: CGFloat = Constant.Button.padding*2
    view.translatesAutoresizingMaskIntoConstraints = false
    
    // constraints
    var constraints: [NSLayoutConstraint] = []
    constraints.append(bottom)
    constraints.append(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: parent, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: parent, attribute: .Trailing, multiplier: 1, constant: 0))
    
    // object
    let scrollViewObject = ScrollViewObject(view: view, constraints: constraints, bottom: bottom, height: height)
    return scrollViewObject
  }
  
  private static func createTextFieldObject(textField textField: UITextField, title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, first: Bool, keyboardType: KeyboardType) -> TextFieldObject {
    // textfield
    textField.placeholder = title
    textField.borderStyle = .RoundedRect
    textField.tintColor = Constant.Color.button
    textField.keyboardType = keyboardType == .Email ? .EmailAddress : .Default
    textField.returnKeyType = .Next
    textField.secureTextEntry = keyboardType == .Password ? true : false
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    // constraints
    let topPadding: CGFloat = padding(first: first)
    var constraints: [NSLayoutConstraint] = []
    constraints.append(NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topPadding))
    constraints.append(NSLayoutConstraint(item: textField, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: textField, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Width, multiplier: Constant.Button.widthMultiplier, constant: Constant.Button.widthConstant(padding: padding(first: false))))
    constraints.append(NSLayoutConstraint(item: textField, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    
    // object
    let height: CGFloat = Constant.Button.height+topPadding
    let textFieldObject = TextFieldObject(view: textField, constraints: constraints, height: height)
    return textFieldObject
  }
  
  private static func createButtonObject(button button: UIButton, title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, first: Bool) -> ButtonObject {
    // button
    button.setTitle(title, forState: .Normal)
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.backgroundColor = Constant.Color.button
    button.translatesAutoresizingMaskIntoConstraints = false
    
    // constraints
    let topPadding: CGFloat = padding(first: first)
    var constraints: [NSLayoutConstraint] = []
    constraints.append(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topPadding))
    constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Width, multiplier: Constant.Button.widthMultiplier, constant: Constant.Button.widthConstant(padding: padding(first: false))))
    constraints.append(NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    
    // object
    let height: CGFloat = Constant.Button.height+topPadding
    let buttonObject = ButtonObject(view: button, constraints: constraints, height: height)
    return buttonObject
  }
  
  private static func createButtonDoubleObject(button1 button1: UIButton, button1Title: String, button2: UIButton, button2Title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, align: Bool, first: Bool) -> ButtonDoubleObject {
    // container
    let topPadding: CGFloat = padding(first: first)
    let container: UIView = UIView()
    var constraints: [NSLayoutConstraint] = []
    container.addSubview(button1)
    container.addSubview(button2)
    container.translatesAutoresizingMaskIntoConstraints = false
    constraints.append(NSLayoutConstraint(item: container, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topPadding))
    constraints.append(NSLayoutConstraint(item: container, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: container, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Width, multiplier: Constant.Button.widthMultiplier, constant: Constant.Button.widthConstant(padding: padding(first: false))))
    constraints.append(NSLayoutConstraint(item: container, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    
    // buttons
    func setupButton(button button: UIButton, title: String, align: UIControlContentHorizontalAlignment) {
      button.setTitle(title, forState: .Normal)
      button.backgroundColor = Constant.Color.background
      button.contentHorizontalAlignment = align
      button.setTitleColor(Constant.Color.button, forState: .Normal)
      button.translatesAutoresizingMaskIntoConstraints = false
    }
    setupButton(button: button1, title: button1Title, align: align ? .Left : .Center)
    setupButton(button: button2, title: button2Title, align: align ? .Right : .Center)
    
    constraints.append(NSLayoutConstraint(item: button1, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button1, attribute: .Leading, relatedBy: .Equal, toItem: container, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button1, attribute: .Trailing, relatedBy: .Equal, toItem: button2, attribute: .Leading, multiplier: 1, constant: -Constant.Button.padding*2))
    constraints.append(NSLayoutConstraint(item: button1, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button1, attribute: .Width, relatedBy: .Equal, toItem: button2, attribute: .Width, multiplier: 1, constant: 0))
    
    constraints.append(NSLayoutConstraint(item: button2, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button2, attribute: .Leading, relatedBy: .Equal, toItem: button1, attribute: .Trailing, multiplier: 1, constant: Constant.Button.padding*2))
    constraints.append(NSLayoutConstraint(item: button2, attribute: .Trailing, relatedBy: .Equal, toItem: container, attribute: .Trailing, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button2, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: button2, attribute: .Width, relatedBy: .Equal, toItem: button1, attribute: .Width, multiplier: 1, constant: 0))
    
    // object
    let height: CGFloat = Constant.Button.height+topPadding
    let buttonDoubleObject = ButtonDoubleObject(view: container, button1: button1, button2: button2, constraints: constraints, height: height)
    return buttonDoubleObject
  }
}