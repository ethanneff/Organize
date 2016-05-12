import UIKit
import AVFoundation

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
  class func log(logMessage: String?=nil, functionName: String = #function) {
    let currentDateTime = Int64(NSDate().timeIntervalSince1970*1000)
    print("[\(currentDateTime)] [\(functionName)] \(logMessage)")
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
  class func animateButtonPress(button button: UIButton) {
    if let color = button.backgroundColor {
      UIView.animateWithDuration(0.2) {
        button.backgroundColor = color.colorWithAlphaComponent(0.7)
        UIView.animateWithDuration(0.3) {
          button.backgroundColor = color
        }
      }
    } else {
      UIView.animateWithDuration(0.4) {
        button.alpha = 0.4
        UIView.animateWithDuration(0.4) {
          button.alpha = 1
        }
      }
    }
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
}