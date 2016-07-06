// TODO: fix minor memory leak

import UIKit

protocol ReorderTableViewDelegate: class {
  // protocol to interact with reorder tableview
  func reorderBeforeLift(fromIndexPath: NSIndexPath, completion: () -> ())
  func reorderAfterLift(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ())
  func reorderBeforeDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ())
  func reorderAfterDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ())
  func reorderDuringMove(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ())
}

extension ReorderTableViewDelegate {
  // make functions optionals
  func reorderBeforeLift(fromIndexPath: NSIndexPath, completion: () -> ()) { completion() }
  func reorderAfterLift(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) { completion() }
  func reorderBeforeDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) { completion() }
  func reorderAfterDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) { completion() }
  func reorderDuringMove(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) { completion() }
}

class ReorderTableView: UITableView {
  // MARK: - PROPERTIES
  
  // constants
  private let kReorderLiftAnimation: Double = 0.35
  private let kReorderScrollMultiplier: CGFloat = 10.0
  private let kReorderScrollTableViewPadding: CGFloat = 50.0
  
  // public
  private var reorderInitalIndexPath: NSIndexPath?
  weak var reorderDelegate: ReorderTableViewDelegate?
  
  // private
  private var reorderGesture: UILongPressGestureRecognizer?
  private var reorderPreviousIndexPath: NSIndexPath?
  private var reorderInitialCellCenter: CGPoint?
  private var reorderSnapshot: UIView?
  private var reorderScrollRate: CGFloat = 0
  private var reorderScrollLink: CADisplayLink?
  private var reorderGestureMoving: Bool = false
  private var reorderGestureLifted: Bool = false
  
  
  
  // MARK: - DELEGATION
  private enum ReorderDelegateNotifications {
    case BeforeLift
    case AfterLift
    case BeforeDrop
    case AfterDrop
    case DuringMove
  }
  
  private func reorderNotifyDelegate(notification notification: ReorderDelegateNotifications, fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath?, completion: () -> ()) {
    // notify the parent controller
    switch notification {
    case .BeforeLift: reorderDelegate?.reorderBeforeLift(fromIndexPath) { completion() }
    case .AfterLift: reorderDelegate?.reorderAfterLift(fromIndexPath, toIndexPath: toIndexPath!) { completion() }
    case .BeforeDrop: reorderDelegate?.reorderBeforeDrop(fromIndexPath, toIndexPath: toIndexPath!) { completion() }
    case .AfterDrop: reorderDelegate?.reorderAfterDrop(fromIndexPath, toIndexPath: toIndexPath!) { completion() }
    case .DuringMove: reorderDelegate?.reorderDuringMove(fromIndexPath, toIndexPath: toIndexPath!) { completion() }
    }
  }
  
  
  
