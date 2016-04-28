import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModalDatePickerDelegate, ModalReminderDelegate, ListTableViewCellDelegate {
  // MARK: - properties
  var data: [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]
  var tableView: UITableView?
  var gestureDoubleTap: UITapGestureRecognizer?
  var gestureSingleTap: UITapGestureRecognizer?
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    refreshControl.tintColor = Config.colorBorder
    return refreshControl
  }()
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    
    createTableView()
    print("lsit")
    //    createGestures()
  }
  
  private func createTableView() {
    tableView = UITableView()
    view.addSubview(tableView!)
    // delegates
    tableView?.delegate = self
    tableView?.dataSource = self
    
    // cell
    tableView?.registerClass(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    
    // refresh
    tableView?.addSubview(refreshControl)
    
    // color
    tableView?.backgroundColor = Config.colorBackground
    
    // borders
    tableView?.contentInset = UIEdgeInsetsZero
    tableView?.separatorInset = UIEdgeInsetsZero
    tableView?.separatorColor = Config.colorBorder
    tableView?.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView?.layoutMargins = UIEdgeInsetsZero
    tableView?.tableFooterView = UIView(frame: CGRect.zero)
    
    // constraints
    tableView?.translatesAutoresizingMaskIntoConstraints = false
    tableView?.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    tableView?.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    tableView?.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
    tableView?.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
  }
  
  private func createGestures() {
    gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap!.numberOfTapsRequired = 2
    gestureDoubleTap!.numberOfTouchesRequired = 1
    tableView?.addGestureRecognizer(gestureDoubleTap!)
    
    gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap!.numberOfTapsRequired = 1
    gestureSingleTap!.numberOfTouchesRequired = 1
    gestureSingleTap!.requireGestureRecognizerToFail(gestureDoubleTap!)
    tableView?.addGestureRecognizer(gestureSingleTap!)
  }
  
  // MARK: - load
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - tableview datasource
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ListTableViewCell.height
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ListTableViewCell.identifier, forIndexPath: indexPath) as! ListTableViewCell
    cell.delegate = self
    cell.updateCell(data: data[indexPath.row])
