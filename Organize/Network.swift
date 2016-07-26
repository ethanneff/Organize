//
//  Network.swift
//  Organize
//
//  Created by Ethan Neff on 7/24/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

class Network {
  // MARK: - singleton
  static let sharedInstance = Network()
  private init() {}
  
  // MARK: - completion blocks
  typealias JSONDictionaryCompletion = ([String: AnyObject]? -> ())
  typealias UIImageCompletion = (UIImage? -> ())
  
  // MARK: - download
  func downloadImage(url url: String, completion: UIImageCompletion) {
    func complete(data: UIImage?) {
      dispatch_async(dispatch_get_main_queue(),{
        return completion(data)
      })
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      guard let url = NSURL(string: url) else { return complete(nil) }
      let request = NSURLRequest(URL: url)
      NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (let data, let response, let error) in
        guard
          let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
          let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
          let data = data where error == nil,
          let image = UIImage(data: data)
          else { return complete(nil) }
        return complete(image)
        }.resume()
    }
  }
  
  func downloadJSON(url url: String, completion: JSONDictionaryCompletion) {
    func complete(data: [String: AnyObject]?) {
      dispatch_async(dispatch_get_main_queue(),{
        return completion(data)
      })
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      guard let url = NSURL(string: url) else { return complete(nil) }
      let request = NSURLRequest(URL: url)
      NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (let data, let response, let error) in
        guard
          let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
          let data = data where error == nil,
          let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject]
          else { return complete(nil) }
        return complete(json)
        }.resume()
    }
  }
}