//
//  Review.swift
//  Organize
//
//  Created by Ethan Neff on 7/25/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import Foundation

class Review {
  // MARK: - singleton
  static let sharedInstance = Review()
  private init() {}
  
  func update() {
    let reviewCount = Constant.UserDefault.get(key: Constant.UserDefault.Key.ReviewCount) as? Int ?? 0
    Constant.UserDefault.set(key: Constant.UserDefault.Key.ReviewCount, val: reviewCount+1)
  }
  
  func show(completion: (success: Bool) -> ()) {
    Remote.Config.fetch { config in
      if let config = config {
        let feedbackApp = Constant.UserDefault.get(key: Constant.UserDefault.Key.FeedbackApp) as? Bool ?? false
        let reviewApp = Constant.UserDefault.get(key: Constant.UserDefault.Key.ReviewApp) as? Bool ?? false
        let reviewCount = Constant.UserDefault.get(key: Constant.UserDefault.Key.ReviewCount) as? Int ?? 0
        let reviewCountConfig = config[Remote.Config.Keys.ShowReview.rawValue].numberValue as? Int ?? 0
        
        if !(reviewApp || feedbackApp) && reviewCount >= reviewCountConfig {
          return completion(success: true)
        }
        return completion(success: false)
      }
    }
  }
  
  func reset() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.ReviewCount, val: 0)
    Constant.UserDefault.set(key: Constant.UserDefault.Key.ReviewApp, val: false)
    Constant.UserDefault.set(key: Constant.UserDefault.Key.FeedbackApp, val: false)
  }
  
  func setCount() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.ReviewCount, val: 0)
  }
  
  func setReview() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.ReviewApp, val: true)
  }
  
  func setFeedback() {
    Constant.UserDefault.set(key: Constant.UserDefault.Key.FeedbackApp, val: true)
  }
}