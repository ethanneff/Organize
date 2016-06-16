import UIKit

// view controller to incapsulate for gestures
class SideMenu: UIViewController {
  // MARK: - properties
  
  // required (references to main)
  private let parent: UIViewController
  private let child: UIViewController
  private let left: UIViewController?
  private let right: UIViewController?
  
  // public
  var leftWidth: CGFloat = 250 {
    didSet {
      if let _ = left {
        NSLayoutConstraint.deactivateConstraints([leftConstraintSide!,leftConstraintWidth!])
        NSLayoutConstraint.activateConstraints(createContainerLeftConstraints())
      }
    }
  }
  var rightWidth: CGFloat = 250 {
    didSet {
      if let _ = right {
        NSLayoutConstraint.deactivateConstraints([rightConstraintSide!,rightConstraintWidth!])
        NSLayoutConstraint.activateConstraints(createContainerRightConstraints())
      }
    }
  }
  var speed: NSTimeInterval = 0.30
  var fade: CGFloat = 0.90
  var shadow: Float = 0.70
  var panMinPercentage: CGFloat = 10
  
  // private
  private var panBeganLocation: CGPoint = CGPointZero
  private var panEndedLocation: CGPoint = CGPointZero
  private var panBeganHorizontal: Bool = false
  
  private var gestureSingleTap: UITapGestureRecognizer?
  private var gesturePanSwipe: UIPanGestureRecognizer?
  
  private var rightConstraintWidth: NSLayoutConstraint?
  private var rightConstraintSide: NSLayoutConstraint?
  private var leftConstraintWidth: NSLayoutConstraint?
  private var leftConstraintSide: NSLayoutConstraint?
  
  private enum PanDirection {
    case Left
    case Right
  }
  
  internal enum Side {
    case Left
    case Right
    case None
  }
  
