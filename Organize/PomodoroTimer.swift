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
  func pomodoroTimerUpdate(output output: String, isBreak: Bool)
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
    print("p init")
    testing = true
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
    reload()
  }
  
  // MARK: - deinit
  deinit {
    print("p deinit")
    dealloc()
  }
  
  private func dealloc() {
    print("p dealloc")
    removeListeners()
  }
  
  // MARK: - public
  override func start() {
    // exit if no premission
    if state == .On || !createNotifications()  {
      return
    }
    super.start()
    render()
    createListeners()
  }
  
  override func pause() {
    if state == .Paused {
      return
    }
    super.pause()
    render()
    deleteNotifications()
  }
  
  override func stop() {
    if state == .Off {
      return
    }
    super.stop()
    render()
    deleteNotifications()
    Constant.UserDefault.remove(key: Constant.UserDefault.Key.PomodoroSeconds)
  }
  
  override func update() {
    super.update()
    render()
  }
  
  func reload() {
    print("p reload")
    // get defaults
    if let secondsInApp = Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroSeconds) as? Double {
      let state = State(rawValue: Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroState) as? Int ?? 0)!
      let open = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppOpenDate) as? NSDate ?? NSDate()
      let close = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppCloseDate) as? NSDate ?? NSDate()
      let time = open.timeIntervalSinceDate(close) + secondsInApp
      
      // action on defaults
      switch state {
      case .On:
        self.state = .Paused
        self.seconds = time
        self.start()
        break
      case .Paused:
        self.pause()
        break
      default: break
      }
    }
  }
  
  // MARK: - output
  private func render() {
    Util.threadBackground {
      let position = self.getIntervalPosition(updateCount: true)
      
      let min: String = String(format: "%02d", Int(position.remainder/60))
      let sec: String = String(format: "%02d", Int(position.remainder%60))
      var output: String = "\(min):\(sec)"
      if self.state == .Off {
        output = ""
      } else if self.state == .Paused {
        output = "paused | \(self.workCount) | \(output)"
      } else {
        output = "\(position.interval.type.button) | \(self.workCount) | \(output)"
      }
      Util.threadMain {
        self.delegate?.pomodoroTimerUpdate(output: output, isBreak: position.interval.type != .Work)
      }
    }
  }
  
  // MARK: - helper
  private func getIntervalPosition(updateCount updateCount: Bool) -> (interval: Interval, index: Int, remainder: Double) {
    var index = 0
    var remainder = seconds
    var interval = schedule[index]
    workCount = updateCount ? 0 : workCount
    workCount = updateCount ? 0 : breakCount
    while true {
      interval = schedule[index]
      if remainder - interval.duration <= 0 {
        remainder = interval.duration - remainder
        break
      }
      
      if updateCount {
        self.updateCounts(type: interval.type)
      }
      remainder = remainder - interval.duration
      index = index >= schedule.count-1 ? 0 : index+1
    }
    
    return (interval: interval, index: index, remainder: remainder)
  }
  
  private func updateCounts(type type: Type) {
    if type == .Work {
      workCount += 1
      Util.threadMain {
        self.delegate?.pomodoroTimerWork()
      }
    } else {
      breakCount += 1
      Util.threadMain {
        self.delegate?.pomodoroTimerBreak()
      }
    }
  }
  
  // MARK: - notifications
  private func createNotifications() -> Bool {
    print("p create notifications")
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
      let remainder: Double = position.remainder == position.interval.duration ? 0 : position.remainder - position.interval.duration
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
      print(UIApplication.sharedApplication().scheduledLocalNotifications!.count)
    }
    return true
  }
  
  private func deleteNotifications(completion: (() -> ())? = nil) {
    dispatch_async(notificationQueue) {
      for uid in self.notifications {
        LocalNotification.sharedInstance.delete(uid: uid)
      }
      self.notifications.removeAll()
      print(UIApplication.sharedApplication().scheduledLocalNotifications!.count)
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillTerminateNotification), name: UIApplicationWillTerminateNotification, object: nil)
  }
  
  private func removeListeners() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  dynamic func applicationDidBecomeActiveNotification() {
    reload()
  }
  
  dynamic func applicationDidBecomeInactiveNotification() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroState, val: state.rawValue)
    Constant.UserDefault.set(key: Constant.UserDefault.Key.PomodoroSeconds, val: seconds)
    timer.invalidate()
  }
  
  dynamic func applicationWillTerminateNotification() {
    deleteNotifications()
    timer.invalidate()
    Constant.UserDefault.remove(key: Constant.UserDefault.Key.PomodoroSeconds)
    Constant.UserDefault.remove(key: Constant.UserDefault.Key.PomodoroState)
  }
}