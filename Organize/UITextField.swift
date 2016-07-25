import UIKit

extension UITextField {
  func bottomBorder(color color: UIColor) {
    self.borderStyle = UITextBorderStyle.None;
    let border = CALayer()
    let width = CGFloat(1.0)
    border.borderColor = color.CGColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
    
    border.borderWidth = width
    self.layer.addSublayer(border)
    self.layer.masksToBounds = true
  }
  
  class func setTabOrder(fields fields: [UITextField]) {
    guard let last = fields.last else {
      return
    }
    for i in 0..<fields.count-1 {
      fields[i].returnKeyType = .Next
      fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), forControlEvents: .EditingDidEndOnExit)
    }
    last.returnKeyType = .Done
    last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), forControlEvents: .EditingDidEndOnExit)
  }
}