//    let swipe = CellSwipe(cell: cell)
////    swipe.delegate = self
//    swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Right1, swipeMode: CellSwipe.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "list")), color: Config.colorBrown) { (cell) -> () in
//      print("finsih")
//    }
//    swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Left1, swipeMode: CellSwipe.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "clock")), color: Config.colorGreen) { (cell) -> () in
//      print("finsih")
//    }
//    swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Right2, swipeMode: CellSwipe.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "check")), color: Config.colorYellow) { (cell) -> () in
//      print("finsih")
//    }
//    swipe.addSwipeGesture(swipeGesture: CellSwipe.SwipeGesture.Left2, swipeMode: CellSwipe.SwipeMode.Slide, icon: UIImageView(image: UIImage(named: "list")), color: Config.colorButton) { (cell) -> () in
//      print("finsih")
//    }
//    
    return cell
  }
  
  // cell accessory button
  
  func cellAccessoryButtonPressed(button: UIButton) {
    print("pressed")
  }
  // cell swipe 1
  // cell swipe 2
  // cell swipe 3
  // cell swipe 4
  
  
  
  // MARK: - refresh
  func tableViewRefresh(refreshControl: UIRefreshControl) {
    tableView?.reloadData()
    refreshControl.endRefreshing()
  }
  
  // MARK: - gestures
  func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    print("single")
    modalReminderDisplay()
  }
  func gestureRecognizedDoubleTap(gesture: UITapGestureRecognizer) {
    
    let paramLater: Double = 2
    let paramMorning: Double = 24 + 8
    let paramEvening: Double = 12 + 6
    // -1 day because working off tomorrow morning's value
    let paramWeek: Double = 6
    let paramMonth: Double = 29
    let paramSomeday: Double = 59
    
    let now: NSDate = NSDate()
    let today: NSDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    let dayOfWeek: Double = Double(NSCalendar.currentCalendar().components(.Weekday, fromDate: today).weekday)
    
    // 2 hours
    let later = now.dateByAddingTimeInterval(60*60*(paramLater))
    
    // at 6pm or 2 hours from now if already after 6pm
    let evening = now.compare(today.dateByAddingTimeInterval(60*60*(paramEvening))) == .OrderedDescending ? later : today.dateByAddingTimeInterval(60*60*(paramEvening))
    
    // 8am tomorrow
    let tomorrow = today.dateByAddingTimeInterval(60*60*(paramMorning))
    
    // saturday at 8am or 2hours if already on weekend
    let weekend = (dayOfWeek == 7 || dayOfWeek == 1) ? later : tomorrow.dateByAddingTimeInterval(60*60*24*(6-dayOfWeek))
    
    // 7 days from now or monday if weekend
    let week = tomorrow.dateByAddingTimeInterval(60*60*24*(paramWeek))
    
    
    // 30 days
    let month = tomorrow.dateByAddingTimeInterval(60*60*24*(paramMonth))
    
    // date
    let someday = tomorrow.dateByAddingTimeInterval(60*60*24*(paramSomeday))
    
    print(today)
    print(now)
    print(later)
    print(evening)
    print(tomorrow)
    print(weekend)
    print(week)
    print(month)
    print(someday)
    
    
    //
    //    let id = Int(NSDate().timeIntervalSince1970 * 100000)
    //    LocalNotification.sharedInstance.create(controller: self, body: "hello", action: "world", fireDate: nil, soundName: nil, uid: id) { success in
    //      if success {
    //        let a = Note(title: "asdioansd", description: "asdoiasn")
    //        a.reminderId = id
    //        // update cell
    //      }
    //
    //    }
    //    LocalNotification.sharedInstance.delete(uid: 123)
    
  }
  
  // MARK: - modals
  func modalDatePickerDisplay() {
    // pass Tasks.reminderDate to autoload that date
    let controller = ModalDatePickerViewController()
    controller.delegate = self
    controller.modalPresentationStyle = .OverCurrentContext
    presentViewController(controller, animated: false, completion: nil)
  }
  
  func modalDatePickerValue(date date: NSDate) {
    print(date)
    // if Task.reminderId != nil
    //    LocalNotification.sharedInstance.delete(uid: Task.reminderId)
    //      let id = Int(NSDate().timeIntervalSince1970 * 100000)
    //      LocalNotification.sharedInstance.create(controller: self, body: "hello", action: "world", fireDate: nil, soundName: nil, uid: id) { success in
    //        Task.reminderId = id
    //        update cell image
    // else
    //   let id = Int(NSDate().timeIntervalSince1970 * 100000)
    //   LocalNotification.sharedInstance.create(controller: self, body: "hello", action: "world", fireDate: nil, soundName: nil, uid: id) { success in
    //     Task.reminderId = id
    //     update cell image
  }
  
  func modalReminderDisplay() {
    let controller = ModalReminderViewController()
    controller.delegate = self
    // pass Task.reminderType
    // controller.selected = Tasks.reminderType
    controller.modalPresentationStyle = .OverCurrentContext
    presentViewController(controller, animated: false, completion: nil)
  }
  
  func modalReminderValue(reminderType reminderType: ReminderType) {
    print(reminderType)
    
    if reminderType == .Date {
      modalDatePickerDisplay()
    } else {
      // if reminderType == Task.reminderType
      //   LocalNotification.sharedInstance.delete(uid: Task.reminderId)
      //     Task.reminderType = nil
      //     Task.reminderId = nil
      // else
      //   let id = Int(NSDate().timeIntervalSince1970 * 100000)
      //   LocalNotification.sharedInstance.create(controller: self, body: "hello", action: "world", fireDate: nil, soundName: nil, uid: id) { success in
      //     Task.reminderId = id
      //     update cell image
    }
  }
  
}

