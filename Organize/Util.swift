import UIKit
import AVFoundation
import Firebase

class Util {
  // multiple story board navigation
  class func navToStoryboard(currentController currentController:UIViewController, storyboard:String) {
    let storyboard = UIStoryboard(name: storyboard, bundle: nil)
    let controller = storyboard.instantiateInitialViewController()! as UIViewController
    currentController.presentViewController(controller, animated: true, completion: nil)
  }
  
  // changing the status bar color
  class func setStatusBarBackgroundColor(color: UIColor) {
    guard let statusBar = UIApplication.sharedApplication().valueForKey("statusBarWindow")?.valueForKey("statusBar") as? UIView else {
      return
    }
    statusBar.backgroundColor = color
  }
  
  // removing the text from the back button in the navigation bar
  class func removeNavBackButtonText(controller controller: UIViewController) {
    controller.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }
  
  // background thread delay
  class func delay(delay:Double, closure:()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
  
  // logging
  class func log(message: String?=nil, function: String = #function, file: String = #file) {
    if Constant.App.logging {
      let current = Int64(NSDate().timeIntervalSince1970*1000)
      let output = "\(current) | \(file) | \(function) | \(message ?? "")"
      print(output)
      FIRCrashMessage(output)
    }
  }
  
  // random
  class func randomString(length length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: length)
    
    for _ in 0..<length {
      let len = UInt32(letters.length)
      let rand = arc4random_uniform(len)
      randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return String(randomString)
  }
  
  class func randomNumber(upperLimit upperLimit: UInt32) -> Int {
    return Int(arc4random_uniform(upperLimit))
  }
  
  // threading
  class func threadBackground(completion: () -> ()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      completion()
    }
  }
  
  class func threadMain(completion: () -> ()) {
    dispatch_async(dispatch_get_main_queue()) {
      completion()
    }
  }
  
  // animation
  class func animateButtonPress(button button: UIView, completion: (() -> ())? = nil) {
    UIView.animateWithDuration(0.05, animations: {
      button.alpha = 0.4
      }, completion: { success in
        UIView.animateWithDuration(0.20, animations: {
          button.alpha = 1
          }, completion: { success in
            if let completion = completion {
              completion()
            }
        })
    })
    Util.playSound(systemSound: .Tap)
  }
  
  // sounds
  enum SystemSounds: UInt32 {
    case Type = 1104
    case Tap = 1103 // tick
    case Positive = 1054 // vibrate
    case Negative = 1053 // vibrate
    
    case MailReceived = 1000 // vibrate
    case MailSent = 1001 // woosh
    
    case SMSReceived = 1003 // vibrate
    case SMSSent = 1004 // woop
    
    case CalendarAlert = 1005 // beep bo beep bop beep bo beep bop
    case LowPower = 1006 // dum dum dum
    case Voicemail = 1015 // boo bo beep
    
    case BeepBeepSuccess = 1111
    case BeepBeepFailure = 1112
    case BeepBoBoopSuccess = 1115
    case BeepBoBoopFailure = 1116
  }
  
  class func playSound(systemSound systemSound: SystemSounds) {
    Util.threadMain {
      let systemSoundID: SystemSoundID = systemSound.rawValue
      AudioServicesPlaySystemSound(systemSoundID)
    }
  }
  
  // image
  class func imageViewWithColor(image image: UIImage, color: UIColor) -> UIImageView {
    let imageView = UIImageView(image: image)
    imageView.image = imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
    imageView.tintColor = color
    return imageView
  }
  
  // network indicator
  class func toggleNetworkIndicator(on on: Bool) {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = on
  }
  
  
  // keyboard
  class func handleKeyboardScrollView(keyboardNotification keyboardNotification: NSNotification, scrollViewBottomConstraint: NSLayoutConstraint, view: UIView, constant: CGFloat? = nil) {
    if let userInfo = keyboardNotification.userInfo {
      let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
      let endFrameHeight: CGFloat = endFrame?.size.height ?? 0.0
      let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
      let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
        scrollViewBottomConstraint.constant = 0.0
      } else {
        scrollViewBottomConstraint.constant = -endFrameHeight + (constant ?? 0)
      }
      UIView.animateWithDuration(duration, delay: NSTimeInterval(0), options: animationCurve, animations: {
        view.layoutIfNeeded()
        }, completion: nil)
    }
  }
  
  class func keyboardHeight(notification notification: NSNotification) -> CGFloat {
    if let userInfo = notification.userInfo, let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
      return keyboardHeight
    }
    return 0
  }
  
}