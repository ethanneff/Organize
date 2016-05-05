protocol Copying {
  init(original: Self)
}

extension Copying {
  func copy() -> Self {
    return Self.init(original: self)
  }
}

extension Array where Element: Copying {
  func clone() -> Array {
    var copiedArray = Array<Element>()
    for element in self {
      copiedArray.append(element.copy())
    }
    return copiedArray
  }
}
