import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModalDatePickerDelegate, ModalReminderDelegate, ListTableViewCellDelegate, SettingsDelegate {
  // MARK: - properties
  var notebook: Notebook
  var activeNotebookIndexPath: NSIndexPath?
  
  lazy var tableView: UITableView = UITableView()
  var gestureDoubleTap: UITapGestureRecognizer?
  var gestureSingleTap: UITapGestureRecognizer?
  weak var menuDelegate: MenuViewController?
  
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
        self.tableView.reloadData()
      }
    }
  }
  
  private func loadListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  
  // MARK: - load
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // shake
    self.becomeFirstResponder()
  }
  
  
  // MARK: - deinit
  deinit {
    // TODO: dismiss viewcontollor does not call deinit
    print("deinit")
    dealloc()
  }
  
  private func dealloc() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  func applicationWillResignActiveNotification() {
    notebook.historyClear()
  }
  
  func applicationDidBecomeActiveNotification() {
    // update reminder icons
    tableView.reloadData()
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
    // double tap
    gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap!.numberOfTapsRequired = 2
    gestureDoubleTap!.numberOfTouchesRequired = 1
    tableView.addGestureRecognizer(gestureDoubleTap!)
    
    // single tap
    gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap!.numberOfTapsRequired = 1
    gestureSingleTap!.numberOfTouchesRequired = 1
    gestureSingleTap!.requireGestureRecognizerToFail(gestureDoubleTap!)
    tableView.addGestureRecognizer(gestureSingleTap!)
  }
  
  // MARK: - error
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
      Util.playSound(systemSound: .Tap)
    }
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
      activeNotebookIndexPath = indexPath
      
      switch type {
      case .Complete:
        notebook.complete(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .BeepBeepSuccess)
      case .Indent:
        notebook.indent(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .SMSSent)
      case .Reminder:
        modalReminderDisplay()
        Util.playSound(systemSound: .BeepBoBoopSuccess)
      case .Uncomplete:
        notebook.uncomplete(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .BeepBeepFailure)
      case .Unindent:
        notebook.unindent(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .SMSSent)
      case .Delete:
        modalDelete(indexPath: indexPath)
        Util.playSound(systemSound: .BeepBeepFailure)
      }
    }
  }
  
  
  
  // MARK: - refresh
  func tableViewRefresh(refreshControl: UIRefreshControl) {
    notebook = Notebook.getDefault()
    Notebook.set(data: notebook)
    tableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  
  
  // MARK: - buttons
  func settingsButtonPressed(button button: SettingViewController.Button) {
    switch button {
    case .Collapse: notebook.collapseAll(tableView: tableView)
    case .Uncollapse: notebook.uncollapseAll(tableView: tableView)
    case .Delete: modalDeleteAll()
    }
  }
  
  
  
  // MARK: - gestures
  func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    print(notebook)
    Util.playSound(systemSound: .Tap)
    tableView.reloadData()
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
    Util.playSound(systemSound: .Tap)
  }
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if let event = event where event.subtype == .MotionShake {
      modalUndo()
    }
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
    Util.playSound(systemSound: .Tap)
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
    //    controller.selected = activeNotebookNote?.reminder ?? nil
    controller.modalPresentationStyle = .OverCurrentContext
    presentViewController(controller, animated: false, completion: nil)
  }
  
  func modalReminderValue(reminderType reminderType: ReminderType) {
    Util.playSound(systemSound: .Tap)
    
    if reminderType == .Date {
      modalDatePickerDisplay()
      return
    }
    
    if let indexPath = activeNotebookIndexPath {
      let note = notebook.display[indexPath.row]
      if let reminder = note.reminder where reminderType == reminder.type {
        note.deleteReminder()
      } else {
        note.createReminder(controller: self, reminderType: reminderType, date: nil)
      }
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  func modalDelete(indexPath indexPath: NSIndexPath) {
    modalActionSheetConfirmation(title: "Delete") {
      self.notebook.delete(indexPath: indexPath, tableView: self.tableView)
    }
  }
  
  func modalDeleteAll() {
    modalActionSheetConfirmation(title: "Delete completed") {
      self.notebook.deleteAll(tableView: self.tableView)
    }
  }
  
  func modalUndo() {
    if notebook.history.count > 0 {
      modalActionSheetConfirmation(title: "Undo") {
        self.notebook.undo(tableView: self.tableView)
      }
    }
  }
  
  func modalNewNote() -> Note {
    return Note(title: "hello")
  }
  
  func modalActionSheetConfirmation(title title:String, completion: () -> ()) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let delete = UIAlertAction(title: title, style: .Default) { action in
      Util.playSound(systemSound: .BeepBoBoopFailure)
      completion()
    }
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { action in
      Util.playSound(systemSound: .Tap)
    }
    alert.addAction(delete)
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion:nil)
  }
}

