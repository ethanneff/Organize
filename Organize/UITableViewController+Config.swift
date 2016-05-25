import UIKit

extension UITableViewController {
  // load
  override public func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
  }
  
  func configureTableView() {
    // color
    tableView.backgroundColor = Constant.Color.background
    
    // borders
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.separatorColor = Constant.Color.border
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    
    // refresh
    refreshControl = UIRefreshControl()
    refreshControl?.tintColor = Constant.Color.border
    refreshControl?.addTarget(self, action: #selector(UITableViewController.beginRefresh), forControlEvents: .ValueChanged)
    edgesForExtendedLayout = .None
  }
  
  // refresh
  func beginRefresh() {
    refreshControl?.beginRefreshing()
  }
  
  func endRefresh() {
    refreshControl?.endRefreshing()
  }
}
