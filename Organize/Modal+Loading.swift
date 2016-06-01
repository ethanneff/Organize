import UIKit

class ModalLoadingController: UIViewController {
  // MARK: - properties
  let modal: UIView = UIView()
  
  let modalWidth: CGFloat = Constant.Button.height*2
  let modalHeight: CGFloat = Constant.Button.height*2
  
  // MARK: - deinit
  deinit {
    dealloc()
  }
  
  private func dealloc() {
    Modal.clear(background: view)
  }
  
  // MARK: - open
  func show(parentController: UIViewController) {
    Modal.show(parentController: parentController, modalController: self, modal: modal)
    Util.toggleNetworkIndicator(on: false)
  }
  
  // MARK: - close
  func hide(parentController: UIViewController? = nil, completion: (() -> ())? = nil) {
    Modal.animateOut(modal: modal, background: view) {
      Util.toggleNetworkIndicator(on: false)
      self.dismissViewControllerAnimated(false, completion: { 
        if let completion = completion {
          completion()
        }
      })
    }
  }
  
  // MARK: - create
  override func loadView() {
    super.loadView()
    setupView()
  }
  
  private func setupView() {
    let indicator = createIndicator()
    Modal.createModalTemplate(background: view, modal: modal, titleText: nil)
    modal.addSubview(indicator)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: modal, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: modal, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalWidth),
      NSLayoutConstraint(item: modal, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: modalHeight),
      
      NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: modal, attribute: .CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: modal, attribute: .CenterY, multiplier: 1, constant: 0),
      ])
  }
  
  private func createIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.activityIndicatorViewStyle = .WhiteLarge
    indicator.color = Constant.Color.button
    indicator.startAnimating()
    
    return indicator
  }
}