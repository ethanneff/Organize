import UIKit

class MenuViewController: UIViewController {
  // MARK: - properties
  var menuDelegate: MenuContainers?
  var menuGestureSingleTap: UITapGestureRecognizer?
  var menuGesturePanSwipe: UIPanGestureRecognizer?
  
  // MARK: - deinit
  deinit {
    menuDelegate?.menuDeinit()
    menuDelegate = nil
    if let menuGestureSingleTap = menuGestureSingleTap {
      view.removeGestureRecognizer(menuGestureSingleTap)
    }
    if let menuGesturePanSwipe = menuGesturePanSwipe {
      view.removeGestureRecognizer(menuGesturePanSwipe)
    }
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    
    // TODO: do better
    menuDelegate = MenuContainers(menuParent: self, menuChild: TasksViewController(), menuLeft: SearchViewController(), menuRight: OrganizeViewController())
    menuDelegate?.menuLeftWidth = 200
    menuDelegate?.menuRightWidth = 200
    menuDelegate?.menuCreate()
    
    createNavButtons()
    createGestures()
  }
  
  private func createNavButtons() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(leftNavButtonPressed(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Organize, target: self, action: #selector(rightNavButtonPressed(_:)))
  }
  
  private func createGestures() {
    menuGestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    menuGestureSingleTap!.numberOfTapsRequired = 1
    view.addGestureRecognizer(menuGestureSingleTap!)
    menuGesturePanSwipe = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizedPanSwipe(_:)))
    menuGesturePanSwipe!.minimumNumberOfTouches = 1
    view.addGestureRecognizer(menuGesturePanSwipe!)
  }
  
  // MARK: - orientation
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    menuDelegate?.menuOrientationChange()
  }
  
  // MARK: - gestures
  internal func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    menuDelegate?.menuGestureRecognizedSingleTap(gesture)
  }
  
  internal func gestureRecognizedPanSwipe(gesture: UIPanGestureRecognizer) {
    menuDelegate?.menuGestureRecognizedPanSwipe(gesture)
  }
  
  // MARK: - buttons
  internal func leftNavButtonPressed(sender: UIBarButtonItem) {
    menuDelegate?.menuToggle(menuSide: .Left)
  }
  
  internal func rightNavButtonPressed(sender: UIBarButtonItem) {
    menuDelegate?.menuToggle(menuSide: .Right)
  }
}
