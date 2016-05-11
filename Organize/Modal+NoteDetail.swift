import UIKit

protocol ModalNoteDetailDelegate: class {
  func modalNoteDetailDisplay(create create: Bool)
  func modalNoteDetailValue(note note: Note)
}

class ModalNoteDetailViewController: UIViewController, UITextViewDelegate {
  // MARK: - properties
  weak var delegate: ModalNoteDetailDelegate?
  weak var selected: Reminder?
  
  let modal: UIView = UIView()
  
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
    delegate = nil
    selected = nil
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
    let yes = createButton(title: Modal.textYes, bold: false)
    let no = createButton(title: Modal.textNo, bold: true)
    let topSeparator = Modal.createSeparator()
    let midSeparator = Modal.createSeparator()
    
    let title = createTextView()
    createPlaceHolderLabel(textView: title)
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
    
    modal.addSubview(title)
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
      
      title.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      title.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      title.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Config.buttonPadding),
      title.heightAnchor.constraintEqualToConstant(Config.buttonHeight*2),
      
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
    textView.tag = 1
    textView.delegate = self
    textView.textAlignment = .Center
    textView.font = UIFont.boldSystemFontOfSize(Modal.textSize)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.tintColor = Config.colorButton
    
    return textView
  }
  
  private func createPlaceHolderLabel(textView textView: UITextView) -> UILabel {
    let label = UILabel()
    label.text = "Title"
    label.font = .boldSystemFontOfSize(textView.font!.pointSize)
    label.sizeToFit()
    label.frame.origin = CGPointMake(modalWidth/2-label.intrinsicContentSize().width/2, textView.font!.pointSize / 2)
    label.textColor = Config.colorBorder
    label.hidden = !textView.text.isEmpty
    label.textAlignment = textView.textAlignment
    textView.addSubview(label)
    
    return label
  }

  private func createButton(title title: String, bold: Bool) -> UIButton {
    let button = UIButton()
    button.tag = Int(bold)
    button.layer.cornerRadius = Modal.radius
    button.setTitle(title, forState: .Normal)
    button.setTitleColor(Config.colorButton, forState: .Normal)
    button.setTitleColor(Config.colorBorder, forState: .Highlighted)
    button.titleLabel?.font = bold ? .boldSystemFontOfSize(Modal.textSize) : .systemFontOfSize(Modal.textSize)
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
    for v in textView.subviews {
      if let _ = v as? UILabel {
        v.hidden = !textView.text.isEmpty
        break
      }
    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    switch textView.tag {
    case 1: return textView.text.length + (text.length - range.length) <= 80
    default: return true
    }
  }
  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.playSound(systemSound: .Tap)
    Util.animateButtonPress(button: button)
    close()
  }
  
  // MARK: - open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  func close() {
    Modal.animateOut(modal: modal, background: view) {
      // calls deinit
      self.dismissViewControllerAnimated(false, completion: nil)
    }
  }
}