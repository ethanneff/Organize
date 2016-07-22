import UIKit

protocol ListTableViewCellDelegate: class {
  func cellAccessoryButtonPressed(cell cell: UITableViewCell)
  func cellSwiped(type type: SwipeType, cell: UITableViewCell)
}

class ListTableViewCell: UITableViewCell, SwipeCellDelegate {
  
  // MARK: properties
  static let identifier: String = "cell"
  static let height: CGFloat = 34
  
  private var titleLabel: UILabel!
  private var titleLabelLeadingConstraint: NSLayoutConstraint!
  private var accessoryButton: UIButton!
  private var reminderView: UIView!
  private let titleLabelPadding: CGFloat = Constant.Button.padding
  private let accessoryButtonWidth: CGFloat = Constant.Button.height
  private let reminderViewWidth: CGFloat = 3
  
  private let titleLabelIndentMultiplier: CGFloat = 20
  
  weak var delegate: ListTableViewCellDelegate?
  private var swipe: SwipeCell!
  
  // MARK: - init
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
  }
  
  private func initialize() {
    setupView()
    setupViewConstraints()
    setupCellDefaults()
    setupSwipe(cell: self)
  }
  
  // MARK: - deinit
  deinit {
    // TODO: test if deinit when tableview deinits
    swipe = nil
    for v in subviews {
      v.removeFromSuperview()
    }
  }
  
  // MARK: - create
  private func setupView() {
    titleLabel = UILabel()
    addSubview(titleLabel)
    
    accessoryButton = UIButton()
    addSubview(accessoryButton)
    accessoryButton?.titleLabel?.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    accessoryButton?.addTarget(self, action: #selector(accessoryButtonPressed(_:)), forControlEvents: .TouchUpInside)
    
    reminderView = UIView()
    addSubview(reminderView)
  }
  
  private func setupCellDefaults() {
    backgroundColor = Constant.Color.background
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
    selectionStyle = .None
    // fixes separator disappearance
    textLabel?.backgroundColor = .clearColor()
  }
  
  private func setupViewConstraints() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    accessoryButton.translatesAutoresizingMaskIntoConstraints = false
    reminderView.translatesAutoresizingMaskIntoConstraints = false
    
    titleLabelLeadingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: titleLabelPadding)
    
    NSLayoutConstraint.activateConstraints([
      titleLabelLeadingConstraint,
      NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: accessoryButton, attribute: .Leading, multiplier: 1, constant: titleLabelPadding),
      NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      
      NSLayoutConstraint(item: accessoryButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: accessoryButtonWidth),
      
      NSLayoutConstraint(item: reminderView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: reminderViewWidth),
      ])
  }
  
  func setupSwipe(cell cell: UITableViewCell) {
    swipe = SwipeCell(cell: cell)
    swipe.delegate = self
    swipe.firstTrigger = 0.15
    swipe.secondTrigger = 0.40
    swipe.thirdTrigger = 0.65
    
    for i in 0..<SwipeType.count {
      if let type = SwipeType(rawValue: i) {
        swipe.create(position: type.position, animation: type.animation, icon: type.icon, color: type.color) { [unowned self] cell in
          self.delegate?.cellSwiped(type: type, cell: cell)
        }
      }
    }
  }
  
  // MARK: load
  func updateCell(note note: Note) {
    // indent
    titleLabelLeadingConstraint.constant = titleLabelPadding + CGFloat(note.indent) * titleLabelIndentMultiplier
    
    // bolded
    titleLabel?.font = note.bolded ? .boldSystemFontOfSize(UIFont.systemFontSize()) : .systemFontOfSize(UIFont.systemFontSize())
    
    // title & complete
    if note.completed {
      let attrString = NSAttributedString(string: note.title, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
      titleLabel?.attributedText = attrString
      titleLabel?.textColor = Constant.Color.border
      accessoryButton?.tintColor = Constant.Color.border
    } else {
      titleLabel?.textColor = Constant.Color.title
      accessoryButton?.tintColor = Constant.Color.button
      titleLabel?.text = note.title
    }
    
    // accessoryButton
    accessoryButton?.enabled = true
    if note.collapsed {
      accessoryButton?.setTitle(String(note.children), forState: .Normal)
      accessoryButton?.setTitleColor(Constant.Color.border, forState: .Normal)
    } else {
      accessoryButton?.setTitle("+", forState: .Normal)
      accessoryButton?.setTitleColor(Constant.Color.button, forState: .Normal)
      
      if note.completed {
        accessoryButton?.setTitleColor(Constant.Color.border, forState: .Normal)
        accessoryButton?.enabled = false
      }
    }
    
    // reminder view
    if note.reminder?.date.timeIntervalSinceNow > 0 {
      reminderView?.backgroundColor = Constant.Color.button
    } else {
      reminderView?.backgroundColor = .clearColor()
    }
  }
  
  // MARK: buttons
  func accessoryButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    delegate?.cellAccessoryButtonPressed(cell: self)
  }
}