import UIKit

private struct DoubleColumn<T, E> {
  let view: UIView
  let item1: T
  let item2: E
  let constraints: [NSLayoutConstraint]
  let height: CGFloat
}

private struct SingleColumn<T> {
  let view: T
  let constraints: [NSLayoutConstraint]
  let height: CGFloat
}

private struct ScrollViewColumn {
  let view: UIScrollView
  var constraints: [NSLayoutConstraint]
  var bottom: NSLayoutConstraint
  var height: CGFloat
}


class AccessSetup {
  // MARK: - custom return types
  private enum KeyboardType {
    case Email
    case Password
    case Default
  }
  
  // MARK: - public functions -
  // MARK: - create
  static func createLogin(controller controller: UIViewController, email: UITextField, password: UITextField, login: UIButton, forgot: UIButton, signup: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewColumn = createScrollViewColumn(parent: controller.view)
    let emailObject: SingleColumn<UITextField> = createTextFieldColumn(textField: email, title: "email", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Email)
    let passwordObject: SingleColumn<UITextField> = createTextFieldColumn(textField: password, title: "password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false, keyboardType: .Password)
    let loginObject: SingleColumn<UIButton> = createButtonColumn(button: login, title: "Log In", view: controller.view, topItem: passwordObject.view, topAttribute: .Bottom, first: false)
    let forgotSignupObject: DoubleColumn<UIButton, UIButton> = createButtonDoubleColumn(button1: forgot, button1Title: "Reset Password", button2: signup, button2Title: "Create Account", view: controller.view, topItem: loginObject.view, topAttribute: .Bottom, align: true, first: false)
    
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
  
  static func createSignup(controller controller: UIViewController, firstName: UITextField, lastName: UITextField, email: UITextField, password: UITextField, signup: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewColumn = createScrollViewColumn(parent: controller.view)
    let nameObject: DoubleColumn<UITextField, UITextField> = createTextFieldDoubleColumn(textField1: firstName, textField1Title: "first name", textField2: lastName, textField2Title: "last name", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Default)
    let emailObject: SingleColumn<UITextField> = createTextFieldColumn(textField: email, title: "email", view: controller.view, topItem: nameObject.view, topAttribute: .Bottom, first: false, keyboardType: .Email)
    let passwordObject: SingleColumn<UITextField> = createTextFieldColumn(textField: password, title: "password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false, keyboardType: .Password)
    let signupObject: SingleColumn<UIButton> = createButtonColumn(button: signup, title: "Sign Up", view: controller.view, topItem: passwordObject.view, topAttribute: .Bottom, first: false)
    
    // views
    controller.view.addSubview(scrollViewObject.view)
    scrollViewObject.view.addSubview(nameObject.view)
    scrollViewObject.view.addSubview(emailObject.view)
    scrollViewObject.view.addSubview(passwordObject.view)
    scrollViewObject.view.addSubview(signupObject.view)
    
    // heights
    scrollViewObject.height += nameObject.height
    scrollViewObject.height += emailObject.height
    scrollViewObject.height += passwordObject.height
    scrollViewObject.height += signupObject.height
    scrollViewObject.view.contentSize = CGSize(width: 0, height: scrollViewObject.height)
    
    // constraints
    scrollViewObject.constraints += scrollViewObject.constraints
    scrollViewObject.constraints += nameObject.constraints
    scrollViewObject.constraints += emailObject.constraints
    scrollViewObject.constraints += passwordObject.constraints
    scrollViewObject.constraints += signupObject.constraints
    NSLayoutConstraint.activateConstraints(scrollViewObject.constraints)
    
    return scrollViewObject.bottom
  }
  
  static func createForgot(controller controller: UIViewController, email: UITextField, forgot: UIButton) -> NSLayoutConstraint {
    // create
    createController(controller: controller)
    var scrollViewObject: ScrollViewColumn = createScrollViewColumn(parent: controller.view)
    let emailObject: SingleColumn<UITextField> = createTextFieldColumn(textField: email, title: "email", view: controller.view, topItem: scrollViewObject.view, topAttribute: .Top, first: true, keyboardType: .Email)
    let forgotObject: SingleColumn<UIButton> = createButtonColumn(button: forgot, title: "Reset Password", view: controller.view, topItem: emailObject.view, topAttribute: .Bottom, first: false)
    
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
  
  // MARK: - private functions -
  
  // MARK: - create
  private static func createController(controller controller: UIViewController) {
    // prevent flash of gray when transitioning between controllers
    controller.view.backgroundColor = Constant.Color.background
    
    // add navigation title
    controller.navigationItem.title = Constant.App.name
    
    // remove back button text
    controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }
  
  private static func createScrollViewColumn(parent parent: UIView) -> ScrollViewColumn {
    // scrollview
    let scrollView: UIScrollView = UIScrollView()
    let bottom: NSLayoutConstraint = NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: 0)
    let height: CGFloat = Constant.Button.padding*2
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    // constraints
    var constraints: [NSLayoutConstraint] = []
    constraints.append(bottom)
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: parent, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: parent, attribute: .Trailing, multiplier: 1, constant: 0))
    
    // object
    let scrollViewObject = ScrollViewColumn(view: scrollView, constraints: constraints, bottom: bottom, height: height)
    return scrollViewObject
  }
  
  private static func createTextFieldColumn(textField textField: UITextField, title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, first: Bool, keyboardType: KeyboardType) -> SingleColumn<UITextField> {
    // textfield
    let textField = setupTextField(textField: textField, title: title, keyboardType: keyboardType)
    
    // constraints
    let constraints: [NSLayoutConstraint] = setupConstraintsFull(item: textField, view: view, topItem: topItem, topAttribute: topAttribute, topPadding: setupTopPadding(first: first))
    
    // object
    let textFieldObject = SingleColumn(view: textField, constraints: constraints, height: setupScrollViewHeight(first: first))
    return textFieldObject
  }
  
  private static func createButtonColumn(button button: UIButton, title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, first: Bool) ->  SingleColumn<UIButton> {
    // button
    let button = setupButton(button: button, title: title, background: true, alignment: .Center)
    
    // constraints
    let constraints: [NSLayoutConstraint] = setupConstraintsFull(item: button, view: view, topItem: topItem, topAttribute: topAttribute, topPadding: setupTopPadding(first: first))
    
    // object
    let buttonObject = SingleColumn(view: button, constraints: constraints, height: setupScrollViewHeight(first: first))
    return buttonObject
  }
  
  private static func createButtonDoubleColumn(button1 button1: UIButton, button1Title: String, button2: UIButton, button2Title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, align: Bool, first: Bool) -> DoubleColumn<UIButton, UIButton> {
    // container
    let container: UIView = setupContainer(item1: button1, item2: button2)
    
    // buttons
    let button1 = setupButton(button: button1, title: button1Title, background: false, alignment: align ? .Left : .Center)
    let button2 = setupButton(button: button2, title: button2Title, background: false, alignment: align ? .Right : .Center)
    
    // constraints
    let constraints: [NSLayoutConstraint] = setupConstraintsHalf(container: container, item1: button1, item2: button2, view: view, topItem: topItem, topAttribute: topAttribute, topPadding: setupTopPadding(first: first))
    
    // object
    let doubleColumn = DoubleColumn(view: container, item1: button1, item2: button2, constraints: constraints, height: setupScrollViewHeight(first: first))
    return doubleColumn
  }
  
  private static func createTextFieldDoubleColumn(textField1 textField1: UITextField, textField1Title: String, textField2: UITextField, textField2Title: String, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, first: Bool, keyboardType: KeyboardType) -> DoubleColumn<UITextField, UITextField> {
    // container
    let container: UIView = setupContainer(item1: textField1, item2: textField2)
    
    // buttons
    let textField1 = setupTextField(textField: textField1, title: textField1Title, keyboardType: keyboardType)
    let textField2 = setupTextField(textField: textField2, title: textField2Title, keyboardType: keyboardType)
    
    // constraints
    let constraints: [NSLayoutConstraint] = setupConstraintsHalf(container: container, item1: textField1, item2: textField2, view: view, topItem: topItem, topAttribute: topAttribute, topPadding: setupTopPadding(first: first))
    
    // object
    let doubleColumn = DoubleColumn(view: container, item1: textField1, item2: textField1, constraints: constraints, height: setupScrollViewHeight(first: first))
    return doubleColumn
  }
  
  // MARK: - setup
  private static func setupTopPadding(first first: Bool) -> CGFloat {
    return first ? Constant.Button.padding : Constant.Button.padding*2
  }
  
  private static func setupScrollViewHeight(first first: Bool) -> CGFloat {
    return Constant.Button.height+setupTopPadding(first: first)
  }
  
  private static func setupContainer(item1 item1: UIView, item2: UIView) -> UIView {
    let container: UIView = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(item1)
    container.addSubview(item2)
    
    return container
  }
  
  private static func setupTextField(textField textField: UITextField, title: String, keyboardType: KeyboardType) -> UITextField {
    textField.placeholder = title
    textField.borderStyle = .RoundedRect
    textField.tintColor = Constant.Color.button
    textField.keyboardType = keyboardType == .Email ? .EmailAddress : .Default
    textField.returnKeyType = .Next
    textField.secureTextEntry = keyboardType == .Password ? true : false
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.autoresizesSubviews = false
    textField.autocapitalizationType = .None
    
    return textField
  }
  
  private static func setupButton(button button: UIButton, title: String, background: Bool, alignment: UIControlContentHorizontalAlignment) -> UIButton {
    button.setTitle(title, forState: .Normal)
    button.layer.cornerRadius = 5
    button.clipsToBounds = true
    button.contentHorizontalAlignment = alignment
    // TODO: font size in Access button is 18 while rest of app is 17 (modals and settings)
    button.backgroundColor = background ? Constant.Color.button : Constant.Color.background
    button.setTitleColor(background ? Constant.Color.background : Constant.Color.button, forState: .Normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  private static func setupConstraintsFull(item item: UIView, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, topPadding: CGFloat) -> [NSLayoutConstraint]  {
    var constraints: [NSLayoutConstraint] = []
    constraints.append(NSLayoutConstraint(item: item, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topPadding))
    constraints.append(NSLayoutConstraint(item: item, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: item, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: Constant.Button.widthMultiplier, constant: Constant.Button.widthConstant(padding: setupTopPadding(first: false))))
    constraints.append(NSLayoutConstraint(item: item, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    
    return constraints
  }
  
  private static func setupConstraintsHalf(container container: UIView, item1: UIView, item2: UIView, view: UIView, topItem: UIView, topAttribute: NSLayoutAttribute, topPadding: CGFloat) -> [NSLayoutConstraint]  {
    var constraints: [NSLayoutConstraint] = []

    // container
    constraints.append(NSLayoutConstraint(item: container, attribute: .Top, relatedBy: .Equal, toItem: topItem, attribute: topAttribute, multiplier: 1, constant: topPadding))
    constraints.append(NSLayoutConstraint(item: container, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: container, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: Constant.Button.widthMultiplier, constant: Constant.Button.widthConstant(padding: setupTopPadding(first: false))))
    constraints.append(NSLayoutConstraint(item: container, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    
    // item 1
    constraints.append(NSLayoutConstraint(item: item1, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item1, attribute: .Leading, relatedBy: .Equal, toItem: container, attribute: .Leading, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item1, attribute: .Trailing, relatedBy: .Equal, toItem: item2, attribute: .Leading, multiplier: 1, constant: -Constant.Button.padding*2))
    constraints.append(NSLayoutConstraint(item: item1, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item1, attribute: .Width, relatedBy: .Equal, toItem: item2, attribute: .Width, multiplier: 1, constant: 0))
    
    // item 2
    constraints.append(NSLayoutConstraint(item: item2, attribute: .Top, relatedBy: .Equal, toItem: container, attribute: .Top, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item2, attribute: .Leading, relatedBy: .Equal, toItem: item1, attribute: .Trailing, multiplier: 1, constant: Constant.Button.padding*2))
    constraints.append(NSLayoutConstraint(item: item2, attribute: .Trailing, relatedBy: .Equal, toItem: container, attribute: .Trailing, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item2, attribute: .Bottom, relatedBy: .Equal, toItem: container, attribute: .Bottom, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: item2, attribute: .Width, relatedBy: .Equal, toItem: item1, attribute: .Width, multiplier: 1, constant: 0))
    
    return constraints
  }
}