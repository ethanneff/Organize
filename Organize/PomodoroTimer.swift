//
//  PomodoroTimer.swift
//  Organize
//
//  Created by Ethan Neff on 6/29/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

// let timer = PomodoroTimer()
// timer.delegate = self
protocol PomodoroTimerDelegate: class {
  func pomodoroTimerUpdate(output output: String, isBreak: Bool, isPaused: Bool)
  func pomodoroTimerBreak()
  func pomodoroTimerWork()
}

// optional
extension PomodoroTimerDelegate {
  func pomodoroTimerBreak() {}
  func pomodoroTimerWork() {}
}


class PomodoroTimer: Timer {
  private let testing: Bool
  private let workTime: Double
  private let longBreakTime: Double
  private let shortBreakTime: Double
  
  private var schedule: [Interval]
  private var notifications: [String]
  private var notificationCount: Int
  private let notificationQueue: dispatch_queue_t
  
  private var breakCount: Int
  private var workCount: Int
  private var countdown: Double
  private var isBreak: Bool
  
  weak var delegate: PomodoroTimerDelegate?
  
  private enum Type: String {
    case ShortBreak
    case LongBreak
    case Work
    
    var notification: String {
      switch self {
      case .LongBreak: return "Long Break"
      case .ShortBreak: return "Short Break"
      case .Work: return "Focus"
      }
    }
    
    var button: String {
      switch self {
      case .LongBreak: return "break"
      case .ShortBreak: return "break"
      case .Work: return "focus"
      }
    }
  }
  
  private struct Interval {
    let duration: Double
    let type: Type
  }
  
  // MARK: init
  override init() {
    testing = false
    workTime = testing ? 5 : 25*60
    longBreakTime = testing ? 5 : 25*60
    shortBreakTime = testing ? 2 : 25*60
    
    breakCount = 0
    workCount = 0
    countdown = workTime
    isBreak = false
    schedule = [Interval(duration: workTime, type: .Work),
                Interval(duration: shortBreakTime, type: .ShortBreak),
                Interval(duration: workTime, type: .Work),
                Interval(duration: shortBreakTime, type: .ShortBreak),
                Interval(duration: workTime, type: .Work),
                Interval(duration: shortBreakTime, type: .ShortBreak),
                Interval(duration: workTime, type: .Work),
                Interval(duration: longBreakTime, type: .LongBreak)]
    notifications = []
    notificationCount = 30
    notificationQueue = dispatch_queue_create("com.eneff.app.organize.pomodorotimer", nil)
    super.init()
  }
  
