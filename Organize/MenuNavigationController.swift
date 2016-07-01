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
    createPomodoroTimer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - deinit
  deinit {
    timer.stop()
  }
  
  // MARK: - load
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    timer.delegate = self
    timer.reload()
  }
  
  
  // MARK: - timer
  func pomodoroTimerUpdate(output output: String, isBreak: Bool, isPaused: Bool) {
    timerLabel.text = output
    timerLabel.textColor = isBreak || isPaused ? Constant.Color.border : Constant.Color.button
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
    let fontSize: CGFloat = 9
    timerLabel.font = UIFont(name: "Menlo-Regular", size: 9)
    timerLabel.textAlignment = .Center
    timerLabel.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.addSubview(timerLabel)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: timerLabel, attribute: .Bottom, relatedBy: .Equal, toItem: navigationBar, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timerLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: fontSize),
      NSLayoutConstraint(item: timerLabel, attribute: .Width, relatedBy: .Equal, toItem: navigationBar, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timerLabel, attribute: .Trailing, relatedBy: .Equal, toItem: navigationBar, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
  }
}
