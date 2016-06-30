import UIKit

class MenuNavigationController: UINavigationController, PomodoroTimerDelegate {
  // MARK: - properties
  let timerLabel: UILabel!
  let timer: PomodoroTimer!
  
  // MARK: - init
  init() {
    timerLabel = UILabel()
    timer = PomodoroTimer()
    super.init(nibName: nil, bundle: nil)
    pushViewController(MenuViewController(), animated: false)
//    createPomodoroTimer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - deinit
  deinit {

  }
  
  func pomodoroTimerUpdate(output output: String, isBreak: Bool) {
    print("pomodoroTimerUpdate \(output)")
    timerLabel.text = output
    timerLabel.textColor = isBreak ? Constant.Color.border : Constant.Color.button
  }
  
  func pomodoroTimerBreak() {
    Util.playSound(systemSound: .BeepBoBoopFailure)
    Util.vibrate()
  }
  
  func pomodoroTimerWork() {
    Util.playSound(systemSound: .BeepBoBoopSuccess)
    Util.vibrate()
  }
  
  private func createPomodoroTimer() {
    timer.delegate = self
    let fontSize: CGFloat = 9
    timerLabel.font = UIFont.boldSystemFontOfSize(fontSize)
    timerLabel.textAlignment = .Center
    timerLabel.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.addSubview(timerLabel)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: timerLabel, attribute: .Bottom, relatedBy: .Equal, toItem: navigationBar, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timerLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: fontSize),
      NSLayoutConstraint(item: timerLabel, attribute: .Width, relatedBy: .Equal, toItem: navigationBar, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timerLabel, attribute: .Trailing, relatedBy: .Equal, toItem: navigationBar, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
    
//    timer.reload()
  }
}
