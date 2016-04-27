import UIKit

class MenuContainers {
  // MARK: - properties
  
  // references to main
  let menuParent: UIViewController
  let menuChild: UIViewController
  let menuLeft: UIViewController
  let menuRight: UIViewController
  
  var menuLeftWidth: CGFloat = 250
  var menuRightWidth: CGFloat = 100
  
  var menuSpeed: NSTimeInterval = 0.4
  // TODO: make menu and modals the same (need to add shadow to modal)
  var menuFade: CGFloat = 0.9
  var menuShadow: Float = 0.7
  var menuPanMinPercentage: CGFloat = 10
  
  private var menuPanBeganLocation: CGPoint = CGPointZero
  private var menuPanEndedLocation: CGPoint = CGPointZero
  private var menuPanBeganHorizontal: Bool = false
  
  private var menuGestureSingleTap: UITapGestureRecognizer?
  private var menuGesturePanSwipe: UIPanGestureRecognizer?
  
  private enum MenuPanDirection {
    case Left
    case Right
  }
  
  internal enum MenuSide {
    case Left
    case Right
    case Center
  }
  
  // MARK: - init
  init(menuParent: UIViewController, menuChild: UIViewController, menuLeft: UIViewController, menuRight:UIViewController) {
    self.menuParent = menuParent
    self.menuChild = menuChild
    self.menuLeft = menuLeft
    self.menuRight = menuRight
  }
  
  func menuCreate() {
    menuCreateContainers()
    menuCreateContainerProperties()
  }
  
  func menuOrientationChange() {
    menuCreateContainerProperties()
  }
  
  func menuDeinit() {
    menuRemoveContainer(container: menuChild)
    menuRemoveContainer(container: menuLeft)
    menuRemoveContainer(container: menuRight)
  }
  
  // MARK: - create
  private func menuCreateContainers() {
    menuDeinit()
    
    // below navigation bar
    // TODO: even needed?
    menuParent.edgesForExtendedLayout = .None
    
    // get the superview's layout
    let margins = menuParent.view.layoutMarginsGuide
    
    // add the containers with constraints
    menuAddContainer(container: menuChild)
    menuChild.view.translatesAutoresizingMaskIntoConstraints = false
    menuChild.view.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
    menuChild.view.bottomAnchor.constraintEqualToAnchor(menuParent.view.bottomAnchor).active = true
    menuChild.view.centerXAnchor.constraintEqualToAnchor(menuParent.view.centerXAnchor).active = true
    menuChild.view.widthAnchor.constraintEqualToAnchor(menuParent.view.widthAnchor).active = true
    
    menuAddContainer(container: menuLeft)
    menuLeft.view.translatesAutoresizingMaskIntoConstraints = false
    menuLeft.view.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
    menuLeft.view.leadingAnchor.constraintEqualToAnchor(menuParent.view.leadingAnchor, constant: -menuLeftWidth).active = true
    menuLeft.view.widthAnchor.constraintEqualToConstant(menuLeftWidth).active = true
    menuLeft.view.bottomAnchor.constraintEqualToAnchor(menuParent.view.bottomAnchor).active = true

    menuAddContainer(container: menuRight)
    menuRight.view.translatesAutoresizingMaskIntoConstraints = false
    menuRight.view.topAnchor.constraintEqualToAnchor(margins.topAnchor).active = true
    menuRight.view.trailingAnchor.constraintEqualToAnchor(menuParent.view.trailingAnchor, constant: menuRightWidth).active = true
    menuRight.view.widthAnchor.constraintEqualToConstant(menuRightWidth).active = true
    menuRight.view.bottomAnchor.constraintEqualToAnchor(menuParent.view.bottomAnchor).active = true
  }
  
  private func menuCreateContainerProperties() {
    // set to make background container fade
    menuParent.view.backgroundColor = UIColor.blackColor()
    
    let containers = [menuChild.view, menuLeft.view, menuRight.view]
    for container in containers {
      container.alpha = 1.0
      container.layer.masksToBounds = true
      container.layer.shadowColor = UIColor.blackColor().CGColor
      container.layer.shadowOpacity = menuShadow
      container.layer.shadowOffset = CGSizeZero
      container.layer.shadowRadius = 5
    }
  }
  
  private func menuAddContainer(container container: UIViewController) {
    menuParent.addChildViewController(container)
    menuParent.view.addSubview(container.view)
    container.didMoveToParentViewController(menuParent)
  }
  
  private func menuRemoveContainer(container container: UIViewController) {
    container.willMoveToParentViewController(nil)
    container.view.removeFromSuperview()
    container.removeFromParentViewController()
  }
  
