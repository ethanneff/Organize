//
//  TestViewController.swift
//  Organize
//
//  Created by Ethan Neff on 6/29/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, PomodoroTimerDelegate {
  
  let button1: UIButton = UIButton()
  let button2: UIButton = UIButton()
  let button3: UIButton = UIButton()
  let button4: UIButton = UIButton()
  let button5: UIButton = UIButton()
  let label1: UILabel = UILabel()
  
  let timer = PomodoroTimer()
  
  enum Names: Int {
    case One
    case Two
    case Three
    case Four
    case Five
    
    var output: String {
      switch self {
      case .One: return "one"
      case .Two: return "two"
      case .Three: return "three"
      case .Four: return "four"
      case .Five: return "five"
      }
    }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    let buttons = [button1, button2, button3, button4, button5]
    setupLabel(label: label1)
    setupButtons(buttons: buttons)
    timer.delegate = self
    timer.reload()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func setupLabel(label label: UILabel) {
    label1.text = "label"
    view.addSubview(label1)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .Center
    label.textColor = Constant.Color.button
    label.font = UIFont(name: "Menlo-Regular", size: UIFont.systemFontSize())
    
    var constraints: [NSLayoutConstraint] = []
    
    constraints.append(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: Constant.Button.padding))
    constraints.append(NSLayoutConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding))
    constraints.append(NSLayoutConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding))
    constraints.append(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  func setupButtons(buttons buttons: [UIButton]) {
    var constraints: [NSLayoutConstraint] = []
    
    for i in 0..<buttons.count {
      let button = buttons[i]
      view.addSubview(button)
      button.tag = i
      button.setTitle(Names(rawValue: i)!.output, forState: .Normal)
      button.layer.cornerRadius = 5
      button.clipsToBounds = true
      button.backgroundColor = Constant.Color.button
      button.setTitleColor(Constant.Color.background, forState: .Normal)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
      
      constraints.append(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: i == 0 ? label1 : buttons[i-1], attribute: .Bottom, multiplier: 1, constant: Constant.Button.padding))
      constraints.append(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: Constant.Button.padding))
      constraints.append(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: -Constant.Button.padding))
      constraints.append(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: Constant.Button.height))
    }
    NSLayoutConstraint.activateConstraints(constraints)
  }
  
  func buttonPressed(button: UIButton) {
    switch button.tag {
    case 0: buttonOne()
    case 1: buttonTwo()
    case 2: buttonThree()
    case 3: buttonFour()
    case 4: buttonFive()
    default: break
    }
        Util.animateButtonPress(button: button)
  }
  
  func buttonOne() {
    timer.start()
  }
  func buttonTwo() {
    timer.pause()
  }
  func buttonThree() {
    timer.stop()
  }
  func buttonFour() {
    
  }
  func buttonFive() {
    
  }
  
  func pomodoroTimerUpdate(output output: String, isBreak: Bool) {
    print("delegate \(NSDate())")
    label1.text = output
    print("done \(NSDate())")
  }
}
