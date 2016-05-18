import UIKit


protocol ModalTutorialDelegate: class {
  func modalNoteDetailDisplay(indexPath indexPath: NSIndexPath, create: Bool)
  func modalNoteDetailValue(indexPath indexPath: NSIndexPath, note: Note, create: Bool)
}

class ModalTutorialViewController: UIViewController {
  // MARK: - properties
  weak var delegate: ModalTutorialDelegate?
  
  let modal: UIView = UIView()
  
  var titleTextView: UITextView?
  var titleTextViewPlaceHolder: UILabel?
  let modalWidth: CGFloat = 290
  let modalHeight: CGFloat = 290
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
  }
  
 
  private func setupView() {
    let yes = createButton(title: Modal.textYes, confirm: true)
    let no = createButton(title: Modal.textNo, confirm: false)
    let topSeparator = Modal.createSeparator()
    let midSeparator = Modal.createSeparator()
    
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

  
  // MARK: - buttons
  internal func buttonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    Util.playSound(systemSound: .Tap)
  }
  
  // MARK: - open/close
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    Modal.animateIn(modal: modal, background: view, completion: nil)
  }
  
  private func close(confirm confirm: Bool, note: Note?, create: Bool?) {
    Modal.animateOut(modal: modal, background: view) {
      self.dismissViewControllerAnimated(false, completion: nil)
//      if let note = note, create = create, indexPath = self.indexPath where confirm {
//        self.delegate?.modalNoteDetailValue(indexPath: indexPath, note: note, create: create)
//      }
    }
  }
}