import UIKit

protocol TasksTableViewCellDelegate: class {
  func cellAccessoryButtonPressed(button: UIButton)
}

class TasksTableViewCell: UITableViewCell {
  
  // MARK: properties
  static let identifier: String = "cell"
  static let height: CGFloat = 40
  
  private var titleLabel: UILabel?
  private var accessoryButton: UIButton?
  private var reminderView: UIView?
  private let titleLabelPadding: CGFloat = 10
  private let accessoryButtonWidth: CGFloat = 44
  private let reminderViewWidth: CGFloat = 3
  
  weak var delegate: TasksTableViewCellDelegate?
  private var swipe: CellSwipe?
  
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
    setupCellDefaults()
    setupSwipeGesture()
  }
  
  
  // MARK: dealloc
  private func dealloc() {
    print("Cell dealloc")
    titleLabel?.removeFromSuperview()
    accessoryButton?.removeFromSuperview()
    reminderView?.removeFromSuperview()
  }
  
  deinit {
    print("CELL deinit")
    dealloc()
  }
  
  
  // MARK: create
  private func setupView() {
    titleLabel = UILabel()
    addSubview(titleLabel!)
    
    accessoryButton = UIButton()
    addSubview(accessoryButton!)
    accessoryButton?.addTarget(self, action: #selector(accessoryButtonPressed(_:)), forControlEvents: .TouchUpInside)
    accessoryButton?.setTitle("+", forState: .Normal)
    accessoryButton?.setTitleColor(Config.colorButton, forState: .Normal)
    accessoryButton?.setTitleColor(Config.colorShadow, forState: .Highlighted)
    
    reminderView = UIView()
    addSubview(reminderView!)
    reminderView?.backgroundColor = Config.colorButton
  }
  
  private func setupCellDefaults() {
    backgroundColor = Config.colorBackground
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    selectionStyle = .None
  }
  
  private func setupViewConstraints() {
    titleLabel!.translatesAutoresizingMaskIntoConstraints = false
    accessoryButton!.translatesAutoresizingMaskIntoConstraints = false
    reminderView!.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activateConstraints([
      titleLabel!.topAnchor.constraintEqualToAnchor(topAnchor),
      titleLabel!.leadingAnchor.constraintEqualToAnchor(reminderView!.trailingAnchor,constant: titleLabelPadding),
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
  
  
  func setupSwipeGesture() {
    // need global for completion block
    swipe = CellSwipe(cell: self)
//    cell.swipeDelegate = self

    if let swipe = swipe {
      swipe.firstTrigger = 0.15
      swipe.secondTrigger = 0.40
      swipe.thirdTrigger = 0.65
      
      // complete
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Left1, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-check")!, color: Config.colorBackground), color: Config.colorGreen) { cell in
        print("finsih")
      }
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Right1, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-close-small")!, color: Config.colorBackground), color: Config.colorSubtitle) { cell in
        print("finsih")
      }
      
      // indent
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Left2, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-arrow-right")!, color: Config.colorBackground), color: Config.colorBrown) { cell in
        print("finsih")
      }
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Right2, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-arrow-left")!, color: Config.colorBackground), color: Config.colorBrown) { cell in
        print("finsih")
      }
      
      // notification
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Left3, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-clock")!, color: Config.colorBackground), color: Config.colorButton) { cell in
        print("finsih")
      }
      
      // delete
      swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Right3, swipeMode: CellSwipe.SwipeMode.Slide, icon: Util.imageViewWithColor(image: UIImage(named: "icon-delete")!, color: Config.colorBackground), color: Config.colorRed) { cell in
        print("finsih")
      }
    }
  }
  
  // MARK: load
  func updateCell(data data: Int) {
    titleLabel?.text = String(data)
  }
  
  // MARK: buttons
  func accessoryButtonPressed(button: UIButton) {
    delegate?.cellAccessoryButtonPressed(button)
  }
}