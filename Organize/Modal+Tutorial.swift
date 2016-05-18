import UIKit

class ModalTutorialViewController: UIViewController {
  // MARK: - properties
  let modal: UIView = UIView()
  var message: UILabel?
  var image: UIImageView?
  var progress: UIView?
  var progressTrailingConstraint: NSLayoutConstraint?
  
  let progressHeight: CGFloat = 3
  let modalWidth: CGFloat = 290
  let modalHeight: CGFloat = 290
  
  
  // MARK: - data
  enum Slide: Int {
    case Complete
    case Uncomplete
    case Indent
    case Reminder
    case Delete
    case Undo
    case Collapse
    case Reorder
    case Edit
    
    static var count: Int {
      return Slide.Edit.hashValue + 1
    }
    
    var title: String {
      switch self {
      case .Complete: return "Swipe right to complete"
      case .Uncomplete: return "Swipe left to uncomplete"
      case .Indent: return "Swipe right or left to indent"
      case .Reminder: return "Swipe right to set a reminder"
      case .Delete: return "Swipe right to delete"
      case .Undo: return "Shake to undo last action"
      case .Collapse: return "Double tap to collapse"
      case .Reorder: return "Hold to reorder"
      case .Edit: return "Tap to edit or create"
      }
    }
    
    var image: UIImage {
      switch self {
      case .Complete: return UIImage(named: "shot-complete")!
      case .Uncomplete: return UIImage(named: "shot-complete")!
      case .Indent: return UIImage(named: "shot-indent")!
      case .Reminder: return UIImage(named: "shot-reminder")!
      case .Delete: return UIImage(named: "shot-delete")!
      case .Undo: return UIImage(named: "shot-undo")!
      case .Collapse: return UIImage(named: "shot-collapse")!
      case .Reorder: return UIImage(named: "shot-reorder")!
      case .Edit: return UIImage(named: "shot-edit")!
      }
    }
  }
  
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    message = nil
    image = nil
    progress = nil
    progressTrailingConstraint = nil
    Modal.clear(background: view)
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    let slide = Slide(rawValue: 0)!
    message = createTitle(title: slide.title)
    image = createImageView(image: slide.image)
    progress = createProgress()
    let next = createButton(title: "Next", confirm: true)
    let topSeparator = Modal.createSeparator()
    let messageSeparator = Modal.createSeparator()
    
    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
    modal.addSubview(message!)
    modal.addSubview(messageSeparator)
    modal.addSubview(image!)
    modal.addSubview(progress!)
    modal.addSubview(topSeparator)
    modal.addSubview(next)
    
    progressTrailingConstraint = progress!.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor, constant: -50)
    
    NSLayoutConstraint.activateConstraints([
      modal.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
      modal.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
      modal.widthAnchor.constraintLessThanOrEqualToAnchor(view.widthAnchor, multiplier: 0.7, constant: 50),
      modal.heightAnchor.constraintLessThanOrEqualToAnchor(view.heightAnchor, multiplier: 0.6, constant: 100),
      
      message!.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      message!.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      message!.topAnchor.constraintEqualToAnchor(modal.topAnchor, constant: Config.buttonPadding),
      message!.heightAnchor.constraintEqualToConstant(Config.buttonHeight),
      
      messageSeparator.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      messageSeparator.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      messageSeparator.topAnchor.constraintEqualToAnchor(message!.bottomAnchor, constant: Config.buttonPadding/2),
      messageSeparator.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      image!.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      image!.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      image!.topAnchor.constraintEqualToAnchor(messageSeparator.bottomAnchor, constant: Config.buttonPadding),
      image!.bottomAnchor.constraintEqualToAnchor(progress!.topAnchor),
      
      progressTrailingConstraint!,
      progress!.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      progress!.bottomAnchor.constraintEqualToAnchor(topSeparator.topAnchor),
      progress!.heightAnchor.constraintEqualToConstant(progressHeight),
      
      topSeparator.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      topSeparator.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      topSeparator.bottomAnchor.constraintEqualToAnchor(next.topAnchor),
      topSeparator.heightAnchor.constraintEqualToConstant(Modal.separator),
      
      next.trailingAnchor.constraintEqualToAnchor(modal.trailingAnchor),
      next.leadingAnchor.constraintEqualToAnchor(modal.leadingAnchor),
      next.bottomAnchor.constraintEqualToAnchor(modal.bottomAnchor),
      next.heightAnchor.constraintEqualToConstant(Config.buttonHeight),
      ])
  }
  
  private func createProgress() -> UIView {
    let view = UIView()
    view.backgroundColor = Config.colorButton
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  private func createTitle(title title: String) -> UILabel {
    let label = UILabel()
    label.textAlignment = .Center
    label.font = .boldSystemFontOfSize(Modal.textSize)
    label.text = title
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }
  
  private func createImageView(image image: UIImage) -> UIImageView {
    let imageView = UIImageView()
    imageView.image = image
    imageView.contentMode = .ScaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
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
    print(button.tag)
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
    }
  }
}