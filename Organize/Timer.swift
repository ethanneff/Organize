//
//  Timer.swift
//  Organize
//
//  Created by Ethan Neff on 6/23/16.
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
  private let workTime: Int = 25*60
  private let longBreakTime: Int = 15*60
  private let shortBreakTime: Int = 5*60
  
  private var schedule: [Int]
  private var notifications: [Int]
  
  private var breakCount: Int
  private var workCount: Int
  private var countdown: Int
  private var isBreak: Bool
  
  weak var delegate: PomodoroTimerDelegate?
  
  // MARK: init
  override init() {
    breakCount = 0
    workCount = 0
    countdown = workTime
    isBreak = false
    schedule = [workTime, shortBreakTime, workTime, shortBreakTime, workTime, shortBreakTime, workTime, longBreakTime]
    notifications = []
  }
  
  convenience init(startTime: NSDate) {
    // check on controller for NSUSERDefautls
    // if exists, then create an instance of timer with the counter
    self.init()
    self.counter = Int(NSDate().timeIntervalSinceDate(startTime))
  }
  
  // MARK: - public access
  override func start() {
    // determing the output based on the the counter
    if countdown == workTime && workCount == 0 {
      delegate?.pomodoroTimerWork()
    }
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
    createNotifications()
    store()
    super.start()
  }
  
  override func stop() {
    super.stop()
    clear()
    delegate?.pomodoroTimerUpdate(output: "", isBreak: isBreak)
  }
  
  override func pause() {
    super.pause()
    deleteNotifications()
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: true)
  }
  
  // MARK:-  private helper
  override private func update() {
    super.update()
    updateCountdown()
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
  }
  
  private func clear() {
    countdown = workTime
    breakCount = 0
    workCount = 0
    isBreak = false
    deleteNotifications()
    discard()
  }
  
  private func discard() {
    // remove from NSUserDefaults
  }
  
  private func store() {
    // save start time in NSUserDefaults
  }
  
  
  private func createNotifications() {
    // test if not able to send notifciatiosn popup
    // save all uid in notifications[] araray
    
    // time should be based on counter
    // time should be next 50 instances (25 pormortos)
//    LocalNotification.sharedInstance.create(controller: self, body: <#T##String#>, action: <#T##String?#>, fireDate: <#T##NSDate?#>, soundName: <#T##String?#>, uid: <#T##Double#>, completion: <#T##completionHandler##completionHandler##(success: Bool) -> ()#>)
    
  }
  
  private func deleteNotifications() {
    // delete all uid from notifications[] array
  }
  
  private func updateCountdown() {
    // countdown should be based on counter, not -1
    if countdown == 0 {
      isBreak = !isBreak
      if isBreak {
        workCount += 1
        delegate?.pomodoroTimerBreak()
        if workCount % 4 == 0 && workCount != 0 {
          countdown = longBreakTime
        } else {
          countdown = shortBreakTime
        }

      } else {
        breakCount += 1
        delegate?.pomodoroTimerWork()
        countdown = workTime
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
    str += String(workCount)
    str += " | "
    str += counterToString()
    return str
  }
}

class Timer {
  var counter: Int = 0
  var timer = NSTimer()
  var on: Bool = false
  var paused: Bool = false
  
  func start() {
    // let timer run in background
    let app = UIApplication.sharedApplication()
    app.beginBackgroundTaskWithExpirationHandler(nil)
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    
    on = true
    paused = false
  }
  
  func stop() {
    pause()
    paused = false
    counter = 0
  }
  
  func pause() {
    timer.invalidate()
    on = false
    paused = true
  }
  
  private dynamic func update() {
    counter += 1
  }
}