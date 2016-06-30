//
//  Timer.swift
//  Organize
//
//  Created by Ethan Neff on 6/29/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class Timer {
  internal var timer: NSTimer
  internal var seconds: Double
  internal var state: State
  
  enum State: Int {
    case On
    case Off
    case Paused
  }
  
  init() {
    timer = NSTimer()
    seconds = 0
    state = .Off
  }
  
  deinit {
    timer.invalidate()
  }
  
  func start() {
    if state == .On {
      return
    }
    timer.invalidate()
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    state = .On
  }
  
  func pause() {
    if state == .Paused {
      return
    }
    timer.invalidate()
    state = .Paused
  }
  
  func stop() {
    if state == .Off {
      return
    }
    timer.invalidate()
    state = .Off
    seconds = 0
  }
  
  internal dynamic func update() {
    seconds += 1
  }
}