  // MARK: - deinit
  deinit {
    removeListeners()
  }
  
  
  // MARK: - public
  override func start() {
    // exit if no premission
    if !createNotifications() {
      return
    }
    super.start()
    render()
    createListeners()
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroState, val: state.rawValue)
  }
  
  override func pause() {
    super.pause()
    render()
    deleteNotifications()
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroState, val: state.rawValue)
  }
  
  override func stop() {
    super.stop()
    render()
    deleteNotifications()
    Constant.UserDefault.remove(key: Constant.UserDefault.Key.PomodoroSeconds)
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroState, val: state.rawValue)
  }
  
  override func update() {
    super.update()
    render()
  }
  
  func reload() {
    // get defaults
    let prevSeconds = Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroSeconds) as? Double ?? seconds
    let prevState = State(rawValue: Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroState) as? Int ?? 0)!
    let prevNotifications = Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroSeconds) as? [String] ?? notifications
    let open = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppOpenDate) as? NSDate ?? NSDate()
    let close = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppCloseDate) as? NSDate ?? NSDate()
    let time = open.timeIntervalSinceDate(close) + prevSeconds
    
    // action on defaults
    switch prevState {
    case .On:
      notifications = prevNotifications
      seconds = time
      start()
    case .Paused:
      notifications = prevNotifications
      seconds = prevSeconds
      pause()
    case .Off:
      stop()
    }
  }
  
  // MARK: - output
  private func render() {
    Util.threadBackground {
      let position = self.getIntervalPosition(updateCount: true)
      let min: Int = Int(position.remainder/60)
      let sec: Int = Int(position.remainder%60)
      
      self.updateDelegateChange(min: min, sec: sec, type: position.interval.type)
      self.updateDelegateTimer(min: min, sec: sec, type: position.interval.type)
    }
  }
  
  // MARK: - delegates
  private func updateDelegateTimer(min min: Int, sec: Int, type: Type) {
    let minStr: String = String(format: "%02d", min)
    let secStr: String = String(format: "%02d", sec)
    var output: String = "\(minStr):\(secStr)"
    
    switch self.state {
    case .Off: output = ""
    case .On: output = "\(type.button) | \(workCount) | \(output)"
    case .Paused: output = "paused | \(workCount) | \(output)"
    }
    
    Util.threadMain {
      self.delegate?.pomodoroTimerUpdate(output: output, isBreak: type != .Work, isPaused: self.state == .Paused)
    }
  }
  
  private func updateDelegateChange(min min: Int, sec: Int, type: Type) {
    if min == 0 && sec == 0 {
      Util.threadMain {
        if type != .Work {
          self.delegate?.pomodoroTimerBreak()
        } else {
          self.delegate?.pomodoroTimerWork()
        }
      }
    }
  }
  
  // MARK: - helper
  private func getIntervalPosition(updateCount updateCount: Bool) -> (interval: Interval, index: Int, remainder: Double) {
    var index = 0
    var remainder = seconds
    var interval = schedule[index]
    workCount = updateCount ? 0 : workCount
    breakCount = updateCount ? 0 : breakCount
    while true {
      interval = schedule[index]
      if remainder - interval.duration <= 0 {
        remainder = interval.duration - remainder
        break
      }
      
      if updateCount {
        if interval.type == .Work {
          workCount += 1
        } else {
          breakCount += 1
        }
      }
      remainder = remainder - interval.duration
      index = index >= schedule.count-1 ? 0 : index+1
    }
    
    return (interval: interval, index: index, remainder: remainder)
  }
  
  // MARK: - notifications
  private func createNotifications() -> Bool {
    // require delegate
    guard let controller = delegate as? UIViewController else {
      Report.sharedInstance.log("missing required PomodoroTimerDelegate")
      return false
    }
    
    // ask permissions
    if !LocalNotification.sharedInstance.checkPermission(controller: controller) {
      return false
    }
    
    // create notifications
    deleteNotifications() {
      let position = self.getIntervalPosition(updateCount: false)
      let remainder: Double = position.remainder == position.interval.duration ? 0 : position.remainder - position.interval.duration - 1 // minus 1 for local notification push delay
      let now: NSDate = NSDate()
      var index: Int = position.index
      var sum: Double = remainder
      for _ in 0..<self.notificationCount {
        let uuid = NSUUID().UUIDString
        let interval = self.schedule[index]
        let nextInterval = self.schedule[index >= self.schedule.count-1 ? 0 : index + 1]
        sum += interval.duration
        let future = now.dateByAddingTimeInterval(sum)
        self.notifications.append(uuid)
        LocalNotification.sharedInstance.create(controller: controller, body: nextInterval.type.notification, action: nil, fireDate: future, soundName: nil, uid: uuid, completion: nil)
        index = index >= self.schedule.count-1 ? 0 : index + 1
      }
      Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroNotifications, val: self.notifications)
    }
    return true
  }
  
  private func deleteNotifications(completion: (() -> ())? = nil) {
    dispatch_async(notificationQueue) {
      for uid in self.notifications {
        LocalNotification.sharedInstance.delete(uid: uid)
      }
      self.notifications.removeAll()
      Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroNotifications, val: self.notifications)
      if let completion = completion {
        completion()
      }
    }
  }
  
  // MARK: - listeners
  private func createListeners() {
    removeListeners()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeInactiveNotification), name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  private func removeListeners() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  dynamic func applicationDidBecomeActiveNotification() {
    reload()
  }
  
  dynamic func applicationDidBecomeInactiveNotification() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroSeconds, val: seconds)
    timer.invalidate()
  }
  
}