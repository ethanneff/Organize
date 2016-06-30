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
    if seconds == 0 {
      print("p start")
    } else {
      print("p resume")
    }
    deleteNotifications()
    if !createNotifications() {
      return
    }
    
    super.start()
    render()
    createListeners()
  }
  
  override func pause() {
    print("p pause")
    super.pause()
    render()
    deleteNotifications()
  }
  
  override func stop() {
    print("p stop")
    super.stop()
    render()
    deleteNotifications()
    Constant.UserDefault.remove(key: Constant.UserDefault.Key.PomodoroSeconds)
  }
  
  override func update() {
    super.update()
    render()
  }
  
  private func render() {
    Util.threadBackground {
      var index = 0
      var delta = self.seconds
      var interval = self.schedule[index]
      self.workCount = 0
      self.breakCount = 0
      while true {
        interval = self.schedule[index]
        if delta - interval.duration > 0 {
          if interval.type == .Work {
            self.workCount += 1
            Util.threadMain {
              self.delegate?.pomodoroTimerWork()
            }
          } else {
            self.breakCount += 1
            Util.threadMain {
              self.delegate?.pomodoroTimerBreak()
            }
          }
        } else {
          delta = interval.duration - delta
          break
        }
        delta = delta - interval.duration
        index = index >= self.schedule.count-1 ? 0 : index+1
      }
      
      let min: String = String(format: "%02d", Int(delta/60))
      let sec: String = String(format: "%02d", Int(delta%60))
      var output: String = "\(min):\(sec)"
      if self.state == .Off {
        output = ""
      } else if self.state == .Paused {
        output = "paused | \(self.workCount) | \(output)"
      } else {
        output = "\(interval.type.button) | \(self.workCount) | \(output)"
      }
      Util.threadMain {
        self.delegate?.pomodoroTimerUpdate(output: output, isBreak: interval.type != .Work)
      }
    }
  }
  
  
  func reload() {
    render()
    print("p reload")
    if let secondsInApp = Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroSeconds) as? Double {
      let state = State(rawValue: Constant.UserDefault.get(key: Constant.UserDefault.Key.PomodoroState) as? Int ?? 0)!
      let open = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppOpenDate) as? NSDate ?? NSDate()
      let close = Constant.UserDefault.get(key: Constant.UserDefault.Key.AppCloseDate) as? NSDate ?? NSDate()
      let time = open.timeIntervalSinceDate(close) + secondsInApp
      
      switch state {
      case .On:
        seconds = time
        start()
        break
      case .Paused:
        pause()
        break
      default: break
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
    Util.threadBackground {
      let now: NSDate = NSDate()
      var index: Int = 0
      var sum: Double = -self.seconds
      for _ in 0..<50 {
        let uuid = NSUUID().UUIDString
        let interval = self.schedule[index]
        sum += interval.duration
        let future = now.dateByAddingTimeInterval(sum)
        self.notifications.append(uuid)
        LocalNotification.sharedInstance.create(controller: controller, body: interval.type.notification, action: nil, fireDate: future, soundName: nil, uid: uuid, completion: nil)
        index = index >= self.schedule.count-1 ? 0 : index + 1
      }
    }
    return true
  }
  
  private func deleteNotifications() {
    print("delete notifications")
    Util.threadBackground {
      for uid in self.notifications {
        LocalNotification.sharedInstance.delete(uid: uid)
      }
      self.notifications.removeAll()
      print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)
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