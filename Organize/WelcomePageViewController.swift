//
//  WelcomeViewController.swift
//  Organize
//
//  Created by Ethan Neff on 7/11/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController {
  // MARK: - properties
  let scrollView: UIScrollView!
  private(set) lazy var slides: [UIViewController] = {
    return [SlideViewController(color: UIColor.redColor()),SlideViewController(color: UIColor.blueColor()), SlideViewController(color: UIColor.greenColor())]
  }()
  
  let getStartedButton: UIButton!
  lazy var navButtons: [Int: UIButton] = [Int: UIButton]()
  var navSelected: UIButton!
  
  // MARK: - init
  init() {
    scrollView = UIScrollView()
    getStartedButton = Constant.Button.create(title: "Get started", bold: false, small: false, background: true, shadow: false)
    super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    initialization()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initialization() {
    setupBottomButton()
    setupNavigationCircles()
  }
  
  // MARK: - deinit
  deinit {
    print("welcome view contoller deinit")
  }
  
  // MARK: - load
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPageController()
  }
  
  // MARK: - error
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - button
  internal func buttonPressedBottom(button: UIButton) {
    Util.animateButtonPress(button: button)
    navigateOut()
  }
  
  internal func buttonPressedNav(button: UIButton) {
    Util.animateButtonPress(button: button)
    button.backgroundColor = Constant.Color.button
    navSelected.backgroundColor = Constant.Color.border
    navSelected = button
  }
  
  private func updateNavButtonIndex(index index: Int) {
    // change nav colors based on index
    if let button = navButtons[index] {
      button.backgroundColor = Constant.Color.button
      navSelected.backgroundColor = Constant.Color.border
      navSelected = button
    }
  }
  
  // MARK: - helper
  private func navigateOut() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - view
extension WelcomePageViewController {
  private func setupPageController() {
    dataSource = self
    delegate = self
    automaticallyAdjustsScrollViewInsets = false
    
    if let firstViewController = slides.first {
      setViewControllers([firstViewController], direction: .Forward, animated: true, completion: nil)
    }
  }
  
  private func setupSlides() {
    let v = UIView()
    v.layer.cornerRadius = 5
    v.layer.masksToBounds = true
    v.translatesAutoresizingMaskIntoConstraints = false
    v.backgroundColor = Constant.Color.background
    view.addSubview(v)
    
    var constraints: [NSLayoutConstraint] = []
    constraints.append(NSLayoutConstraint(item: v, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: v, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
    constraints.append(NSLayoutConstraint(item: v, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 300))
    constraints.append(NSLayoutConstraint(item: v, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 500))
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  private func setupNavigationCircles() {
    let buttonHeight = Constant.Button.height/4
    let buttonSpacing = buttonHeight/2
    var constraints: [NSLayoutConstraint] = []
    
    var prevButton: UIButton!
    for i in 0..<slides.count {
      let button = UIButton()
      button.tag = i
      
      button.layer.cornerRadius = buttonHeight/2
      button.backgroundColor = i == 0 ? Constant.Color.button : Constant.Color.border
      button.addTarget(self, action: #selector(buttonPressedNav(_:)), forControlEvents: .TouchUpInside)
      button.translatesAutoresizingMaskIntoConstraints = false
      
      view.addSubview(button)
      navButtons[i] = button
      
      constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight))
      constraints.append(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight))
      constraints.append(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: getStartedButton, attribute: .Top, multiplier: 1, constant: -Constant.Button.padding))
      if i == 0 {
        navSelected = button
        let mid: CGFloat = (CGFloat(slides.count) * (buttonHeight + buttonSpacing) - 5 ) / 2
        constraints.append(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: -mid))
      } else {
        constraints.append(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: prevButton, attribute: .Trailing, multiplier: 1, constant: buttonSpacing))
      }
      prevButton = button
    }
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  private func setupBottomButton() {
    getStartedButton.addTarget(self, action: #selector(buttonPressedBottom(_:)), forControlEvents: .TouchUpInside)
    view.addSubview(getStartedButton)
    
    var constraints: [NSLayoutConstraint] = []
    constraints.append(NSLayoutConstraint(item: getStartedButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -Constant.Button.padding))
    constraints.append(NSLayoutConstraint(item: getStartedButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    constraints.append(NSLayoutConstraint(item: getStartedButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding))
    constraints.append(NSLayoutConstraint(item: getStartedButton, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding))
    NSLayoutConstraint.activateConstraints(constraints)
  }
}

// MARK: - page controller
extension WelcomePageViewController: UIPageViewControllerDelegate {
  func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    guard let viewController = pendingViewControllers.first, let viewControllerIndex = slides.indexOf(viewController) else {
      return
    }
    updateNavButtonIndex(index: viewControllerIndex)
  }
}

extension WelcomePageViewController: UIPageViewControllerDataSource {
  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slides.indexOf(viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    guard slides.count > previousIndex else {
      return nil
    }
    
    return slides[previousIndex]
  }
  
  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = slides.indexOf(viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = slides.count
    
    guard orderedViewControllersCount != nextIndex else {
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return slides[nextIndex]
  }
}

