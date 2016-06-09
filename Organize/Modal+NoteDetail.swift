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
  private var body: UITextView!
  private var headerPlaceholder: UILabel!
  private var bodyPlaceholder: UILabel!
  private var yes: UIButton!
  private var no: UIButton!
  
  private var tagWhen: UIButton!
  private var tagWhere: UIButton!
  private var tagWhat: UIButton!
  private var tagWho: UIButton!
  private var headerSeparator: UIView!
  private var tagSeparator: UIView!
  private var topSeparator: UIView!
  private var midSeparator: UIView!
  private var modalHeightConstraint: NSLayoutConstraint!
  private var modalCenterYConstraint: NSLayoutConstraint!
  private var modalTopConstraint: NSLayoutConstraint!
  private var modalBottomConstraint: NSLayoutConstraint!
  private let modalPadding: CGFloat = Constant.Button.padding*2.5
  
  enum OutputKeys: String {
    case Note
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
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
  }
  
  // MARK: - open  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    handlePlaceholderAndCursor(textView: header, placeholder: headerPlaceholder, header: true)
    handlePlaceholderAndCursor(textView: body, placeholder: bodyPlaceholder, header: false)
  }
  
  // MARK: - create
  private func createViews() {
    scrollView = createScrollView()
    // set mininum for horizontal rotation
    scrollView.contentSize = CGSize(width: 0, height: 300)
    
    header = createTextView(header: true)
    body = createTextView(header: false)
    headerPlaceholder = createPlaceholderLabel(textView: header, header: true)
    bodyPlaceholder = createPlaceholderLabel(textView: body, header: false)
    header.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    header.textAlignment = .Center
    
    tagWhen = createButton(title: "when", confirm: true)
    tagWhere = createButton(title: "where", confirm: true)
    tagWhat = createButton(title: "what", confirm: true)
    tagWho = createButton(title: "who", confirm: true)
    
    headerSeparator = createSeparator()
    tagSeparator = createSeparator()
    topSeparator = createSeparator()
    midSeparator = createSeparator()
    
    yes = createButton(title: nil, confirm: true)
    no = createButton(title: nil, confirm: false)
    
    modal.addSubview(scrollView)
    scrollView.addSubview(header)
    scrollView.addSubview(body)
    scrollView.addSubview(tagWhen)
    scrollView.addSubview(tagWhere)
    scrollView.addSubview(tagWhat)
    scrollView.addSubview(tagWho)
    scrollView.addSubview(headerSeparator)
    scrollView.addSubview(tagSeparator)
    modal.addSubview(topSeparator)
    modal.addSubview(midSeparator)
    modal.addSubview(yes)
    modal.addSubview(no)
    
    yes.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    no.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
  }
  
  private func createConstraints() {
    // FIXME: constraint breaks when horizontal, keyboard up, on iphone
    constraintButtonDoubleBottom(topSeparator: topSeparator, midSeparator: midSeparator, left: no, right: yes)
    
    modalBottomConstraint = NSLayoutConstraint(item: modal, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -modalPadding)
    modalTopConstraint = NSLayoutConstraint(item: modal, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: modalPadding)
    modalCenterYConstraint =  NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
    modalHeightConstraint = NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 0.6, constant: 120)
    
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
    
    //    NSLayoutConstraint.activateConstraints([
    //      NSLayoutConstraint(item: tagWhen, attribute: .Top, relatedBy: .Equal, toItem: headerSeparator, attribute: .Bottom, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhen, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
    //      NSLayoutConstraint(item: tagWhen, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhen, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
    //      ])
    //    NSLayoutConstraint.activateConstraints([
    //      NSLayoutConstraint(item: tagWhere, attribute: .Top, relatedBy: .Equal, toItem: tagWhen, attribute: .Bottom, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhere, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
    //      NSLayoutConstraint(item: tagWhere, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhere, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
    //      ])
    //
    //    NSLayoutConstraint.activateConstraints([
    //      NSLayoutConstraint(item: tagWhat, attribute: .Top, relatedBy: .Equal, toItem: tagWhere, attribute: .Bottom, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhat, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
    //      NSLayoutConstraint(item: tagWhat, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWhat, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
    //      ])
    //    NSLayoutConstraint.activateConstraints([
    //      NSLayoutConstraint(item: tagWho, attribute: .Top, relatedBy: .Equal, toItem: tagWhat, attribute: .Bottom, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWho, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height),
    //      NSLayoutConstraint(item: tagWho, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagWho, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
    //      ])
    //
    //    NSLayoutConstraint.activateConstraints([
    //      NSLayoutConstraint(item: tagSeparator, attribute: .Top, relatedBy: .Equal, toItem: tagWho, attribute: .Bottom, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagSeparator, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: separatorHeight),
    //      NSLayoutConstraint(item: tagSeparator, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: 0),
    //      NSLayoutConstraint(item: tagSeparator, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: 0),
    //      ])
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: body, attribute: .Top, relatedBy: .Equal, toItem: headerSeparator, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: body, attribute: .Bottom, relatedBy: .Equal, toItem: topSeparator, attribute: .Top, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: body, attribute: .Leading, relatedBy: .Equal, toItem: modal, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding/2),
      NSLayoutConstraint(item: body, attribute: .Trailing, relatedBy: .Equal, toItem: modal, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding/2),
      ])
  }
  
  private func createTextView(header header: Bool) -> UITextView {
    let textView = UITextView()
    textView.tag = header ? 1 : 2
    textView.delegate = self
    textView.returnKeyType = .Done
    textView.textAlignment = header ? .Center : .Left
    textView.font = header ? UIFont.boldSystemFontOfSize(Constant.Button.fontSize) : UIFont.systemFontOfSize(UIFont.systemFontSize())
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.tintColor = Constant.Color.button
    
    return textView
  }
  
  private func createPlaceholderLabel(textView textView: UITextView, header: Bool) -> UILabel {
    let label = UILabel()
    label.text = header ? "Title" : "Description"
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
      if let completion = self.completion where button.tag == 1 {
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(rotated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tap)
  }
  
  internal func rotated(notification: NSNotification) {
    // device rotation
    handlePlaceholderAndCursor(textView: header, placeholder: headerPlaceholder, header: true)
    handlePlaceholderAndCursor(textView: body, placeholder: bodyPlaceholder, header: false)
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
    guard let userInfo = notification.userInfo else { return }
    
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
  
  func textViewDidChange(textView: UITextView) {
    // hide the placeholderwhen typing
    handlePlaceholderAndCursor(textView: header, placeholder: headerPlaceholder, header: true)
    handlePlaceholderAndCursor(textView: body, placeholder: bodyPlaceholder, header: false)
  }
  
  private func handlePlaceholderAndCursor(textView textView: UITextView, placeholder: UILabel, header: Bool) {
    // FIXME: rotating device with placerholder location (need delay to get correct modal.frame.width)
    Util.delay(0.1) {
      let textWidth: CGFloat = placeholder.intrinsicContentSize().width
      let textViewTextSize: CGFloat = textView.font!.pointSize
      let x: CGFloat = (self.modal.frame.width - (header ? 0 : Constant.Button.padding/2))/2 - textWidth/2
      let y: CGFloat = textViewTextSize/2
      
      placeholder.frame.origin = CGPointMake(x, y)
      placeholder.hidden = !textView.text.isEmpty
      textView.textContainerInset = textView.text.isEmpty ? UIEdgeInsets(top: textViewTextSize/2, left:-textWidth, bottom: 0, right: 0) : UIEdgeInsets(top: textViewTextSize/2, left:0, bottom: 0, right: 0)
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