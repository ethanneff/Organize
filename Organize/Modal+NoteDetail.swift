//import UIKit
//
//protocol ModalNoteDetailDelegate: class {
//  func modalNoteDetailDisplay(indexPath indexPath: NSIndexPath, create: Bool)
//  func modalNoteDetailValue(indexPath indexPath: NSIndexPath, note: Note, create: Bool)
//}
//
//class ModalNoteDetailViewController: UIViewController, UITextViewDelegate {
//  // MARK: - properties
//  weak var delegate: ModalNoteDetailDelegate?
//  weak var data: Note?
//  var indexPath: NSIndexPath?
//  
//  let modal: UIView = UIView()
//  
//  var titleTextView: UITextView?
//  var titleTextViewPlaceHolder: UILabel?
//  let modalPadding: CGFloat = 25
//  var modalBottomConstraint: NSLayoutConstraint?
//  var tapGesture: UITapGestureRecognizer?
//  var panGesture: UIPanGestureRecognizer?
//  
//  
//  // MARK: - deinit
//  deinit {
//    dealloc()
//  }
//  
//  private func dealloc() {
//    titleTextView = nil
//    titleTextViewPlaceHolder = nil
//    delegate = nil
//    data = nil
//    tapGesture = nil
//    panGesture = nil
//    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    Modal.clear(background: view)
//  }
//  
//  
//  // MARK: - open
//  override func viewWillAppear(animated: Bool) {
//    super.viewWillAppear(animated)
//    Modal.animateIn(modal: modal, background: view, completion: nil)
//    titleTextView?.text = data?.title
//    titleTextView?.becomeFirstResponder()
//  }
//  
//  override func viewDidAppear(animated: Bool) {
//    super.viewDidAppear(animated)
//    handleTitlePlaceholderAndCursor()
//  }
//  
//  
//  // MARK: - close
//  private func close(confirm confirm: Bool, note: Note?, create: Bool?) {
//    Modal.animateOut(modal: modal, background: view) {
//      self.dismissViewControllerAnimated(false, completion: nil)
//      if let note = note, create = create, indexPath = self.indexPath where confirm {
//        self.delegate?.modalNoteDetailValue(indexPath: indexPath, note: note, create: create)
//      }
//    }
//  }
//  
//  
//  // MARK: - create
//  override func loadView() {
//    super.loadView()
//    setupView()
//    createGestures()
//    createListeners()
//  }
//  
//  private func createGestures() {
//    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_:)))
//    panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPressed(_:)))
//    view.addGestureRecognizer(panGesture!)
//    view.addGestureRecognizer(tapGesture!)
//  }
//  
//  private func createListeners() {
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
//  }
//  
//  private func setupView() {
//    let yes = createButton(title: Modal.textYes, confirm: true)
//    let no = createButton(title: Modal.textNo, confirm: false)
//    let topSeparator = Modal.createSeparator()
//    let midSeparator = Modal.createSeparator()
//    
//    titleTextView = createTextView()
//    titleTextViewPlaceHolder = createPlaceHolderLabel(textView: titleTextView!)
//    
//    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
//    
//    modal.addSubview(titleTextView!)
//    modal.addSubview(yes)
//    modal.addSubview(no)
//    modal.addSubview(topSeparator)
//    modal.addSubview(midSeparator)
//    
//    modalBottomConstraint = NSLayoutConstraint(item: modal, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -modalPadding)
//    
//    NSLayoutConstraint.activateConstraints([
//      modalBottomConstraint!,
//      NSLayoutConstraint(item: modal, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: modalPadding),
//      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: modalPadding*4),
//      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
//      
//      NSLayoutConstraint(item: titleTextView!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*2),
//      
//      // TODO: next 4 are the same as datePicker
//      NSLayoutConstraint(item: no, attribute: .Trailing, relatedBy: .Equal, toItem: midSeparator, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      
//      NSLayoutConstraint(item: yes, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Leading, relatedBy: .Equal, toItem: midSeparator, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      NSLayoutConstraint(item: yes, attribute: .Width, relatedBy: .Equal, toItem: no, attribute: .Width, multiplier: 1, constant: 0),
//      
//      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: yes, attribute: .Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      
//      NSLayoutConstraint(item: midSeparator, attribute: .Leading, relatedBy: .Equal, toItem: no, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Height, relatedBy: .Equal, toItem: no, attribute: .Height, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      ])
//  }
//  
//  private func createTextView() -> UITextView {
//    let textView = UITextView()
//    textView.tag = 1
//    textView.delegate = self
//    textView.returnKeyType = .Done
//    textView.textAlignment = .Center
//    textView.font = UIFont.boldSystemFontOfSize(Modal.textSize)
//    textView.translatesAutoresizingMaskIntoConstraints = false
//    textView.tintColor = Constant.Color.button
//    
//    return textView
//  }
//  
//  private func createPlaceHolderLabel(textView textView: UITextView) -> UILabel {
//    let label = UILabel()
//    label.text = "Title"
//    label.font = .boldSystemFontOfSize(textView.font!.pointSize)
//    label.sizeToFit()
//    label.textColor = Constant.Color.border
//    label.hidden = !textView.text.isEmpty
//    label.textAlignment = textView.textAlignment
//    textView.addSubview(label)
//    
//    return label
//  }
//  
//  private func createButton(title title: String, confirm: Bool) -> UIButton {
//    let button = UIButton()
//    button.tag = Int(confirm)
//    button.layer.cornerRadius = Modal.radius
//    button.setTitle(title, forState: .Normal)
//    button.setTitleColor(Constant.Color.button, forState: .Normal)
//    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
//    button.titleLabel?.font = confirm ? .systemFontOfSize(Modal.textSize) : .boldSystemFontOfSize(Modal.textSize)
//    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
//    button.translatesAutoresizingMaskIntoConstraints = false
//    
//    return button
//  }
//  
//  
//  // MARK: - gestures
//  func tapPressed(gesture: UITapGestureRecognizer) {
//    view.endEditing(true)
//  }
//  
//  func panPressed(gesture: UIPanGestureRecognizer) {
//    view.endEditing(true)
//  }
//  
//  
//  // MARK: - keybaord
//  func keyboardWillShow(notification: NSNotification) {
//    moveModalWithKeyboard(constant: -keyboardHeight(notification: notification)-modalPadding)
//  }
//  
//  func keyboardWillHide(notification: NSNotification) {
//    moveModalWithKeyboard(constant: -modalPadding)
//  }
//  
//  private func keyboardHeight(notification notification: NSNotification) -> CGFloat {
//    if let info  = notification.userInfo, let value = info[UIKeyboardFrameEndUserInfoKey] {
//      let rawFrame = value.CGRectValue
//      let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
//      return keyboardFrame.height
//    }
//    return 0
//  }
//  
//  private func moveModalWithKeyboard(constant constant: CGFloat) {
//    modalBottomConstraint?.constant = constant
//    UIView.animateWithDuration(0.3) {
//      self.view.layoutIfNeeded()
//    }
//  }
//  
//  func textViewDidChange(textView: UITextView) {
//    handleTitlePlaceholderAndCursor()
//  }
//  
//  private func handleTitlePlaceholderAndCursor() {
//    if let placeholder = titleTextViewPlaceHolder, title = titleTextView {
//      let labelWidth = placeholder.intrinsicContentSize().width
//      let textViewTextSize = title.font!.pointSize
//      
//      placeholder.frame.origin = CGPointMake(modal.frame.width/2-labelWidth/2, textViewTextSize/2)
//      placeholder.hidden = !title.text.isEmpty
//      title.textContainerInset = title.text.isEmpty ? UIEdgeInsets(top: textViewTextSize/2, left:labelWidth+textViewTextSize/4, bottom: 0, right: 0) : UIEdgeInsets(top: textViewTextSize/2, left:0, bottom: 0, right: 0)
//    }
//  }
//  
//  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//    if text == "\n" {
//      textView.resignFirstResponder()
//      submitNote(confirm: true)
//    }
//    
//    switch textView.tag {
//    case 1: return textView.text.length + (text.length - range.length) <= 80
//    default: return true
//    }
//  }
//  
//  
//  // MARK: - buttons
//  internal func buttonPressed(button: UIButton) {
//    Util.animateButtonPress(button: button)
//    Util.playSound(systemSound: .Tap)
//    submitNote(confirm: Bool(button.tag))
//  }
//  
//  
//  // MARK: - validation
//  private func submitNote(confirm confirm: Bool) {
//    if confirm {
//      guard let title = titleTextView?.text where title.length > 0 else {
//        close(confirm: false, note: nil, create: nil)
//        return
//      }
//      
//      let create = data == nil ? true : false
//      let note = data ?? Note(title: title)
//      note.title = title.trim
//      
//      close(confirm: true, note: note, create: create)
//      return
//    }
//    
//    close(confirm: false, note: nil, create: nil)
//  }
//}