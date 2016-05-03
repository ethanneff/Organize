import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModalDatePickerDelegate, ModalReminderDelegate, ListTableViewCellDelegate {
  // MARK: - properties
  var notebook: Notebook
  lazy var tableView: UITableView = UITableView()
  var gestureDoubleTap: UITapGestureRecognizer?
  var gestureSingleTap: UITapGestureRecognizer?
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    refreshControl.tintColor = Config.colorBorder
    return refreshControl
  }()
  
  // MARK: - init
  init() {
    notebook = Notebook.getDefault()
    super.init(nibName: nil, bundle: nil)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  private func initialize() {
    loadNotebook()
    loadListeners()
    createTableView()
    createGestures()
  }
  
  private func loadNotebook() {
    Notebook.get { data in
      if let data = data {
        self.notebook = data
      }
    }
  }
  
  private func loadListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  // MARK: - deinit
  deinit {
    // TODO: dismissviewcontollors does not call dinit
    print("deinit")
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  func applicationWillResignActiveNotification() {
    Notebook.set(data: notebook)
  }
  
  // MARK: - create
  private func createTableView() {
    // add
    view.addSubview(tableView)
    
    // delegates
    tableView.delegate = self
    tableView.dataSource = self
    
    // cell
    tableView.registerClass(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.identifier)
    
    // refresh
    tableView.addSubview(refreshControl)
    
    // color
    tableView.backgroundColor = Config.colorBackground
    
    // borders
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.separatorColor = Config.colorBorder
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    
    // constraints
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      tableView.topAnchor.constraintEqualToAnchor(view.topAnchor),
      tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
      tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
      tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
      ])
  }
  
  private func createGestures() {
    gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap!.numberOfTapsRequired = 2
    gestureDoubleTap!.numberOfTouchesRequired = 1
    tableView.addGestureRecognizer(gestureDoubleTap!)
    
    gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap!.numberOfTapsRequired = 1
    gestureSingleTap!.numberOfTouchesRequired = 1
    gestureSingleTap!.requireGestureRecognizerToFail(gestureDoubleTap!)
    tableView.addGestureRecognizer(gestureSingleTap!)
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
    return notebook.display.count
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ListTableViewCell.height
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(ListTableViewCell.identifier, forIndexPath: indexPath) as! ListTableViewCell
    cell.delegate = self
    cell.updateCell(note: notebook.display[indexPath.row])
    
    return cell
  }
  
  // cell accessory button
  func cellAccessoryButtonPressed(cell cell: UITableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let item = notebook.display[indexPath.row]
      if item.collapsed {
        notebook.uncollapse(indexPath: indexPath, tableView: tableView)
      } else {
        let note = modalNewNote()
        notebook.add(indexPath: indexPath, tableView: tableView, note: note)
      }
    }
  }
  
  
  func modalNewNote() -> Note {
    return Note(title: "hello")
  }
  
  func getDisplayItem(cell cell: UITableViewCell) -> Note? {
    if let indexPath = tableView.indexPathForCell(cell) {
      return notebook.display[indexPath.row]
    }
    return nil
  }
  
  
  // cell swiped
  func cellSwiped(type type: SwipeType, cell: UITableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      switch type {
      case .Complete:
        notebook.complete(indexPath: indexPath, tableView: tableView)
      case .Indent:
        notebook.indent(indexPath: indexPath, tableView: tableView)
      case .Reminder:
        modalReminderDisplay()
      case .Uncomplete:
        notebook.uncomplete(indexPath: indexPath, tableView: tableView)
      case .Unindent:
        notebook.unindent(indexPath: indexPath, tableView: tableView)
      case .Delete:
        modalDelete(indexPath: indexPath) {
          self.notebook.delete(indexPath: indexPath, tableView: self.tableView)
        }
      }
    }
  }
  
  
  func modalDelete(indexPath indexPath: NSIndexPath, completion: () -> ()) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let delete = UIAlertAction(title: "Delete", style: .Default) { action in
      completion()
    }
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alert.addAction(delete)
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion:nil)
  }
  
  // MARK: - refresh
  func tableViewRefresh(refreshControl: UIRefreshControl) {
    notebook = Notebook.getDefault()
    Notebook.set(data: notebook)
    tableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  // MARK: - gestures
  func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    print(notebook)
    print("single")
  }
  
  
  func gestureRecognizedDoubleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      let item = notebook.display[indexPath.row]
      if item.collapsed {
        notebook.uncollapse(indexPath: indexPath, tableView: tableView)
      } else {
        notebook.collapse(indexPath: indexPath, tableView: tableView)
      }
    }
  }
  
  
  func reminder() {
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

