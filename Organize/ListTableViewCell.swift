import UIKit

protocol ListTableViewCellDelegate: class {
  func cellAccessoryButtonPressed(cell cell: UITableViewCell)
  func cellSwiped(type type: SwipeType, cell: UITableViewCell)
}

class ListTableViewCell: UITableViewCell, CellSwipeDelegate {
  
  // MARK: properties
  static let identifier: String = "cell"
  static let height: CGFloat = 40
  
  private var titleLabel: UILabel?
  private var accessoryButton: UIButton?
  private var reminderView: UIView?
  private let titleLabelPadding: CGFloat = 10
  private let accessoryButtonWidth: CGFloat = 44
  private let reminderViewWidth: CGFloat = 3
  private let titleIndentSpace: String = "     "
  
  weak var delegate: ListTableViewCellDelegate?
  // TODO: figure out why to make a property... swipe gets deinit otherwise
  var swipe: CellSwipe?
  
  // MARK: init
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    dealloc()
    initialize()
  }
  
  private func initialize() {
    setupView()
    setupViewConstraints()
    setupSwipe(cell: self)
    setupCellDefaults()
  }
  
  
  // MARK: dealloc
  private func dealloc() {
    titleLabel?.removeFromSuperview()
    accessoryButton?.removeFromSuperview()
    reminderView?.removeFromSuperview()
    swipe = nil
  }
  
  deinit {
    dealloc()
  }
  
  
  // MARK: create
  private func setupView() {
    titleLabel = UILabel()
    addSubview(titleLabel!)
    
    accessoryButton = UIButton()
    addSubview(accessoryButton!)
    accessoryButton?.addTarget(self, action: #selector(accessoryButtonPressed(_:)), forControlEvents: .TouchUpInside)
    
    reminderView = UIView()
    addSubview(reminderView!)
    
  }
  
  private func setupCellDefaults() {
    backgroundColor = Config.colorBackground
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    selectionStyle = .None
  }
  
  private func setupViewConstraints() {
    titleLabel!.translatesAutoresizingMaskIntoConstraints = false
    accessoryButton!.translatesAutoresizingMaskIntoConstraints = false
    reminderView!.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activateConstraints([
      titleLabel!.topAnchor.constraintEqualToAnchor(topAnchor),
      titleLabel!.leadingAnchor.constraintEqualToAnchor(reminderView!.trailingAnchor, constant: titleLabelPadding),
      titleLabel!.trailingAnchor.constraintEqualToAnchor(accessoryButton!.leadingAnchor, constant: titleLabelPadding),
      titleLabel!.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
      
      accessoryButton!.topAnchor.constraintEqualToAnchor(topAnchor),
      accessoryButton!.trailingAnchor.constraintEqualToAnchor(trailingAnchor),
      accessoryButton!.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
      accessoryButton!.widthAnchor.constraintEqualToConstant(accessoryButtonWidth),
      
      reminderView!.topAnchor.constraintEqualToAnchor(topAnchor),
      reminderView!.leadingAnchor.constraintEqualToAnchor(leadingAnchor),
      reminderView!.bottomAnchor.constraintEqualToAnchor(bottomAnchor),
      reminderView!.widthAnchor.constraintEqualToConstant(reminderViewWidth)
      ])
  }
  
  func setupSwipe(cell cell: UITableViewCell) {
    swipe = CellSwipe(cell: cell)
    if let swipe = swipe {
      swipe.delegate = self
      swipe.firstTrigger = 0.15
      swipe.secondTrigger = 0.40
      swipe.thirdTrigger = 0.65
      
      for i in 0..<SwipeType.count {
        if let type = SwipeType(rawValue: i) {
          swipe.create(position: type.position, animation: type.animation, icon: type.icon, color: type.color) { cell in
            self.delegate?.cellSwiped(type: type, cell: cell)
          }
        }
      }
    }
  }
  
  
  // MARK: load
  func updateCell(note note: Note) {
    // title
    var title = note.title
    for _ in 0..<note.indent {
      title = titleIndentSpace + title
    }
    titleLabel?.text = title
    
    // accessoryButton
    if note.collapsed {
      accessoryButton?.setTitle(String(note.children), forState: .Normal)
      accessoryButton?.setTitleColor(Config.colorBorder, forState: .Normal)
    } else {
      accessoryButton?.setTitle("+", forState: .Normal)
      accessoryButton?.setTitleColor(Config.colorButton, forState: .Normal)
    }
    
    // reminder view
    if note.reminderType != .None {
      reminderView?.backgroundColor = Config.colorButton
    } else {
      reminderView?.backgroundColor = Config.colorBackground
    }
  }
  
  // MARK: buttons
  func accessoryButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    delegate?.cellAccessoryButtonPressed(cell: self)
  }
}