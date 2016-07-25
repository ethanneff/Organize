import UIKit

// MARK: - delegate to view controller
protocol ListTableViewCellDelegate: class {
  func cellAccessoryButtonPressed(cell cell: UITableViewCell)
  func cellSwiped(type type: SwipeType, cell: UITableViewCell)
}

class ListTableViewCell: UITableViewCell {
  // MARK: - properties
  static let identifier: String = "cell"
  static let height: CGFloat = 34
  
  private var titleLabel: UILabel!
  private var accessoryButton: UIButton!
  private var reminderView: UIView!
  
  private var titleLabelLeadingConstraint: NSLayoutConstraint!
  
  private let reminderViewWidth: CGFloat = 3
  private let titleLabelIndentMultiplier: CGFloat = 20
  
  weak var delegate: ListTableViewCellDelegate?
  private var swipe: SwipeCell!
  
  // MARK: - init
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
    setupDefaults()
    setupSwipe()
  }
  
  deinit {
    swipe = nil
    for v in subviews {
      v.removeFromSuperview()
    }
  }
}

// MARK: - layout
extension ListTableViewCell {
  private func setupView() {
    titleLabel = Constant.Label.create(title: nil, primary: true, alignment: .Left)
    accessoryButton = Constant.Button.create(title: nil, bold: false, small: true, background: false, shadow: false)
    reminderView = Constant.View.create()
    
    accessoryButton.addTarget(self, action: #selector(accessoryButtonPressed(_:)), forControlEvents: .TouchUpInside)
    
    addSubview(titleLabel)
    addSubview(accessoryButton)
    addSubview(reminderView)
  }
  
  private func setupViewConstraints() {
    titleLabelLeadingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding)
    
    NSLayoutConstraint.activateConstraints([
      titleLabelLeadingConstraint,
      NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: accessoryButton, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding),
      NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      
      NSLayoutConstraint(item: accessoryButton, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: accessoryButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
      
      NSLayoutConstraint(item: reminderView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: reminderView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: reminderViewWidth),
      ])
  }
}

// MARK: - swipe
extension ListTableViewCell: SwipeCellDelegate {
  func setupSwipe() {
    swipe = SwipeCell(cell: self)
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
}

// MARK: - buttons
extension ListTableViewCell {
  func accessoryButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    delegate?.cellAccessoryButtonPressed(cell: self)
  }
}

// MARK: - load
extension ListTableViewCell {
  func updateCell(note note: Note) {
    // indent
    titleLabelLeadingConstraint.constant = Constant.Button.padding + CGFloat(note.indent) * titleLabelIndentMultiplier
    
    // bolded
    titleLabel.font = note.bolded ? .boldSystemFontOfSize(Constant.Font.title) : .systemFontOfSize(Constant.Font.title)
    
    // title & complete
    if note.completed {
      let attrString = NSAttributedString(string: note.title, attributes: [NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue])
      titleLabel.attributedText = attrString
      titleLabel.textColor = Constant.Color.border
      accessoryButton.tintColor = Constant.Color.border
    } else {
      titleLabel.textColor = Constant.Color.title
      accessoryButton.tintColor = Constant.Color.button
      titleLabel.text = note.title
    }
    
    // accessoryButton
    accessoryButton.enabled = true
    if note.collapsed {
      accessoryButton.setTitle(String(note.children), forState: .Normal)
      accessoryButton.setTitleColor(Constant.Color.border, forState: .Normal)
    } else {
      accessoryButton.setTitle("+", forState: .Normal)
      accessoryButton.setTitleColor(Constant.Color.button, forState: .Normal)
      
      if note.completed {
        accessoryButton.setTitleColor(Constant.Color.border, forState: .Normal)
        accessoryButton.enabled = false
      }
    }
    
    // reminder view
    if note.reminder?.date.timeIntervalSinceNow > 0 {
      reminderView.backgroundColor = Constant.Color.button
    } else {
      reminderView.backgroundColor = .clearColor()
    }
  }
}