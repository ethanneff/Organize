import UIKit

class MenuNavigationController: UINavigationController, PomodoroTimerDelegate {
  var timer: UILabel!
  
  override func loadView() {
    super.loadView()
    
    pushViewController(MenuViewController(), animated: false)
    createPomodoroTimer()
    let t = PomodoroTimer()
    t.delegate = self
    t.start()
  }
  
  func pomodoroTimerUpdate(output output: String, isBreak: Bool) {
    timer.text = output
    timer.textColor = isBreak ? Constant.Color.border : Constant.Color.button
  }
  
  private func createPomodoroTimer() {
    timer = UILabel()
    let fontSize: CGFloat = 9
    let text = "focus | 0 | 02:25"
    timer.text = text
    timer.textColor = Constant.Color.button
    timer.font = UIFont.boldSystemFontOfSize(fontSize)
    timer.textAlignment = .Center
    
    timer.translatesAutoresizingMaskIntoConstraints = false
    navigationBar.addSubview(timer)
    
    NSLayoutConstraint.activateConstraints([
      NSLayoutConstraint(item: timer, attribute: .Bottom, relatedBy: .Equal, toItem: navigationBar, attribute: .Bottom, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: fontSize),
      NSLayoutConstraint(item: timer, attribute: .Width, relatedBy: .Equal, toItem: navigationBar, attribute: .Width, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: timer, attribute: .Trailing, relatedBy: .Equal, toItem: navigationBar, attribute: .Trailing, multiplier: 1, constant: 0),
      ])
  }
}

protocol PomodoroTimerDelegate: class {
  func pomodoroTimerUpdate(output output: String, isBreak: Bool)
}

class PomodoroTimer: Timer {
  private let pomodoroTime: Int = 25*60
  private let longBreakTime: Int = 15*60
  private let shortBreakTime: Int = 5*60
  
  private var breakCount: Int = 0
  private var pomodoroCount: Int = 0
  private var countdown: Int = 25*60
  private var isBreak: Bool = false
  
  weak var delegate: PomodoroTimerDelegate?
  
  override func start() {
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
    super.start()
  }
  
  override func stop() {
    super.stop()
    clear()
  }
  
  override func update() {
    updateCountdown()
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
  }
  
  private func clear() {
    countdown = pomodoroTime
    breakCount = 0
    pomodoroCount = 0
    isBreak = false
  }
  
  private func updateCountdown() {
    if countdown == 0 {
      isBreak = !isBreak
      if isBreak {
        pomodoroCount += 1
        if breakCount % 4 == 0  && breakCount != 0 {
          countdown = longBreakTime
        } else {
          countdown = shortBreakTime
        }
      } else {
        breakCount += 1
        countdown = pomodoroTime
      }
    }
    countdown -= 1
  }
  
  private func counterToString() -> String {
    let min: String = String(format: "%02d", countdown/60)
    let sec: String = String(format: "%02d", countdown%60)
    return "\(min):\(sec)"
  }
  
  private func output() -> String {
    var str: String = isBreak ? "break" : "focus"
    str += " | "
    str += String(pomodoroCount)
    str += " | "
    str += counterToString()
    return str
  }
}


class Timer {
  var counter: Int = 0
  var timer = NSTimer()
  
  func start() {
    timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(update), userInfo: nil, repeats: true)
  }
  
  func stop() {
    pause()
    counter = 0
  }
  
  func pause() {
    timer.invalidate()
  }
  
  private dynamic func update() {
    counter += 1
  }
}