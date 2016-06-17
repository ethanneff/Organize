import UIKit
import MessageUI
import Firebase
import GoogleMobileAds

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, ListTableViewCellDelegate, SettingsDelegate, ReorderTableViewDelegate,GADBannerViewDelegate {
  // MARK: - properties
  private var notebook: Notebook
  
  lazy var tableView: UITableView = ReorderTableView()
  weak var menuDelegate: MenuViewController?
  private var addButton: UIButton!
  private var bannerAd: GADBannerView!
  private var bannerAdHeight: CGFloat = 50
  private var tableViewBottomConstraint: NSLayoutConstraint!
  private var addButtonBottomPadding: CGFloat = Constant.Button.padding*2
  private var addButtonBottomConstraint: NSLayoutConstraint!
  
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    refreshControl.tintColor = Constant.Color.title.colorWithAlphaComponent(0.5)
    return refreshControl
  }()
  
  // MARK: - init
  init() {
    notebook = Notebook(title: "init")
    super.init(nibName: nil, bundle: nil)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  private func initialize() {
    createBannerAd()
    createTableView()
    createAddButton()
    createGestures()
    loadNotebook()
    loadListeners()
  }
  
  // MARK: - deinit
  deinit {
    print("list deinit)")
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillTerminateNotification, object: nil)
    // FIXME: dismiss viewcontollor does not call deinit (reference cycle) (has to do with menu)
  }
  
  // MARK: - error
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - appear
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // config
    loadRemoteConfig()
    // title
    updateTitle()
    // accessed
    Remote.User.open()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // shake
    becomeFirstResponder()
  }
  
  
  // MARK: - load
  internal func applicationDidBecomeActiveNotification() {
    // update reminder icons
    tableView.reloadData()
  }
  
  internal func applicationDidBecomeInactiveNotification() {
    Remote.Auth.upload(notebook: notebook)
  }
  
  private func loadNotebook() {
    Notebook.get { data in
      if let data = data {
        Util.threadMain {
          self.notebook = data
          self.tableView.reloadData()
          self.updateTitle()
        }
      } else {
        self.displayLogout()
      }
    }
  }
  
  private func loadListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeInactiveNotification), name: UIApplicationWillResignActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeInactiveNotification), name: UIApplicationWillTerminateNotification, object: nil)
  }
  
  private func loadRemoteConfig() {
    Remote.Config.fetch { config in
      if let config = config {
        if config[Remote.Config.Keys.ShowAds.rawValue].boolValue {
          self.loadBannerAd()
        }
      }
    }
  }
  
  // MARK: - create
  private func createBannerAd() {
    bannerAd = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    view.addSubview(bannerAd)
    bannerAd.delegate = self
    bannerAd.rootViewController = self
    bannerAd.adUnitID = Constant.App.firebaseBannerAdUnitID
    bannerAd.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: bannerAd, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bannerAdHeight),
      NSLayoutConstraint(item: bannerAd, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: bannerAd, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: bannerAd, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0),
      ])
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
    tableViewBottomConstraint = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0),
      tableViewBottomConstraint,
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
    addButtonBottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -addButtonBottomPadding)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -addButtonBottomPadding),
      addButtonBottomConstraint,
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
  
  private func updateTitle() {
    if let controller = self.navigationController?.childViewControllers.first {
      controller.navigationItem.title = notebook.title
    }
  }
  
  // MARK: - banner
  private func loadBannerAd() {
    let request = GADRequest()
    request.testDevices = Constant.App.firebaseTestDevices
    bannerAd.loadRequest(request)
  }
  
  internal func adViewDidReceiveAd(bannerView: GADBannerView!) {
    displayBannerAd(show: true)
  }
  
  internal func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }
  
  private func displayBannerAd(show show: Bool) {
    tableViewBottomConstraint.constant = show ? -bannerAdHeight : 0
    addButtonBottomConstraint.constant = show ? -bannerAdHeight-addButtonBottomPadding : 0
    UIView.animateWithDuration(0.3, animations: {
      self.view.layoutIfNeeded()
    })
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
    refreshControl.endRefreshing()
    let modal = ModalConfirmation()
    modal.message = "Download from cloud and overwrite data on device?"
    modal.show(controller: self, dismissible: true) { (output) in
      Remote.Auth.download(controller: self) { (error) in
        if let error = error {
          let modal = ModalError()
          modal.message = error
          modal.show(controller: self)
          return
        }
        self.loadNotebook()
      }
    }
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
    Util.playSound(systemSound: .Tap)
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
    Util.playSound(systemSound: .Tap)
  }
  
  // MARK: - gestures
  func gestureRecognizedSingleTap(gesture: UITapGestureRecognizer) {
    let location = gesture.locationInView(tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) {
      Util.animateButtonPress(button: cell)
      displayNoteDetail(indexPath: indexPath, create: false)
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
      // FIXME: undo in v2
      // displayUndo()
    }
  }
  
  // MARK: - buttons
  func settingsButtonPressed(button button: SettingViewController.Button) {
    switch button {
    case .NotebookTitle: displayNotebookTitle()
    case .NotebookCollapse: notebook.collapseAll(tableView: tableView)
    case .NotebookUncollapse: notebook.uncollapseAll(tableView: tableView)
    case .NotebookDeleteCompleted: displayDeleteCompleted()
      
    case .AppTutorial: displayAppTutorial()
    case .AppColor: displayAppColor()
    case .AppFeedback: displayAppFeedback()
    case .AppShare: displayAppShare()
      
    case .AccountEmail: displayAccountEmail()
    case .AccountPassword: displayAccountPassword()
    case .AccountDelete: displayAccountDelete()
    case .AccountLogout: attemptLogout()
      
    default: break
    }
  }
  
  func cellAccessoryButtonPressed(cell cell: UITableViewCell) {
    if let indexPath = tableView.indexPathForCell(cell) {
      let item = notebook.display[indexPath.row]
      if item.collapsed {
        notebook.uncollapse(indexPath: indexPath, tableView: tableView)
      } else {
        displayNoteDetail(indexPath: NSIndexPath(forRow: indexPath.row+1, inSection: indexPath.section), create: true)
      }
    }
  }
  
  func addButtonPressed(button: UIButton) {
    Util.animateButtonPress(button: button)
    displayNoteDetail(indexPath: NSIndexPath(forRow: 0, inSection: 0), create: true)
  }
  
  private func displayLogout() {
    let modal = ModalError()
    modal.message = "An error has occured and you will need to log back in"
    modal.show(controller: self) { output in
      self.logout()
    }
  }
  
  private func attemptLogout() {
    Remote.Auth.logout(controller: self, notebook: notebook) { error in
      if let error = error {
        let modal = ModalError()
        modal.message = error
        modal.show(controller: self)
        return
      }
      self.logout()
    }
  }
  
  private func logout() {
    Report.sharedInstance.track(event: "logout")
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - modals
  private func displayNotebookTitle() {
    //    dismissViewControllerAnimated(true, completion: nil)
    //    PushNotification.sharedInstance.registerPermission()
    
    let modal = ModalTextField()
    modal.limit = 25
    modal.placeholder = notebook.title
    modal.show(controller: self, dismissible: true) { output in
      if let title = output[ModalTextField.OutputKeys.Text.rawValue] as? String {
        self.notebook.title = title
        self.updateTitle()
      }
    }
  }
  
  private func displayAppTutorial() {
    let modal = ModalTutorial()
    modal.show(controller: self, dismissible: true)
  }
  
  private func displayAppColor() {
    Constant.Color.toggleColor()
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func displayDeleteCompleted() {
    if notebook.hasCompleted {
      let modal = ModalConfirmation()
      modal.message = "Permanently delete all completed?"
      modal.show(controller: self, dismissible: false) { (output) in
        self.notebook.deleteAll(tableView: self.tableView)
      }
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
        Util.playSound(systemSound: .Tap)
        //        Util.playSound(systemSound: create ? .BeepBoBoopSuccess : .BeepBoBoopFailure)
      }
    }
  }
  
  private func displayAppFeedback() {
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
  
  private func displayAppShare() {
    let shareContent: String = "Check out this app!\n\nI've been using it quite a bit and I think you'll like it too. Tell me what you think.\n\n" + Constant.App.deepLinkUrl
    let activityViewController: ActivityViewController = ActivityViewController(activityItems: [shareContent], applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
    presentViewController(activityViewController, animated: true, completion: nil)
  }
  
  private func displayAccountEmail() {
    let modal = ModalTextField()
    modal.placeholder = Remote.Auth.user?.email ?? "new email"
    modal.keyboardType = .EmailAddress
    modal.show(controller: self, dismissible: true) { (output) in
      if let email = output[ModalTextField.OutputKeys.Text.rawValue] as? String where email.isEmail {
        Remote.Auth.changeEmail(controller: self, email: email, completion: { error in
          // FIXME: catch error 17014 and force logout? (minor)
          // FIXME: if no wifi on simulator, causes a flash in modals because loading.hide happens before loading.show finshes (minor)
          let message = error ?? "Log back in with your new email"
          let modal = ModalError()
          modal.message = message
          modal.show(controller: self) { (output) in
            if let _ = error {
              // close
            } else {
              self.attemptLogout()
            }
          }
        })
      } else {
        let modal = ModalError()
        modal.message = AccessBusinessLogic.ErrorMessage.EmailInvalid.message
        modal.show(controller: self) { (output) in
          // TODO: pass previous text through
          self.displayAccountEmail()
        }
      }
    }
  }
  
  private func displayAccountPassword() {
    let modal = ModalTextField()
    modal.placeholder = "new password"
    modal.secureEntry = true
    modal.show(controller: self, dismissible: true) { (output) in
      if let password = output[ModalTextField.OutputKeys.Text.rawValue] as? String where password.isPassword {
        Remote.Auth.changePassword(controller: self, password: password, completion: { error in
          let message = error ?? "Log back in with your new email"
          let modal = ModalError()
          modal.message = message
          modal.show(controller: self) { (output) in
            if let _ = error {
              // close
            } else {
              self.attemptLogout()
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
  
  private func displayNoteDetail(indexPath indexPath: NSIndexPath, create: Bool) {
    let note: Note? = create ? nil : notebook.display[indexPath.row]
    let modal = ModalNoteDetail()
    modal.note = note
    modal.show(controller: self, dismissible: false) { (output) in
      if let note = output[ModalNoteDetail.OutputKeys.Note.rawValue] as? Note {
        if create {
          self.notebook.create(indexPath: indexPath, tableView: self.tableView, note: note)
        } else {
          self.notebook.update(indexPath: indexPath, tableView: self.tableView, note: note)
        }
      }
    }
  }
}