import UIKit
import MessageUI
import Firebase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, ListTableViewCellDelegate, SettingsDelegate, ReorderTableViewDelegate {
  // MARK: - properties
  var notebook: Notebook
  
  lazy var tableView: UITableView = ReorderTableView()
  weak var addButton: UIButton!
  weak var menuDelegate: MenuViewController?
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    refreshControl.tintColor = Constant.Color.border
    return refreshControl
  }()
  
  // modals (let for common, lazy for rare)
  let modalNoteDetail: ModalNoteDetail = ModalNoteDetail()
  
  // MARK: - init
  init() {
    if Constant.App.release {
      notebook = Notebook(notes: [], display: [], history: [])
    } else {
      notebook = Notebook.getDefault()
    }
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
  
  // MARK: - deinit
  deinit {
    print("list deinit)")
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    // FIXME: dismiss viewcontollor does not call deinit (reference cycle)
  }
  
  // MARK: - error
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - appear
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // shake
    self.becomeFirstResponder()
  }
  
  
  // MARK: - load
  internal func applicationDidBecomeActiveNotification() {
    // update reminder icons
    tableView.reloadData()
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
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
    tableView.backgroundColor = Constant.Color.background
    
    // borders
    tableView.contentInset = UIEdgeInsetsZero
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.separatorColor = Constant.Color.border
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    if #available(iOS 9.0, *) {
      tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    tableView.layoutMargins = UIEdgeInsetsZero
    
    // constraints
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
      ])
  }
  
  private func createAddButton() {
    let button = UIButton()
    let buttonSize = Constant.Button.height*1.33
    let image = UIImage(named: "icon-add")!
    let imageView = Util.imageViewWithColor(image: image, color: Constant.Color.background)
    view.addSubview(button)
    button.layer.cornerRadius = buttonSize/2
    // TODO: make shadow same as menu
    button.layer.shadowColor = UIColor.blackColor().CGColor
    button.layer.shadowOffset = CGSizeMake(0, 2)
    button.layer.shadowOpacity = 0.2
    button.layer.shadowRadius = 2
    button.layer.masksToBounds = false
    button.backgroundColor = Constant.Color.button
    button.tintColor = Constant.Color.background
    button.setImage(imageView.image, forState: .Normal)
    button.setImage(imageView.image, forState: .Highlighted)
    button.addTarget(self, action: #selector(addButtonPressed(_:)), forControlEvents: .TouchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding*2),
      NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -Constant.Button.padding*2),
      NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonSize),
      NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonSize),
      ])
    addButton = button
  }
  
  private func createGestures() {
    // double tap
    let gestureDoubleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedDoubleTap(_:)))
    gestureDoubleTap.numberOfTapsRequired = 2
    gestureDoubleTap.numberOfTouchesRequired = 1
    tableView.addGestureRecognizer(gestureDoubleTap)
    
    // single tap
    let gestureSingleTap = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizedSingleTap(_:)))
    gestureSingleTap.numberOfTapsRequired = 1
    gestureSingleTap.numberOfTouchesRequired = 1
    gestureSingleTap.requireGestureRecognizerToFail(gestureDoubleTap)
    tableView.addGestureRecognizer(gestureSingleTap)
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
  
  // MARK: - refresh
  func tableViewRefresh(refreshControl: UIRefreshControl) {
    if Constant.App.release {
      notebook.display = notebook.notes
    } else {
      notebook = Notebook.getDefault()
    }
    notebook.uncollapseAll(tableView: tableView)
    refreshControl.endRefreshing()
  }
  
  // MARK - swipe
  func cellSwiped(type type: SwipeType, cell: UITableViewCell) {
    Util.playSound(systemSound: .Tap)
    if let indexPath = tableView.indexPathForCell(cell) {
      switch type {
      case .Complete: notebook.complete(indexPath: indexPath, tableView: tableView)
      case .Indent: notebook.indent(indexPath: indexPath, tableView: tableView)
      case .Reminder: displayReminder(indexPath: indexPath)
      case .Uncomplete: notebook.uncomplete(indexPath: indexPath, tableView: tableView)
      case .Unindent: notebook.unindent(indexPath: indexPath, tableView: tableView)
      case .Delete: displayDeleteCell(indexPath: indexPath)
      }
    }
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
      // FIXME: v2
      displayUndo()
    }
  }
  
  // MARK: - buttons
  func settingsButtonPressed(button button: SettingViewController.Button) {
    switch button {
    case .NotebookTitle: displayNotebookTitle()
    case .NotebookCollapse: notebook.collapseAll(tableView: tableView)
    case .NotebookUncollapse: notebook.uncollapseAll(tableView: tableView)
    case .NotebookDeleteCompleted: displayDeleteCompleted()
      
    case .SettingsTutorial: displayTutorial()
      
    case .SocialFeedback: displaySocialFeedback()
    case .SocialShare: displaySocialShare()
      
    case .AccountEmail: displayAccountEmail()
    case .AccountPassword: displayAccountPassword()
    case .AccountDelete: displayAccountDelete()
    case .AccountLogout: logout()
      
    default: break
    }
  }
  
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
  
  func addButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    modalNoteDetailDisplay(indexPath: NSIndexPath(forRow: 0, inSection: 0), create: true)
  }
  
  private func logout() {
    Remote.Auth.logout()
    Report.sharedInstance.track(event: "logout")
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - modals
  private func displayNotebookTitle() {
    let modal = ModalTextField()
    modal.limit = 25
    // TODO: get notebook title (add field)
    modal.placeholder = "notebook title"
    modal.show(controller: self, dismissible: true) { output in
      if let title = output[ModalTextField.OutputKeys.Text.rawValue] as? String, let menuController = self.navigationController?.childViewControllers.first as? MenuViewController {
        menuController.createNavTitle(title: title)
        // TODO: Save
      }
    }
  }
  
  private func displayTutorial() {
    let modal = ModalTutorial()
    modal.show(controller: self, dismissible: true)
  }
  
  private func displayDeleteCompleted() {
    let modal = ModalConfirmation()
    modal.message = "Permanently delete all completed?"
    modal.show(controller: self, dismissible: false) { (output) in
      self.notebook.deleteAll(tableView: self.tableView)
    }
  }
  
  private func displayDeleteCell(indexPath indexPath: NSIndexPath) {
    let modal = ModalConfirmation()
    modal.message = "Permanently delete?"
    modal.show(controller: self, dismissible: false) { (output) in
      self.notebook.delete(indexPath: indexPath, tableView: self.tableView)
    }
  }
  
  private func displayReminder(indexPath indexPath: NSIndexPath) {
    let note = notebook.display[indexPath.row]
    if !note.completed {
      let modal = ModalReminder()
      modal.reminder = note.reminder ?? nil
      modal.show(controller: self, dismissible: true, completion: { (output) in
        if let id = output[ModalReminder.OutputKeys.ReminderType.rawValue] as? Int, let reminderType = ReminderType(rawValue: id) {
          if reminderType == .Date {
            if let reminder = self.notebook.display[indexPath.row].reminder where reminder.type == .Date {
              // delete custom date
              self.createReminder(indexPath: indexPath, type: reminderType, date: nil)
            } else {
              // create custom date
              self.displayReminderDatePicker(indexPath: indexPath)
            }
          } else {
            // delete and create select date
            self.createReminder(indexPath: indexPath, type: reminderType, date: nil)
          }
        }
      })
    }
  }
  
  private func displayReminderDatePicker(indexPath indexPath: NSIndexPath) {
    let modal = ModalDatePicker()
    modal.show(controller: self, dismissible: true) { (output) in
      if let date = output[ModalDatePicker.OutputKeys.Date.rawValue] as? NSDate {
        self.createReminder(indexPath: indexPath, type: .Date, date: date)
      }
    }
  }
  
  private func createReminder(indexPath indexPath: NSIndexPath, type: ReminderType, date: NSDate?) {
    notebook.reminder(indexPath: indexPath, controller: self, tableView: tableView, reminderType: type, date: date) { success, create in
      if success {
        Util.playSound(systemSound: create ? .BeepBoBoopSuccess : .BeepBoBoopFailure)
      }
    }
  }
  
  private func displaySocialShare() {
    
  }
  
  private func displaySocialFeedback() {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients(["ethan.neff@eneff.com"])
      mail.setSubject("I have feedback for your Organize app!")
      mail.setMessageBody("<p>Hey Ethan,</p></br>", isHTML: true)
      presentViewController(mail, animated: true, completion: nil)
    } else {
      let modal = ModalError()
      modal.message = "Please check your email configuration and try again"
      modal.show(controller: self)
    }
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    switch result.rawValue {
    default: Util.playSound(systemSound: .Tap)
    }
  }
  
  private func displayAccountEmail() {
    let modal = ModalTextField()
    modal.placeholder = Remote.Auth.user?.email ?? "new email"
    modal.show(controller: self, dismissible: true) { (output) in
      if let email = output[ModalTextField.OutputKeys.Text.rawValue] as? String where email.isEmail {
        Remote.Auth.changeEmail(controller: self, email: email, completion: { error in
          let message = error ?? "Log back in with your new email"
          let modal = ModalError()
          modal.message = message
          modal.show(controller: self) { (output) in
            if let _ = error { } else {
              self.logout()
            }
          }
        })
      } else {
        let modal = ModalError()
        modal.message = AccessBusinessLogic.ErrorMessage.EmailInvalid.message
        modal.show(controller: self) { (output) in
          self.displayAccountEmail()
        }
      }
    }
  }
  
  private func displayAccountPassword() {
    let modal = ModalTextField()
    modal.placeholder = "new password"
    modal.show(controller: self, dismissible: true) { (output) in
      if let password = output[ModalTextField.OutputKeys.Text.rawValue] as? String where password.isPassword {
        Remote.Auth.changePassword(controller: self, password: password, completion: { error in
          let message = error ?? "Log back in with your new password"
          let modal = ModalError()
          modal.message = message
          modal.show(controller: self) { (output) in
            if let _ = error { } else {
              self.logout()
            }
          }
        })
      } else {
        let modal = ModalError()
        modal.message = AccessBusinessLogic.ErrorMessage.PasswordInvalid.message
        modal.show(controller: self, dismissible: true) { (output) in
          self.displayAccountEmail()
        }
      }
    }
  }
  
  private func displayAccountDelete() {
    let modal = ModalConfirmation()
    modal.message = "Permanently delete account and all data related to it?"
    modal.show(controller: self, dismissible: true) { (output) in
      Remote.Auth.delete(controller: self, completion: { (error) in
        if let error = error {
          let modal = ModalError()
          modal.message = error
          modal.show(controller: self)
        } else {
          self.logout()
        }
      })
    }
  }
  
  private func displayUndo() {
    let modal = ModalConfirmation()
    modal.message = "Undo last action?"
    modal.show(controller: self, dismissible: false) { (output) in
      self.notebook.undo(tableView: self.tableView)
    }
  }
  
  // MARK: - modal note detail
  func modalNoteDetailDisplay(indexPath indexPath: NSIndexPath, create: Bool) {
    //    modalNoteDetail.delegate = self
    //    modalNoteDetail.indexPath = indexPath
    //    modalNoteDetail.data = create ? nil : notebook.display[indexPath.row]
    //    modalPresent(controller: modalNoteDetail)
  }
  
  func modalNoteDetailValue(indexPath indexPath: NSIndexPath, note: Note, create: Bool) {
    if create {
      notebook.create(indexPath: indexPath, tableView: tableView, note: note)
    } else {
      notebook.update(indexPath: indexPath, tableView: tableView, note: note)
    }
  }
}