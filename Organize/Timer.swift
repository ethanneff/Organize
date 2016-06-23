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
  
  private var breakCount: Int
  private var workCount: Int
  private var countdown: Int
  private var isBreak: Bool
  
  weak var delegate: PomodoroTimerDelegate?
  
  override init() {
    breakCount = 0
    workCount = 0
    countdown = workTime
    isBreak = false
  }
  
  override func start() {
    if countdown == workTime && workCount == 0 {
      delegate?.pomodoroTimerWork()
    }
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
    super.start()
  }
  
  override func stop() {
    super.stop()
    clear()
    delegate?.pomodoroTimerUpdate(output: "", isBreak: isBreak)
  }
  
  override func update() {
    updateCountdown()
    delegate?.pomodoroTimerUpdate(output: output(), isBreak: isBreak)
  }
  
  private func clear() {
    countdown = workTime
    breakCount = 0
    workCount = 0
    isBreak = false
  }
  
  private func updateCountdown() {
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