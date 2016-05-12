import UIKit


protocol ModalNoteDetailDelegate: ModalDelegate {
  func modalNoteDetailDisplay(indexPath indexPath: NSIndexPath, create: Bool)
  func modalNoteDetailValue(indexPath indexPath: NSIndexPath, note: Note, create: Bool)
}

protocol ModalDelegate: class {
  
}


class ModalNoteDetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
  // MARK: - properties
  weak var delegate: ModalNoteDetailDelegate?
  weak var data: Note?
  var indexPath: NSIndexPath?
  
  let modal: UIView = UIView()
  
  var titleTextView: UITextView?
  var titleTextViewPlaceHolder: UILabel?
  let modalWidth: CGFloat = 290
  let modalHeight: CGFloat = 140
  var tapGesture: UITapGestureRecognizer?
  var panGesture: UIPanGestureRecognizer?
  var modalCenterYConstraint: NSLayoutConstraint?
  
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    titleTextView = nil
    titleTextViewPlaceHolder = nil
    delegate = nil
    data = nil
    tapGesture = nil
    panGesture = nil
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    Modal.clear(background: view)
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
    createGestures()
    createListeners()
  }
  
  private func createGestures() {
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_:)))
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPressed(_:)))
    view.addGestureRecognizer(panGesture!)
    view.addGestureRecognizer(tapGesture!)
  }
  
  private func createListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  private func setupView() {
    let yes = createButton(title: Modal.textYes, confirm: true)
    let no = createButton(title: Modal.textNo, confirm: false)
    let topSeparator = Modal.createSeparator()
    let midSeparator = Modal.createSeparator()
    
    titleTextView = createTextView()
    titleTextView!.becomeFirstResponder()
    titleTextViewPlaceHolder = createPlaceHolderLabel(textView: titleTextView!)
    handleTitlePlaceholderAndCursor()
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
    
    modal.addSubview(titleTextView!)
    modal.addSubview(yes)
    modal.addSubview(no)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    
    modalCenterYConstraint = modal.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
    
    NSLayoutConstraint.activateConstraints([
      modal.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
      modalCenterYConstraint!,
      modal.widthAnchor.constraintEqualToConstant(modalWidth),
      modal.heightAnchor.constraintEqualToConstant(modalHeight),
      
      titleTextView!.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      titleTextView!.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      titleTextView!.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Config.buttonPadding),
      titleTextView!.heightAnchor.constraintEqualToConstant(Config.buttonHeight*2),
      
      no.trailingAnchor.constraintEqualToAnchor(midSeparator.leadingAnchor),
      no.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      no.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      no.heightAnchor.constraintEqualToConstant(Config.buttonHeight),
      
      yes.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      yes.leadingAnchor.constraintEqualToAnchor(midSeparator.trailingAnchor),
      yes.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      yes.heightAnchor.constraintEqualToConstant(Config.buttonHeight),
      yes.widthAnchor.constraintEqualToAnchor(no.widthAnchor),
      
      topSeparator.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparator.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparator.bottomAnchor.constraintEqualToAnchor(yes.topAnchor),
      topSeparator.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      midSeparator.leadingAnchor.constraintEqualToAnchor(no.trailingAnchor),
      midSeparator.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      midSeparator.heightAnchor.constraintEqualToAnchor(no.heightAnchor),
      midSeparator.widthAnchor.constraintEqualToConstant(Modal.separator),
      ])
  }
  
  private func createTextView() -> UITextView {
    let textView = UITextView()
    textView.text = data?.title
    textView.tag = 1
    textView.delegate = self
    textView.returnKeyType = .Done
    textView.textAlignment = .Center
    textView.font = UIFont.boldSystemFontOfSize(Modal.textSize)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.tintColor = Config.colorButton
    
    return textView
  }
  
  private func createPlaceHolderLabel(textView textView: UITextView) -> UILabel {
    let label = UILabel()
    label.text = "Title"
    let labelWidth = label.intrinsicContentSize().width
    let textViewTextSize = textView.font!.pointSize
    label.font = .boldSystemFontOfSize(textView.font!.pointSize)
    label.sizeToFit()
    label.frame.origin = CGPointMake(modalWidth/2-labelWidth/2, textViewTextSize/2)
    label.textColor = Config.colorBorder
    label.hidden = !textView.text.isEmpty
    label.textAlignment = textView.textAlignment
    textView.addSubview(label)
    
    return label
  }
  
  private func createButton(title title: String, confirm: Bool) -> UIButton {
    let button = UIButton()
    button.tag = Int(confirm)
    button.layer.cornerRadius = Modal.radius
    button.setTitle(title, forState: .Normal)
    button.setTitleColor(Config.colorButton, forState: .Normal)
    button.setTitleColor(Config.colorBorder, forState: .Highlighted)
    button.titleLabel?.font = confirm ? .systemFontOfSize(Modal.textSize) : .boldSystemFontOfSize(Modal.textSize)
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
  }
  
  // MARK: - gestures
  func tapPressed(gesture: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func panPressed(gesture: UIPanGestureRecognizer) {
    view.endEditing(true)
  }
  
  
  // MARK: - keybaord
  func keyboardWillShow(notification: NSNotification) {
    moveModalWithKeyboard(constant: -85)
  }
  
  func keyboardWillHide(notification: NSNotification) {
    moveModalWithKeyboard(constant: 0)
  }
  
  private func moveModalWithKeyboard(constant constant: CGFloat) {
    modalCenterYConstraint?.constant = constant
    view.layoutIfNeeded()
  }
  
  func textViewDidChange(textView: UITextView) {
    handleTitlePlaceholderAndCursor()
  }
  
  private func handleTitlePlaceholderAndCursor() {
    if let placeholder = titleTextViewPlaceHolder, title = titleTextView {
      let labelWidth = placeholder.intrinsicContentSize().width
      let textViewTextSize = title.font!.pointSize
      
      placeholder.hidden = !title.text.isEmpty
      title.textContainerInset = title.text.isEmpty ? UIEdgeInsets(top: textViewTextSize/2, left:labelWidth+textViewTextSize/4, bottom: 0, right: 0) : UIEdgeInsets(top: textViewTextSize/2, left:0, bottom: 0, right: 0)
    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    
    if text == "\n" {
      textView.resignFirstResponder()
      submitNote(confirm: true)
    }
    
    switch textView.tag {
    case 1: return textView.text.length + (text.length - range.length) <= 80
    default: return true
    }
  }
  
  
  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
    submitNote(confirm: Bool(button.tag))
  }
  
  // MARK: - validation
  private func submitNote(confirm confirm: Bool) {
    if confirm {
      guard let title = titleTextView?.text where title.length > 0 else {
        close(confirm: false, note: nil, create: nil)
        return
      }
      
      let create = data == nil ? true : false
      let note = data ?? Note(title: title)
      note.title = title.trim
      
      close(confirm: true, note: note, create: create)
      return
    }
    
    close(confirm: false, note: nil, create: nil)
  }
  
  
  // MARK: - open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  private func close(confirm confirm: Bool, note: Note?, create: Bool?) {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
      if let note = note, create = create, indexPath = self.indexPath where confirm {
        self.delegate?.modalNoteDetailValue(indexPath: indexPath, note: note, create: create)
      }
    }
  }
}