  // MARK: - init
  init(parent: UIViewController, child: UIViewController, left: UIViewController?, right: UIViewController?) {
    self.parent = parent
    self.child = child
    self.left = left
    self.right = right
    
    super.init(nibName: nil, bundle: nil)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  private func initialize() {
    createContainers()
    createContainerProperties()
    createGestures()
  }
  
  
  // MARK: - deinit
  deinit {
    // FIXME: reference cycle
    print("side menu deinit")
    dealloc()
  }
  
  private func dealloc() {
    if let gestureSingleTap = gestureSingleTap {
      parent.view.removeGestureRecognizer(gestureSingleTap)
    }
    if let gesturePanSwipe = gesturePanSwipe {
      parent.view.removeGestureRecognizer(gesturePanSwipe)
    }
    
    parent.removeFromParentViewController()
    removeContainer(container: child)
    removeContainer(container: left)
    removeContainer(container: right)
  }
  
  
  // MARK: - orientation
  internal func orientationChange() {
    createContainerProperties()
  }
  
  // MARK: - create
  private func createGestures() {
    gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap!.numberOfTapsRequired = 1
    parent.view.addGestureRecognizer(gestureSingleTap!)
    gesturePanSwipe = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizedPanSwipe(_:)))
    gesturePanSwipe!.minimumNumberOfTouches = 1
    parent.view.addGestureRecognizer(gesturePanSwipe!)
  }
  
  private func createContainers() {
    // below navigation bar
    parent.edgesForExtendedLayout = .None
    
    // constraints
    var constraints:[NSLayoutConstraint] = []
    constraints += createContainerChild()
    constraints += createContainerLeft()
    constraints += createContainerRight()
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  private func createContainerChild() -> [NSLayoutConstraint] {
    addContainer(container: child)
    child.view.translatesAutoresizingMaskIntoConstraints = false
    
    return [
      NSLayoutConstraint(item: child.view, attribute: .Top, relatedBy: .Equal, toItem: parent.view, attribute: .TopMargin, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: child.view, attribute: .Bottom, relatedBy: .Equal, toItem: parent.view, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: child.view, attribute: .CenterX, relatedBy: .Equal, toItem: parent.view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: child.view, attribute: .Width, relatedBy: .Equal, toItem: parent.view, attribute: .Width, multiplier: 1, constant: 0),
    ]
  }
  
  private func createContainerLeft() -> [NSLayoutConstraint] {
    if let left = left {
      addContainer(container: left)
      left.view.translatesAutoresizingMaskIntoConstraints = false
      return [
        NSLayoutConstraint(item: left.view, attribute: .Top, relatedBy: .Equal, toItem: parent.view, attribute: .TopMargin, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: left.view, attribute: .Bottom, relatedBy: .Equal, toItem: parent.view, attribute: .Bottom, multiplier: 1, constant: 0),
      ] + createContainerLeftConstraints()
    }
    return []
  }
  
  private func createContainerRight() -> [NSLayoutConstraint] {
    if let right = right {
      addContainer(container: right)
      right.view.translatesAutoresizingMaskIntoConstraints = false
     
      return [
        NSLayoutConstraint(item: right.view, attribute: .Top, relatedBy: .Equal, toItem: parent.view, attribute: .TopMargin, multiplier: 1, constant: 0),
        NSLayoutConstraint(item: right.view, attribute: .Bottom, relatedBy: .Equal, toItem: parent.view, attribute: .Bottom, multiplier: 1, constant: 0),
      ] + createContainerRightConstraints()
    }
    return []
  }
  
  private func createContainerRightConstraints() -> [NSLayoutConstraint] {
    rightConstraintSide = NSLayoutConstraint(item: right!.view, attribute: .Trailing, relatedBy: .Equal, toItem: parent.view, attribute: .Trailing, multiplier: 1, constant: rightWidth)
    rightConstraintWidth = NSLayoutConstraint(item: right!.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: rightWidth)
    return [rightConstraintSide!, rightConstraintWidth!]
  }
  
  private func createContainerLeftConstraints() -> [NSLayoutConstraint] {
    leftConstraintSide = NSLayoutConstraint(item: left!.view, attribute: .Leading, relatedBy: .Equal, toItem: parent.view, attribute: .Leading, multiplier: 1, constant: -leftWidth)
    leftConstraintWidth = NSLayoutConstraint(item: left!.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: leftWidth)
    return [leftConstraintSide!, leftConstraintWidth!]
  }
  
  private func createContainerProperties() {
    // set to make background container fade
    parent.view.backgroundColor = UIColor.blackColor()
    
    var containers: [UIView] = []
    containers.append(child.view)
    if let left = left?.view {
      containers.append(left)
    }
    if let right = right?.view {
      containers.append(right)
    }
    
    for container in containers {
      container.alpha = 1.0
      container.layer.masksToBounds = true
      container.layer.shadowColor = UIColor.blackColor().CGColor
      container.layer.shadowOpacity = shadow
      container.layer.shadowOffset = CGSizeZero
      container.layer.shadowRadius = 5
    }
  }
  
  private func addContainer(container container: UIViewController) {
    parent.addChildViewController(container)
    parent.view.addSubview(container.view)
    container.didMoveToParentViewController(parent)
  }
  
  private func removeContainer(container container: UIViewController?) {
    if let container = container {
      container.willMoveToParentViewController(nil)
      container.view.removeFromSuperview()
      container.removeFromParentViewController()
    }
  }
  
  // MARK: - gesture handling
  internal func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(parent.view)
    if touchInMainContainer(location: location) {
      toggle(side: .None)
    }
  }
  
  private func touchInMainContainer(location location: CGPoint) -> Bool {
    if isVisible(container: left?.view) {
      return location.x > left!.view.frame.origin.x + left!.view.frame.size.width
    } else if isVisible(container: right?.view) {
      return location.x < right!.view.frame.origin.x
    }
    return false
  }
  
  internal func gestureRecognizedPanSwipe(gesture: UIPanGestureRecognizer) {
    let state = gesture.state
    let location = gesture.locationInView(parent.view)
    let velocity = gesture.velocityInView(parent.view)
    
    switch state {
    case .Began:
      panBeganLocation = location
      panBeganHorizontal = panHorizontal(velocity: velocity)
    case .Changed: break
    case .Cancelled, .Ended:
      panEndedLocation = location
      let direction = panDirection(beganLocation: panBeganLocation, endedLocation: panEndedLocation)
      let percentage = panPercentage(beganLocation: panBeganLocation, endedLocation: panEndedLocation)
      let correct = panCorrect(direction: direction, percentage: percentage, horizontal: panBeganHorizontal)
      if correct {
        toggle(side: .None)
      }
      panReset()
    default: break
    }
  }
  
  private func panDirection(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> PanDirection {
    return endedLocation.x > beganLocation.x ? .Right : .Left
  }
  
  private func panPercentage(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> CGFloat {
    if isVisible(container: left?.view) {
      return fabs(panEndedLocation.x - panBeganLocation.x) / left!.view.frame.size.width * 100
    }
    return fabs(panEndedLocation.x - panBeganLocation.x) / right!.view.frame.size.width * 100
  }
  
  private func panHorizontal(velocity velocity: CGPoint) -> Bool {
    return fabs(velocity.x) > fabs(velocity.y)
  }
  
  private func panCorrect(direction direction: PanDirection, percentage: CGFloat, horizontal: Bool) -> Bool {
    if isVisible(container: left?.view) {
      return direction == .Left && percentage > panMinPercentage && horizontal
    } else if isVisible(container: right?.view) {
      return direction == .Right && percentage > panMinPercentage && horizontal
    }
    return false
  }
  
  private func panReset() {
    panBeganLocation = CGPointZero
    panEndedLocation = CGPointZero
    panBeganHorizontal = false
  }
  
  
  // MARK: - menu handling
  internal func toggle(side side: Side) {
    switch side {
    case .Left:
      if isVisible(container: right?.view) {
        rightAnimate {
          self.leftAnimate()
        }
      } else {
        leftAnimate()
      }
    case .Right:
      if isVisible(container: left?.view) {
        leftAnimate {
          self.rightAnimate()
        }
      } else {
        rightAnimate()
      }
    case .None:
      if isVisible(container: left?.view) {
        leftAnimate()
      } else {
        rightAnimate()
      }
    }
  }
  
  private func leftAnimate(completion: (() -> ())? = nil) {
    if let left = left {
      animate(menu: left.view, isOpening: !isVisible(container: left.view), side: .Left, completion: {
        if let completion = completion {
          completion()
        }
      })
    }
  }
  
  private func rightAnimate(completion: (() -> ())? = nil) {
    if let right = right {
      animate(menu: right.view, isOpening: !isVisible(container: right.view), side: .Right, completion: {
        if let completion = completion {
          completion()
        }
      })
    }
  }
  
  private func isVisible(container container: UIView?) -> Bool {
    if let container = container {
      return container.frame.origin.x >= 0 && container.frame.origin.x < parent.view.frame.size.width
    }
    return false
  }
  
  private func animate(menu menu: UIView, isOpening: Bool, side: Side, completion: (() -> ())?) {
    menu.layer.masksToBounds = false
    child.view.userInteractionEnabled = isOpening ? false : true
    
    UIView.animateWithDuration(speed, delay: 0.0, options: isOpening ? .CurveEaseOut : .CurveEaseIn, animations: {
      self.child.view.alpha = isOpening ? self.fade : 1.0
      
      switch side {
      case .Left: menu.frame.origin.x -= isOpening ? -menu.frame.size.width : menu.frame.size.width
      case .Right: menu.frame.origin.x -= isOpening ? menu.frame.size.width : -menu.frame.size.width
      case .None: break
      }
    }) { (success) in
      menu.layer.masksToBounds = isOpening ? false : true
      if let completion = completion {
        completion()
      }
    }
  }
}