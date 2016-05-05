import UIKit

class MenuViewController: UIViewController {
  // MARK: - properties
  var sideMenu: SideMenu?
  
  // MARK: - init
  init() {
    super.init(nibName: nil, bundle: nil)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func initialize() {
    sideMenu = SideMenu(parent: self, child: ListViewController(), left: SearchViewController(), right: SettingViewController())
    sideMenu?.rightWidth = 160
    sideMenu?.leftWidth = 250
    createNavButtons()
    createNavTitle(title: Config.appName)
  }
  
  // MARK: - deinit
  deinit {
    sideMenu = nil
  }
  
  // MARK: - orientation
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    sideMenu?.orientationChange()
  }
  
  // MARK: - create
  private func createNavButtons() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(leftNavButtonPressed(_:)))
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Organize, target: self, action: #selector(rightNavButtonPressed(_:)))
  }
  
  private func createNavTitle(title title: String) {
    navigationItem.title = title
  }
  
  internal func leftNavButtonPressed(sender: UIBarButtonItem) {
    sideMenu?.toggle(side: .Left)
    Util.playSound(systemSound: .Tap)
  }
  
  internal func rightNavButtonPressed(sender: UIBarButtonItem) {
    sideMenu?.toggle(side: .Right)
    Util.playSound(systemSound: .Tap)
  }
}