import UIKit
import MessageUI

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ModalDatePickerDelegate, ModalReminderDelegate, ModalNoteDetailDelegate, ListTableViewCellDelegate, SettingsDelegate, ReorderTableViewDelegate, MFMailComposeViewControllerDelegate {
  // MARK: - properties
  var notebook: Notebook
  
  lazy var tableView: UITableView = ReorderTableView()
  var addButton: UIButton?
  var gestureDoubleTap: UITapGestureRecognizer?
  var gestureSingleTap: UITapGestureRecognizer?
  weak var menuDelegate: MenuViewController?
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    refreshControl.tintColor = Config.colorBorder
    return refreshControl
  }()
  
  // properties to reload the modals faster (instead of creating each time) - lazy for rare modals
  let modalNoteDetail: ModalNoteDetailViewController = ModalNoteDetailViewController()
  lazy var modalReminder: ModalReminderViewController = ModalReminderViewController()
  lazy var modalDatePicker: ModalDatePickerViewController = ModalDatePickerViewController()
  
  // MARK: - init
  init() {
    //    notebook = Notebook.getDefault()
    notebook = Notebook(notes: [], display: [], history: [])
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
    createAddButton()
    createGestures()
  }
  
  private func loadNotebook() {
    Notebook.get { data in
      if let data = data {
        Util.threadMain {
          self.notebook = data
          self.tableView.reloadData()
        }
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
    // FIXME: dismiss viewcontollor does not call deinit (reference cycle)
    dealloc()
  }
  
  private func dealloc() {
    addButton = nil
    gestureDoubleTap = nil
    gestureSingleTap = nil
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  func applicationWillResignActiveNotification() {}
  
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
    if let tableView = tableView as? ReorderTableView {
      tableView.reorderDelegate = self
    }
    
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
  
  private func createAddButton() {
    let button = UIButton()
    let buttonSize = Config.buttonHeight*1.33
    let image = UIImage(named: "icon-add")!
    let imageView = Util.imageViewWithColor(image: image, color: Config.colorBackground)
    view.addSubview(button)
    button.layer.cornerRadius = buttonSize/2
    // TODO: make shadow same as menu
    button.layer.shadowColor = UIColor.blackColor().CGColor
    button.layer.shadowOffset = CGSizeMake(0, 2)
    button.layer.shadowOpacity = 0.2
    button.layer.shadowRadius = 2
    button.layer.masksToBounds = false
    button.backgroundColor = Config.colorButton
    button.tintColor = Config.colorBackground
    button.setImage(imageView.image, forState: .Normal)
    button.setImage(imageView.image, forState: .Highlighted)
    button.addTarget(self, action: #selector(addButtonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      button.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -Config.buttonPadding*2),
      button.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -Config.buttonPadding*2),
      button.heightAnchor.constraintEqualToConstant(buttonSize),
      button.widthAnchor.constraintEqualToConstant(buttonSize),
      ])
    addButton = button
  }
  
  func addButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    modalNoteDetailDisplay(indexPath: NSIndexPath(forRow: 0, inSection: 0), create: true)
    Util.playSound(systemSound: .Tap)
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
    addButton?.hidden = notebook.display.count > 0
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
  
  
  
  // MARK - cell accessory button
  func cellAccessoryButtonPressed(cell cell: UITableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let item = notebook.display[indexPath.row]
      if item.collapsed {
        notebook.uncollapse(indexPath: indexPath, tableView: tableView)
      } else {
        modalNoteDetailDisplay(indexPath: NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section), create: true)
      }
    }
  }
  
  
  
  // MARK - swipe
  func cellSwiped(type type: SwipeType, cell: UITableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      
      switch type {
      case .Complete:
        notebook.complete(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .BeepBeepSuccess)
      case .Indent:
        notebook.indent(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .Tap)
      case .Reminder:
        modalReminderDisplay(indexPath: indexPath)
        Util.playSound(systemSound: .Tap)
      case .Uncomplete:
        notebook.uncomplete(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .BeepBeepFailure)
      case .Unindent:
        notebook.unindent(indexPath: indexPath, tableView: tableView)
        Util.playSound(systemSound: .Tap)
      case .Delete:
        modalDelete(indexPath: indexPath)
        Util.playSound(systemSound: .Tap)
      }
    }
  }
  
  
  
  // MARK: - refresh
  func tableViewRefresh(refreshControl: UIRefreshControl) {
    //    notebook = Notebook.getDefault()
    notebook.display = notebook.notes
    Notebook.set(data: notebook)
    tableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  
  
  
  // MARK: - reorder
  func reorderBeforeLift(fromIndexPath: NSIndexPath, completion: () -> ()) {
    notebook.reorderBeforeLift(indexPath: fromIndexPath, tableView: tableView) {
      completion()
    }
  }
  
  func reorderAfterLift(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) {
    notebook.reorderAfterLift(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath) {
      completion()
    }
  }
  
  func reorderDuringMove(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) {
    notebook.reorderDuringMove(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath) {
      completion()
    }
  }
  
  func reorderAfterDrop(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath, completion: () -> ()) {
    notebook.reorderAfterDrop(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath, tableView: tableView) {
      completion()
    }
  }
  
  
  
  // MARK: - buttons
  func settingsButtonPressed(button button: SettingViewController.Button) {
    switch button {
    case .Collapse: notebook.collapseAll(tableView: tableView)
    case .Uncollapse: notebook.uncollapseAll(tableView: tableView)
    case .Delete: modalDeleteAll()
    case .Feedback: modalFeedback()
    case .Tutorial: modalTutorial()
    }
  }
  
  
  
  // MARK: - gestures
  func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(location) {
      modalNoteDetailDisplay(indexPath: indexPath, create: false)
      Util.playSound(systemSound: .Tap)
    }
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
      Util.playSound(systemSound: .Tap)
    }
  }
  
  
  // MARK: - shake
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if let event = event where event.subtype == .MotionShake {
      // TODO: v2
      // modalUndo()
    }
  }
  
  
  // MARK: - modal reminder
  func modalReminderDisplay(indexPath indexPath: NSIndexPath) {
    let note = notebook.display[indexPath.row]
    if !note.completed {
      modalReminder.delegate = self
      modalReminder.data = note.reminder ?? nil
      modalReminder.indexPath = indexPath
      modalPresent(controller: modalReminder)
    }
  }
  
  func modalReminderValue(indexPath indexPath: NSIndexPath, reminderType: ReminderType) {
    if reminderType == .Date {
      if let reminder = notebook.display[indexPath.row].reminder where reminder.type == .Date {
        createReminder(indexPath: indexPath, type: reminderType, date: nil)
      } else {
        modalDatePickerDisplay(indexPath: indexPath)
      }
    } else {
      createReminder(indexPath: indexPath, type: reminderType, date: nil)
    }
  }
  
  private func createReminder(indexPath indexPath: NSIndexPath, type: ReminderType, date: NSDate?) {
    notebook.reminder(indexPath: indexPath, controller: self, tableView: tableView, reminderType: type, date: date) { success, create in
      if success {
        Util.playSound(systemSound: create ? .BeepBoBoopSuccess : .BeepBoBoopFailure)
      }
    }
  }
  
  
  
  // MARK: - modal date picker
  func modalDatePickerDisplay(indexPath indexPath: NSIndexPath) {
    modalDatePicker.delegate = self
    modalDatePicker.data = notebook.display[indexPath.row].reminder ?? nil
    modalDatePicker.indexPath = indexPath
    modalPresent(controller: modalDatePicker)
  }
  
  func modalDatePickerValue(indexPath indexPath: NSIndexPath, date: NSDate) {
    createReminder(indexPath: indexPath, type: .Date, date: date)
  }
  
  
  
  
  // MARK: - modal delete
  private func modalDelete(indexPath indexPath: NSIndexPath) {
    modalActionSheetConfirmation(title: "Delete") {
      self.notebook.delete(indexPath: indexPath, tableView: self.tableView)
    }
  }
  
  private func modalDeleteAll() {
    if notebook.display.count > 0 {
      modalActionSheetConfirmation(title: "Delete completed") {
        self.notebook.deleteAll(tableView: self.tableView)
      }
    }
  }
  
  
  
  // MARK: - modal undo
  private func modalUndo() {
    if notebook.history.count > 0 {
      modalActionSheetConfirmation(title: "Undo") {
        self.notebook.undo(tableView: self.tableView)
      }
    }
  }
  
  
  
  // MARK: - modal tutorial
  private func modalTutorial() {
    let controller = ModalTutorialViewController()
    modalPresent(controller: controller)
  }
  
  
  
  // MARK: - modal feedback
  private func modalFeedback() {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients(["ethan-neff@msn.com"])
      mail.setSubject("I have some feedback for your Organize app!")
      mail.setMessageBody("<p>Hey Ethan,</p></br>", isHTML: true)
      presentViewController(mail, animated: true, completion: nil)
    } else {
      modalError(title: "Could not send email", message: "Please check your email configuration and try again", completion: nil)
    }
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    switch result.rawValue {
    case 2: Util.playSound(systemSound: .BeepBoBoopSuccess)
    default: Util.playSound(systemSound: .BeepBoBoopFailure)
    }
  }
  
  
  
  // MARK: - modal note detail
  func modalNoteDetailDisplay(indexPath indexPath: NSIndexPath, create: Bool) {
    modalNoteDetail.delegate = self
    modalNoteDetail.indexPath = indexPath
    modalNoteDetail.data = create ? nil : notebook.display[indexPath.row]
    modalPresent(controller: modalNoteDetail)
  }
  
  func modalNoteDetailValue(indexPath indexPath: NSIndexPath, note: Note, create: Bool) {
    if create {
      notebook.create(indexPath: indexPath, tableView: tableView, note: note)
    } else {
      notebook.update(indexPath: indexPath, tableView: tableView, note: note)
    }
  }
  
  
  
  // MARK: - modal helper functions
  private func modalPresent(controller controller: UIViewController) {
    controller.modalPresentationStyle = .OverCurrentContext
    presentViewController(controller, animated: false, completion: nil)
  }
  
  private func modalActionSheetConfirmation(title title: String, completion: () -> ()) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let confirm = UIAlertAction(title: title, style: .Default) { action in
      Util.playSound(systemSound: .BeepBoBoopFailure)
      completion()
    }
    let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { action in
      Util.playSound(systemSound: .Tap)
    }
    alert.addAction(confirm)
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion:nil)
  }
  
  private func modalError(title title: String, message: String?, completion: (() -> ())?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let delete = UIAlertAction(title: "Okay", style: .Default) { action in
      Util.playSound(systemSound: .BeepBoBoopFailure)
    }
    alert.addAction(delete)
    presentViewController(alert, animated: true, completion:nil)
  }
}