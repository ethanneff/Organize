import UIKit

extension UITableViewCell {
  // add guid: String property to UITableViewCell
  private struct AssociatedKeys {
    static var guid:String?
  }
  
  var guid: String? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.guid) as? String
    }
    set {
      if let newValue = newValue {
        objc_setAssociatedObject(self, &AssociatedKeys.guid, newValue as String?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
    }
  }
  
  // load 
  override public func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = Config.colorBackground
    separatorInset = UIEdgeInsetsZero
    layoutMargins = UIEdgeInsetsZero
    selectionStyle = .None
  }
}