//
//  UILabel.swift
//  Organize
//
//  Created by Ethan Neff on 7/24/16.
//  Copyright © 2016 Ethan Neff. All rights reserved.
//

import UIKit

extension UILabel {
  // MARK: - text height
  func heightWithWidth(width: CGFloat) -> CGFloat {
    guard let text = text else {
      return 0
    }
    return text.heightWithWidth(width, font: font)
  }
  
  func heightWithAttributedWidth(width: CGFloat) -> CGFloat {
    guard let attributedText = attributedText else {
      return 0
    }
    return attributedText.heightWithWidth(width)
  }
}

extension String {
  func heightWithWidth(width: CGFloat, font: UIFont) -> CGFloat {
    let maxSize = CGSize(width: width, height: CGFloat.max)
    let actualSize = self.boundingRectWithSize(maxSize, options: [.UsesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
    return actualSize.height
  }
}

extension NSAttributedString {
  func heightWithWidth(width: CGFloat) -> CGFloat {
    let maxSize = CGSize(width: width, height: CGFloat.max)
    let actualSize = boundingRectWithSize(maxSize, options: [.UsesLineFragmentOrigin], context: nil)
    return actualSize.height
  }
}