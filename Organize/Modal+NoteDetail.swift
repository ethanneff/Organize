//
//  Modal+NoteDetail.swift
//  Organize
//
//  Created by Ethan Neff on 6/7/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class ModalNoteDetail: Modal, UITextViewDelegate {
  // MARK: - properties
  var note: Note? {
    didSet {
      
    }
  }
  
  private var scrollView: UIScrollView!
  private var header: UITextView!
  private var headerPlaceholder: UILabel!
  private var body: UITextView!
  private var bodyPlaceHolder: UITextView!
  private var yes: UIButton!
  private var headerSeparator: UIView!
  private var topSeparator: UIView!
  private var modalHeightConstraint: NSLayoutConstraint!
  private var modalCenterYConstraint: NSLayoutConstraint!
  private var modalTopConstraint: NSLayoutConstraint!
  private var modalBottomConstraint: NSLayoutConstraint!
  private let modalPadding: CGFloat = Constant.Button.padding*2.5
  
  enum OutputKeys: String {
    case None
  }
  
  // MARK: - init
  override init() {
    super.init()
    createViews()
    createConstraints()
    listenKeyboard()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init coder not implemented")
  }
  
  // MARK: - deinit
  deinit {
    header.removeObserver(self, forKeyPath: "contentSize")
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  // MARK: - create
  private func createViews() {
    scrollView = createScrollView()
    scrollView.backgroundColor = .lightGrayColor()
    scrollView.contentSize = CGSize(width: 0, height: 1000)
    
    header = createTextView()
    header.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    header.textAlignment = .Center
    
    headerSeparator = createSeparator()
    body = createTextView()
    body.tag = 2
    body.textAlignment = .Left
    body.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
    
    topSeparator = createSeparator()
    yes = createButton(title: "Done", confirm: true)
    
    modal.addSubview(scrollView)
    scrollView.addSubview(header)
    scrollView.addSubview(headerSeparator)
    scrollView.addSubview(body)
    modal.addSubview(topSeparator)
    modal.addSubview(yes)
    
    yes.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func createConstraints() {
    modalBottomConstraint = NSLayoutConstraint(item: modal, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -modalPadding)
    modalTopConstraint = NSLayoutConstraint(item: modal, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: modalPadding)
    modalCenterYConstraint =  NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
    modalHeightConstraint = NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.6, constant: 80)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: 80),
      modalHeightConstraint,
      modalCenterYConstraint,
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: header, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: header, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*2),
      NSLayoutConstraint(item: header, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: header, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: headerSeparator, attribute: .Top, relatedBy: .Equal, toItem: header, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
      NSLayoutConstraint(item: headerSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: headerSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: body, attribute: .Top, relatedBy: .Equal, toItem: headerSeparator, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: body, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*5),
      NSLayoutConstraint(item: body, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: body, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
    
    constraintButtonSingleBottom(topSeparator: topSeparator, button: yes)
  }
  
  private func createTextView() -> UITextView {
    let textView = UITextView()
    textView.tag = 1
    textView.delegate = self
    textView.returnKeyType = .Done
    textView.textAlignment = .Center
    textView.font = UIFont.boldSystemFontOfSize(Constant.Button.fontSize)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.tintColor = Constant.Color.button
    
    return textView
  }
  
  private func createPlaceHolderLabel(textView textView: UITextView) -> UILabel {
    let label = UILabel()
    label.text = "Title"
    label.font = .boldSystemFontOfSize(textView.font!.pointSize)
    label.sizeToFit()
    label.textColor = Constant.Color.border
    label.hidden = !textView.text.isEmpty
    label.textAlignment = textView.textAlignment
    textView.addSubview(label)
    
    return label
  }
  
  // MARK: - buttons
  func buttonPressed(button: UIButton) {
    Util.playSound(systemSound: .Tap)
    hide() {
      if let completion = self.completion {
        completion(output: [:])
      }
    }
  }
  
  // MARK: - textview
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    // center vertically
    let textView = object as! UITextView
    var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
    topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
    textView.contentInset.top = topCorrect
  }
  
  // MARK: - keyboard
  private func listenKeyboard() {
    header.delegate = self
    body.delegate = self
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  internal func dismissKeyboard() {
    view.endEditing(true)
  }
  
  internal func keyboardWillShow(notification: NSNotification) {
    updateModalHeightConstraints(show: true, notification: notification)
  }
  
  internal func keyboardWillHide(notification: NSNotification) {
    updateModalHeightConstraints(show: false, notification: notification)
  }
  
  private func updateModalHeightConstraints(show show: Bool, notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let height: CGFloat = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height ?? 0
      let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
      let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
    
      modalBottomConstraint.constant = -height-modalPadding
      
      modalCenterYConstraint.active = false
      modalHeightConstraint.active = false
      modalTopConstraint.active = false
      modalBottomConstraint.active = false
      
      modalCenterYConstraint.active = !show
      modalHeightConstraint.active = !show
      modalTopConstraint.active = show
      modalBottomConstraint.active = show
    
      UIView.animateWithDuration(duration, delay: 0, options: animationCurve, animations: {
        self.view.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  func textViewDidChange(textView: UITextView) {
    handleTitlePlaceholderAndCursor()
  }
  
  private func handleTitlePlaceholderAndCursor() {
    if let placeholder = headerPlaceholder, title = header {
      let labelWidth = placeholder.intrinsicContentSize().width
      let textViewTextSize = title.font!.pointSize
      
      placeholder.frame.origin = CGPointMake(modal.frame.width/2-labelWidth/2, textViewTextSize/2)
      placeholder.hidden = !title.text.isEmpty
      title.textContainerInset = title.text.isEmpty ? UIEdgeInsets(top: textViewTextSize/2, left:labelWidth+textViewTextSize/4, bottom: 0, right: 0) : UIEdgeInsets(top: textViewTextSize/2, left:0, bottom: 0, right: 0)
    }
  }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if textView.tag == 1 && text == "\n" {
      textView.resignFirstResponder()
      buttonPressed(yes)
    }
    
    switch textView.tag {
    case 1: return textView.text.length + (text.length - range.length) <= 80
    default: return true
    }
  }
}

//
//class ModalNoteDetailViewController: UIViewController, UITextViewDelegate {
//  // MARK: - properties
//  weak var delegate: ModalNoteDetailDelegate?
//  weak var data: Note?
//  var indexPath: NSIndexPath?
//
//  let modal: UIView = UIView()
//
//  var titleTextView: UITextView?
//  var titleTextViewPlaceHolder: UILabel?
//  let modalPadding: CGFloat = 25
//  var modalBottomConstraint: NSLayoutConstraint?
//  var tapGesture: UITapGestureRecognizer?
//  var panGesture: UIPanGestureRecognizer?
//
//
//  // MARK: - deinit
//  deinit {
//    dealloc()
//  }
//
//  private func dealloc() {
//    titleTextView = nil
//    titleTextViewPlaceHolder = nil
//    delegate = nil
//    data = nil
//    tapGesture = nil
//    panGesture = nil
//    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    Modal.clear(background: view)
//  }
//
//
//  // MARK: - open
//  override func viewWillAppear(animated: Bool) {
//    super.viewWillAppear(animated)
//    Modal.animateIn(modal: modal, background: view, completion: nil)
//    titleTextView?.text = data?.title
//    titleTextView?.becomeFirstResponder()
//  }
//
//  override func viewDidAppear(animated: Bool) {
//    super.viewDidAppear(animated)
//    handleTitlePlaceholderAndCursor()
//  }
//
//
//  // MARK: - close
//  private func close(confirm confirm: Bool, note: Note?, create: Bool?) {
//    Modal.animateOut(modal: modal, background: view) {
//      self.dismissViewControllerAnimated(false, completion: nil)
//      if let note = note, create = create, indexPath = self.indexPath where confirm {
//        self.delegate?.modalNoteDetailValue(indexPath: indexPath, note: note, create: create)
//      }
//    }
//  }
//
//
//  // MARK: - create
//  override func loadView() {
//    super.loadView()
//    setupView()
//    createGestures()
//    createListeners()
//  }
//
//  private func createGestures() {
//    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_:)))
//    panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPressed(_:)))
//    view.addGestureRecognizer(panGesture!)
//    view.addGestureRecognizer(tapGesture!)
//  }
//
//  private func createListeners() {
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
//  }
//
//  private func setupView() {
//    let yes = createButton(title: Modal.textYes, confirm: true)
//    let no = createButton(title: Modal.textNo, confirm: false)
//    let topSeparator = Modal.createSeparator()
//    let midSeparator = Modal.createSeparator()
//
//    titleTextView = createTextView()
//    titleTextViewPlaceHolder = createPlaceHolderLabel(textView: titleTextView!)
//
//    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
//
//    modal.addSubview(titleTextView!)
//    modal.addSubview(yes)
//    modal.addSubview(no)
//    modal.addSubview(topSeparator)
//    modal.addSubview(midSeparator)
//
//    modalBottomConstraint = NSLayoutConstraint(item: modal, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -modalPadding)
//
//    NSLayoutConstraint.activateConstraints([
//      modalBottomConstraint!,
//      NSLayoutConstraint(item: modal, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: modalPadding),
//      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 0.6, constant: modalPadding*4),
//      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
//
//      NSLayoutConstraint(item: titleTextView!, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Top, relatedBy: .Equal, toItem: modal, attribute: .Top, multiplier: 1, constant: Constant.Button.padding),
//      NSLayoutConstraint(item: titleTextView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height*2),
//
//      // TODO: next 4 are the same as datePicker
//      NSLayoutConstraint(item: no, attribute: .Trailing, relatedBy: .Equal, toItem: midSeparator, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: no, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//
//      NSLayoutConstraint(item: yes, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Leading, relatedBy: .Equal, toItem: midSeparator, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: yes, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
//      NSLayoutConstraint(item: yes, attribute: .Width, relatedBy: .Equal, toItem: no, attribute: .Width, multiplier: 1, constant: 0),
//
//      NSLayoutConstraint(item: topSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: yes, attribute: .Top, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: topSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//
//      NSLayoutConstraint(item: midSeparator, attribute: .Leading, relatedBy: .Equal, toItem: no, attribute: .Trailing, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Bottom, relatedBy: .Equal, toItem: modal, attribute: .Bottom, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Height, relatedBy: .Equal, toItem: no, attribute: .Height, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: midSeparator, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Modal.separator),
//      ])
//  }
//
//  private func createTextView() -> UITextView {
//    let textView = UITextView()
//    textView.tag = 1
//    textView.delegate = self
//    textView.returnKeyType = .Done
//    textView.textAlignment = .Center
//    textView.font = UIFont.boldSystemFontOfSize(Modal.textSize)
//    textView.translatesAutoresizingMaskIntoConstraints = false
//    textView.tintColor = Constant.Color.button
//
//    return textView
//  }
//
//  private func createPlaceHolderLabel(textView textView: UITextView) -> UILabel {
//    let label = UILabel()
//    label.text = "Title"
//    label.font = .boldSystemFontOfSize(textView.font!.pointSize)
//    label.sizeToFit()
//    label.textColor = Constant.Color.border
//    label.hidden = !textView.text.isEmpty
//    label.textAlignment = textView.textAlignment
//    textView.addSubview(label)
//
//    return label
//  }
//
//  private func createButton(title title: String, confirm: Bool) -> UIButton {
//    let button = UIButton()
//    button.tag = Int(confirm)
//    button.layer.cornerRadius = Modal.radius
//    button.setTitle(title, forState: .Normal)
//    button.setTitleColor(Constant.Color.button, forState: .Normal)
//    button.setTitleColor(Constant.Color.border, forState: .Highlighted)
//    button.titleLabel?.font = confirm ? .systemFontOfSize(Modal.textSize) : .boldSystemFontOfSize(Modal.textSize)
//    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
//    button.translatesAutoresizingMaskIntoConstraints = false
//
//    return button
//  }
//
//
//  // MARK: - gestures
//  func tapPressed(gesture: UITapGestureRecognizer) {
//    view.endEditing(true)
//  }
//
//  func panPressed(gesture: UIPanGestureRecognizer) {
//    view.endEditing(true)
//  }
//
//
//  // MARK: - keybaord
//  func keyboardWillShow(notification: NSNotification) {
//    moveModalWithKeyboard(constant: -keyboardHeight(notification: notification)-modalPadding)
//  }
//
//  func keyboardWillHide(notification: NSNotification) {
//    moveModalWithKeyboard(constant: -modalPadding)
//  }
//
//  private func keyboardHeight(notification notification: NSNotification) -> CGFloat {
//    if let info  = notification.userInfo, let value = info[UIKeyboardFrameEndUserInfoKey] {
//      let rawFrame = value.CGRectValue
//      let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
//      return keyboardFrame.height
//    }
//    return 0
//  }
//
//  private func moveModalWithKeyboard(constant constant: CGFloat) {
//    modalBottomConstraint?.constant = constant
//    UIView.animateWithDuration(0.3) {
//      self.view.layoutIfNeeded()
//    }
//  }
//
//  func textViewDidChange(textView: UITextView) {
//    handleTitlePlaceholderAndCursor()
//  }
//
//  private func handleTitlePlaceholderAndCursor() {
//    if let placeholder = titleTextViewPlaceHolder, title = titleTextView {
//      let labelWidth = placeholder.intrinsicContentSize().width
//      let textViewTextSize = title.font!.pointSize
//
//      placeholder.frame.origin = CGPointMake(modal.frame.width/2-labelWidth/2, textViewTextSize/2)
//      placeholder.hidden = !title.text.isEmpty
//      title.textContainerInset = title.text.isEmpty ? UIEdgeInsets(top: textViewTextSize/2, left:labelWidth+textViewTextSize/4, bottom: 0, right: 0) : UIEdgeInsets(top: textViewTextSize/2, left:0, bottom: 0, right: 0)
//    }
//  }
//
//  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//    if text == "\n" {
//      textView.resignFirstResponder()
//      submitNote(confirm: true)
//    }
//
//    switch textView.tag {
//    case 1: return textView.text.length + (text.length - range.length) <= 80
//    default: return true
//    }
//  }
//
//
//  // MARK: - buttons
//  internal func buttonPressed(button: UIButton) {
//    Util.animateButtonPress(button: button)
//    Util.playSound(systemSound: .Tap)
//    submitNote(confirm: Bool(button.tag))
//  }
//
//
//  // MARK: - validation
//  private func submitNote(confirm confirm: Bool) {
//    if confirm {
//      guard let title = titleTextView?.text where title.length > 0 else {
//        close(confirm: false, note: nil, create: nil)
//        return
//      }
//
//      let create = data == nil ? true : false
//      let note = data ?? Note(title: title)
//      note.title = title.trim
//
//      close(confirm: true, note: note, create: create)
//      return
//    }
//
//    close(confirm: false, note: nil, create: nil)
//  }
//}