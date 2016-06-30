import Foundation

extension String {
  var isBlank: Bool {
    get {
      let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      return trimmed.isEmpty
    }
  }
  
  var isEmail: Bool {
    do {
      let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
    } catch {
      return false
    }
  }
  
  var isPhoneNumber: Bool {
    let charcter  = NSCharacterSet(charactersInString: "+0123456789").invertedSet
    var filtered:NSString!
    let inputString:NSArray = self.componentsSeparatedByCharactersInSet(charcter)
    filtered = inputString.componentsJoinedByString("")
    return  self == filtered
  }
  
  var isPassword: Bool {
    do {
      // 6+, 1 num, 1 cap, 1 lower
      let regex = try NSRegularExpression(pattern: "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$", options: .CaseInsensitive)
      return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
      // 8+, 1 num, 1 cap, 1 lower, 1 special
      // "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$
    } catch {
      return false
    }
  }
}

extension String {
  var trim: String {
    return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
  
  var length: Int {
    return self.characters.count
  }
}

extension String {
  subscript(integerIndex: Int) -> Character {
    let index = startIndex.advancedBy(integerIndex)
    return self[index]
  }
  
  subscript(integerRange: Range<Int>) -> String {
    let start = startIndex.advancedBy(integerRange.startIndex)
    let end = startIndex.advancedBy(integerRange.endIndex)
    let range = start..<end
    return self[range]
  }
}