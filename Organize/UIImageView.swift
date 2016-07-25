//
//  UIImageView.swift
//  Organize
//
//  Created by Ethan Neff on 7/24/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

// Contant.ImageView.create()
extension UIImageView {
  func loading(on on: Bool) {
    for v in subviews {
      if let indicator = v as? UIActivityIndicatorView {
        if on {
          indicator.startAnimating()
        } else {
          indicator.stopAnimating()
        }
        break
      }
    }
  }
}