  // MARK: - INIT
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    initalizer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initalizer()
  }
  
  convenience init(tableView: UITableView) {
    self.init(frame: CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height), style: .Plain)
  }
  
  private func initalizer() {
    reorderGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderGestureRecognized(_:)))
    if let reorderGesture = reorderGesture {
      reorderGesture.minimumPressDuration = 0.3
      addGestureRecognizer(reorderGesture)
    }
    //    registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
  
  
  // MARK: - DEALLOC
  deinit {
    // TODO: does not get called (probably b/c list deinit not being called)
    reorderDealloc()
  }
  
  private func reorderDealloc() {
    reorderScrollRate = 0
    if let scrollLink = reorderScrollLink {
      scrollLink.invalidate()
    }
    if let reorderSnapshot = reorderSnapshot {
      reorderSnapshot.removeFromSuperview()
    }
    
    reorderInitalIndexPath = nil
    reorderPreviousIndexPath = nil
    reorderSnapshot = nil
    reorderInitialCellCenter = nil
  }
  
  
  
  // MARK: - GESTURE
  internal func reorderGestureRecognized(gesture: UILongPressGestureRecognizer) {
    // long press on cell
    let location = gesture.locationInView(self)
    
    switch gesture.state {
    case UIGestureRecognizerState.Began:
      // began
      if let indexPath = indexPathForRowAtPoint(location) {
        reorderNotifyDelegate(notification: .BeforeLift, fromIndexPath: indexPath, toIndexPath: nil) {
          self.reorderHandleDelegateIndexChange(gesture: gesture, location: location, indexPath: indexPath)
          
          if let previousIndexPath = self.reorderPreviousIndexPath, let cell = self.cellForRowAtIndexPath(previousIndexPath) {
            self.reorderInitialCellCenter = cell.center
            self.reorderCreateSnapshotCell(cell: cell)
            self.reorderLiftSnapshotCell(location: location, cell: cell)
            self.reorderNotifyDelegate(notification: .AfterLift, fromIndexPath: indexPath, toIndexPath: previousIndexPath) {
              self.reorderLoopToDetectScrolling()
              self.reorderGestureLifted = true
            }
          }
        }
      }
    case UIGestureRecognizerState.Changed:
      // changed
      reorderUpdateScrollRateForTableViewScrolling(location: location)
    default:
      // ended
      waitForGestureDelegates {
        if let initialIndexPath = self.reorderInitalIndexPath,
          let previousIndexPath = self.reorderPreviousIndexPath,
          let previousCell = self.cellForRowAtIndexPath(previousIndexPath) {
          self.reorderNotifyDelegate(notification: .BeforeDrop, fromIndexPath: initialIndexPath, toIndexPath: previousIndexPath) {
            let cell = self.reorderAdjustCellCenterOffset(initialIndexPath: initialIndexPath, previousIndexPath: previousIndexPath, previousCell: previousCell)
            
            self.reorderDropSnapshotCell(cell: cell) {
              self.reorderNotifyDelegate(notification: .AfterDrop, fromIndexPath: initialIndexPath, toIndexPath: previousIndexPath) {}
              self.reorderDealloc()
            }
          }
        }
      }
    }
  }
  
  
  
  // MARK: - BEGIN
  private func reorderLoopToDetectScrolling() {
    // start looping for scrolling (because want to scroll when non-moving near edges [UIGestureRecognizerState.Change won't be called])
    reorderScrollLink = CADisplayLink(target: self, selector: #selector(reorderScrollTableWithCell))
    reorderScrollLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
  }
  
  private func reorderHandleDelegateIndexChange(gesture gesture: UILongPressGestureRecognizer, location: CGPoint, indexPath: NSIndexPath) {
    // if location changes from delegation
    let newLocation = gesture.locationInView(self)
    
    // handle out of bounds limit of tableview
    let newIndexPath = indexPathForRowAtPoint(newLocation) ?? NSIndexPath(forRow: numberOfRowsInSection(0)-1, inSection: 0)
    
    //    FIXME: broken, causes reorder mismatch
    //    if location != newLocation {
    //      // reorder any changes from the delegate
    //      moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
    //    }
    
    // save initial and previous indexes (used the passed index [reorderInitalIndexPath] if available)
    reorderInitalIndexPath = newIndexPath
    reorderPreviousIndexPath = indexPath
  }
  
  private func reorderCreateSnapshotCell(cell cell: UITableViewCell) {
    // create snapshot cell (the pickup cell)
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
    cell.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
    UIGraphicsEndImageContext()
    self.reorderSnapshot = UIImageView(image: image)
    if let reorderSnapshot = self.reorderSnapshot {
      reorderSnapshot.layer.masksToBounds = false
      reorderSnapshot.layer.cornerRadius = 0.0
      reorderSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
      reorderSnapshot.layer.shadowRadius = 3.0
      reorderSnapshot.layer.shadowOpacity = 0.4
      reorderSnapshot.center = cell.center
      reorderSnapshot.alpha = 0.0
      self.addSubview(reorderSnapshot)
    }
  }
  
  private func reorderLiftSnapshotCell(location location: CGPoint, cell: UITableViewCell) {
    // animate the snapshot lift
    UIView.animateWithDuration(kReorderLiftAnimation, animations: {
      cell.center.y = location.y
      cell.alpha = 0.0
      if let reorderSnapshot = self.reorderSnapshot {
        reorderSnapshot.center = cell.center
        reorderSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
        reorderSnapshot.alpha = 0.8
      }
      }, completion: { (finished) -> Void in
        cell.hidden = true
    })
  }
  
  
  
  // MARK: - CHANGED
  private func reorderCorrectDraggingBounds(location location: CGPoint) {
    // update position of the drag view so it wont go past the top or the bottom too far
    if let reorderSnapshot = reorderSnapshot where location.y >= 0 && location.y <= contentSize.height + kReorderScrollTableViewPadding {
      reorderSnapshot.center = CGPointMake(center.x, location.y)
    }
  }
  
  private func reorderUpdateScrollRateForTableViewScrolling(location location: CGPoint) {
    // adjust rect for content inset as we will use it below for calculating scroll zones
    var rect: CGRect = bounds
    rect.size.height -= contentInset.top
    
    // use scrollLink loop to move tableView and snapshot by changing the reorderScrollRate property
    let scrollZoneHeight: CGFloat = rect.size.height / 6
    let bottomScrollBeginning: CGFloat = contentOffset.y + contentInset.top + rect.size.height - scrollZoneHeight
    let topScrollBeginning: CGFloat = contentOffset.y + contentInset.top + scrollZoneHeight
    
    // reorderScrollRate updates reorderScrollTableWithCell() via the reorderScrollLink
    if location.y >= bottomScrollBeginning {
      // bottom
      reorderScrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight
    } else if location.y <= topScrollBeginning {
      // top
      reorderScrollRate = (location.y - topScrollBeginning) / scrollZoneHeight
    } else {
      // middle
      reorderScrollRate = 0
    }
  }
  
  internal func reorderScrollTableWithCell() {
    // looping via the CADisplayLink of reorderScrollLink to detect whether to move the tableview or not (start after lifted)
    if let gesture: UILongPressGestureRecognizer = reorderGesture {
      let location: CGPoint = gesture.locationInView(self)
      let prevOffset: CGPoint = contentOffset
      let nextOffset: CGPoint = CGPointMake(prevOffset.x, prevOffset.y + reorderScrollRate * kReorderScrollMultiplier)
      
      reorderScrollWithTableView(prevOffset: prevOffset, nextOffset: nextOffset)
      reorderCorrectDraggingBounds(location: location)
      reorderUpdateCurrentLocation(gesture: gesture, location: location)
    }
  }
  
  private func reorderScrollWithTableView(prevOffset prevOffset: CGPoint, nextOffset: CGPoint ) {
    var newOffset = nextOffset
    
    // scroll the tableview on drag
    if nextOffset.y < -contentInset.top {
      newOffset.y = -contentInset.top
    }
    else if contentSize.height + contentInset.bottom < frame.size.height {
      newOffset = prevOffset
    }
    else if nextOffset.y > (contentSize.height + contentInset.bottom) - frame.size.height {
      newOffset.y = (contentSize.height + contentInset.bottom) - frame.size.height
    }
    contentOffset = newOffset
  }
  
  private func reorderUpdateCurrentLocation(gesture gesture: UILongPressGestureRecognizer, location: CGPoint) {
    // reorder the tableview cells on drag
    if let nextIndexPath = indexPathForRowAtPoint(location), let prevIndexPath = reorderPreviousIndexPath {
      // prevents spamming and fast scrolling bug (allow only 1 difference b/c of swap function)
      if nextIndexPath != prevIndexPath && abs(nextIndexPath.row - prevIndexPath.row) == 1 && !reorderGestureMoving {
        // prevents sending multiple data updates to controller (can cause swapping of cells)
        reorderGestureMoving = true
        reorderNotifyDelegate(notification: .DuringMove, fromIndexPath: prevIndexPath, toIndexPath: nextIndexPath) {
          self.moveRowAtIndexPath(prevIndexPath, toIndexPath: nextIndexPath)
          self.reorderPreviousIndexPath = nextIndexPath
          self.reorderGestureMoving = false
        }
      }
    }
  }
  
  
  
  // MARK: - ENDED
  private func reorderAdjustCellCenterOffset(initialIndexPath initialIndexPath: NSIndexPath, previousIndexPath: NSIndexPath, previousCell: UITableViewCell) -> UITableViewCell {
    // if picked up and dropped on the same cell location... re adjust so the cell drops in the center and not a few pixels off
    if let initialCenter = reorderInitialCellCenter where initialIndexPath == previousIndexPath {
      previousCell.center = initialCenter
    }
    return previousCell
  }
  
  private func reorderDropSnapshotCell(cell cell: UITableViewCell, completion: () -> ()) {
    cell.hidden = false
    cell.alpha = 0.0
    UIView.animateWithDuration(kReorderLiftAnimation, animations: {
      cell.alpha = 1.0
      if let reorderSnapshot = self.reorderSnapshot {
        reorderSnapshot.center = cell.center
        reorderSnapshot.transform = CGAffineTransformIdentity
        reorderSnapshot.alpha = 0.0
      }
      }, completion: { (finished) -> Void in
        cell.hidden = false
        completion()
    })
  }
  
  private func waitForGestureDelegates(completion: () -> ()) {
    if reorderGestureLifted && !reorderGestureMoving {
      completion()
    } else {
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.waitForGestureDelegates(completion)
      }
    }
  }
}