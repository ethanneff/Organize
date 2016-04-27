import UIKit

class SearchViewController: UIViewController {
  
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setupView() {
    view.backgroundColor = Config.colorBackground
    
    var label = UILabel(frame: CGRectMake(0,0,50,50))
    label.backgroundColor = .greenColor()
    label.text = "hello"
    view.addSubview(label)
    
    label = UILabel()
    label.text = "hello"
    view.addSubview(label)
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
    label.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
    label.heightAnchor.constraintEqualToConstant(50).active = true
    label.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    label.backgroundColor = .brownColor()
    
    
    let button = UIButton(frame: CGRectMake(100,100,100,200))
    button.setTitle("local notification", forState: .Normal)
    button.setTitleColor(.blackColor(), forState: .Normal)
    button.backgroundColor = .yellowColor()
    button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
    view.addSubview(button)
  }
  
  func buttonPressed(sender: UIButton) {

  }
  

}