  // MARK: - gesture handling
  internal func menuGestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(menuParent.view)
    if touchInMainContainer(location: location) {
      menuToggle(menuSide: .Center)
    }
  }
  
  private func touchInMainContainer(location location: CGPoint) -> Bool {
    if menuIsVisible(container: menuLeft.view) {
      return location.x > menuLeft.view.frame.origin.x + menuLeft.view.frame.size.width
    } else if menuIsVisible(container: menuRight.view) {
      return location.x < menuRight.view.frame.origin.x
    }
    return false
  }
  
  internal func menuGestureRecognizedPanSwipe(gesture: UIPanGestureRecognizer) {
    let state = gesture.state
    let location = gesture.locationInView(menuParent.view)
    let velocity = gesture.velocityInView(menuParent.view)
    
    switch state {
    case .Began:
      menuPanBeganLocation = location
      menuPanBeganHorizontal = menuPanHorizontal(velocity: velocity)
    case .Changed: break
    case .Cancelled, .Ended:
      menuPanEndedLocation = location
      let direction = menuPanDirection(beganLocation: menuPanBeganLocation, endedLocation: menuPanEndedLocation)
      let percentage = menuPanPercentage(beganLocation: menuPanBeganLocation, endedLocation: menuPanEndedLocation)
      let correct = menuPanCorrect(direction: direction, percentage: percentage, horizontal: menuPanBeganHorizontal)
      if correct {
        menuToggle(menuSide: .Center)
      }
      menuPanReset()
    default: break
    }
  }
  
  private func menuPanDirection(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> MenuPanDirection {
    return endedLocation.x > beganLocation.x ? .Right : .Left
  }
  
  private func menuPanPercentage(beganLocation beganLocation: CGPoint, endedLocation: CGPoint) -> CGFloat {
    if menuIsVisible(container: menuLeft.view) {
      return fabs(menuPanEndedLocation.x - menuPanBeganLocation.x) / menuLeft.view.frame.size.width * 100
    }
    return fabs(menuPanEndedLocation.x - menuPanBeganLocation.x) / menuRight.view.frame.size.width * 100
  }
  
  private func menuPanHorizontal(velocity velocity: CGPoint) -> Bool {
    return fabs(velocity.x) > fabs(velocity.y)
  }
  
  private func menuPanCorrect(direction direction: MenuPanDirection, percentage: CGFloat, horizontal: Bool) -> Bool {
    if menuIsVisible(container: menuLeft.view) {
      return direction == .Left && percentage > menuPanMinPercentage && horizontal
    } else if menuIsVisible(container: menuRight.view) {
      return direction == .Right && percentage > menuPanMinPercentage && horizontal
    }
    return false
  }
  
  private func menuPanReset() {
    menuPanBeganLocation = CGPointZero
    menuPanEndedLocation = CGPointZero
    menuPanBeganHorizontal = false
  }
  
  
  // MARK: - menu handling
  func menuToggle(menuSide menuSide: MenuSide) {
    switch menuSide {
    case .Left:
      if menuIsVisible(container: menuRight.view) {
        menuRightAnimate {
          self.menuLeftAnimate()
        }
      } else {
        menuLeftAnimate()
      }
    case .Right:
      if menuIsVisible(container: menuLeft.view) {
        menuLeftAnimate {
          self.menuRightAnimate()
        }
      } else {
        menuRightAnimate()
      }
    case .Center:
      if menuIsVisible(container: menuLeft.view) {
        menuLeftAnimate()
      } else {
        menuRightAnimate()
      }
    }
  }
  
  private func menuLeftAnimate(completion: (() -> ())? = nil) {
    menuAnimate(menu: menuLeft.view, menuIsOpening: !menuIsVisible(container: menuLeft.view), menuSide: .Left, completion: {
      if let completion = completion {
        completion()
      }
    })
  }
  
  private func menuRightAnimate(completion: (() -> ())? = nil) {
    menuAnimate(menu: menuRight.view, menuIsOpening: !menuIsVisible(container: menuRight.view), menuSide: .Right, completion: {
      if let completion = completion {
        completion()
      }
    })
  }
  
  private func menuIsVisible(container container: UIView) -> Bool {
    return container.frame.origin.x >= 0 && container.frame.origin.x < menuParent.view.frame.size.width
  }
  
  private func menuAnimate(menu menu: UIView, menuIsOpening: Bool, menuSide: MenuSide, completion: (() -> ())?) {
    menu.layer.masksToBounds = false
    menuChild.view.userInteractionEnabled = menuIsOpening ? false : true
    
    UIView.animateWithDuration(menuSpeed, delay: 0.0, options: menuIsOpening ? .CurveEaseOut : .CurveEaseIn, animations: {
      self.menuChild.view.alpha = menuIsOpening ? self.menuFade : 1.0
      
      switch menuSide {
      case .Left: menu.frame.origin.x -= menuIsOpening ? -menu.frame.size.width : menu.frame.size.width
      case .Right: menu.frame.origin.x -= menuIsOpening ? menu.frame.size.width : -menu.frame.size.width
      case .Center: break
      }
    }) { (success) in
      menu.layer.masksToBounds = menuIsOpening ? false : true
      if let completion = completion {
        completion()
      }
    }
  }
}