//
//  HashableExt.swift
//  Master
//
//  Created by Sina khanjani on 9/16/1399 AP.
//

import UIKit
import CryptoSwift

// MARK: String Extentions
extension String {
    var toEnNumber: String {
        let oldCount = self.count
        let formatter: NumberFormatter = NumberFormatter()
        formatter.locale = Locale(identifier: "EN")
        
        if let final = formatter.number(from: self) {
            let newCount = "\(final)".count
            let differ = oldCount - newCount
            if differ == 0 {
                return "\(final)"
            } else {
                var outFinal = "\(final)"
                for _ in 1...differ {
                    outFinal = "0" + outFinal
                }
                return outFinal
            }
        }
        
        return ""
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        return phoneTest.evaluate(with: self)
    }
    
    var isValidEmail: Bool { NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self) }
    
    /*
     /// No special characters (e.g. @,#,$,%,&,*,(,),^,<,>,!,±)
     Pattern details:
     ^ - start of the string (can be replaced with \A to ensure start of string only matches)
     \w{7,18} - 7 to 18 word characters (i.e. any Unicode letters, digits or underscores, if you only allow ASCII letters and digits, use [a-zA-Z0-9] or [a-zA-Z0-9_] instead)
     $ - end of string (for validation, I'd rather use \z instead to ensure end of string only matches).
     Swift code
     
     Note that if you use it with NSPredicate and MATCHES, you do not need the start/end of string anchors, as the match will be anchored by default:
     */
    var isValidUserID: Bool { range(of: "\\A\\w{7,18}\\z", options: .regularExpression) != nil }
    
    ///In 99% of the cases when I trim String in Swift, I want to remove spaces and other similar symbols
    var trimmed: String {trimmingCharacters(in: .whitespacesAndNewlines) }
    
    ///In 99% of the cases when I trim String in Swift, I want to remove spaces and other similar symbols
    mutating func trim() {
        self = self.trimmed
    }
    
    ///iOS and macOS use the URL type to handle links. It’s more flexible, it allows to get components, and it handles different types of URLs. At the same time, we usually enter it or get it from API String.
    var asURL: URL? {
        URL(string: self)
    }
    
    ///Like the previous extension, this one checks the content of String. It returns true if the string is not empty and contains only alphanumeric characters. An inverted version of this extension can be useful to confirm that passwords have non-alphanumeric characters.
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    ///Getting the Date from String and formatting the Date to display it or send to API are common tasks. The standard way to convert takes three lines of code. Let’s see how to make it shorter:
    func toDate(format: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: self)
    }
    
    ///iOS can calculate the size of UILabel automatically, using provided constraints, but sometimes it’s important to set the size yourself.
    ///This extension allows us to calculate the String width and height using the provided UIFont:
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    ///iOS can calculate the size of UILabel automatically, using provided constraints, but sometimes it’s important to set the size yourself.
    ///This extension allows us to calculate the String width and height using the provided UIFont:
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    ///JSON is a popular format to exchange or store structured data. Most APIs prefer to use JSON. JSON is a JavaScript structure. Swift has exactly the same data type — dictionary.
    ///let json = "{\"hello\": \"world\"}"
    ///let dictFromJson = json.asDict
    var asDict: [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
    ///This extension is similar to a previous one, but it converts the JSON array into a Swift array:
    ///let json2 = "[1, 2, 3]"
    ///let arrFromJson2 = json2.asArray
    var asArray: [Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
    }
    
    ///only allows you to initialize a String that obeys some common best practices for choosing a password
    init?(passwordSafeString: String) {
        guard passwordSafeString.rangeOfCharacter(from: .uppercaseLetters) != nil &&
                passwordSafeString.rangeOfCharacter(from: .lowercaseLetters) != nil &&
                passwordSafeString.rangeOfCharacter(from: .punctuationCharacters) != nil &&
                passwordSafeString.rangeOfCharacter(from: .decimalDigits) != nil  else {
                    return nil
                }
        
        self = passwordSafeString
    }
    
    /// convert "yyyy-MM-dd'T'HH:mm:ss.SSSZ" date format comming from server to any date format used in jobloyal. exmaple: 2021-04-29T20:37:07.830Z
    func to(date with: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //2021-04-29T20:37:07.830Z
        guard let date = dateFormatter.date(from: self) else { return nil }
        dateFormatter.dateFormat = with
        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.locale = Locale(identifier: "fa_IR")
        
        return dateFormatter.string(from: date)
    }
    
    func toNonQuotes() -> String {
        let userInput: String = self
        return userInput.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func toJSONObject<T: Codable>(typeOf: T.Type) -> T? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: StringProtocol Extentions
extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}

// MARK: NSAttributedString Extentions
extension NSAttributedString {
    ///iOS can calculate the size of UILabel automatically, using provided constraints, but sometimes it’s important to set the size yourself.
    ///This extension allows us to calculate the String width and height using the provided UIFont:
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    ///iOS can calculate the size of UILabel automatically, using provided constraints, but sometimes it’s important to set the size yourself.
    ///This extension allows us to calculate the String width and height using the provided UIFont:
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    ///Swift 5 has a horrible way of subscripting Strings. Calculating indexes and offsets is annoying if you want to get, for example, characters from 5 to 10. This extension allows to use simple Ints for this purpose:
    ///let subscript1 = "Hello, world!"[7...]
    ///let subscript2 = "Hello, world!"[7...11]
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start..<end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex...end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex..<end]
    }
    
    func localized(_ comment: String = "", bundle: Bundle = .main) -> String {
        NSLocalizedString(self, bundle: .main, comment: comment)
    }
}

// MARK: Int Extentions
extension Int {
    /// you can convert it with Double(a) , where a is an
    ///integer variable. But if a is optional, you can’t do it. Usage:
    ///Let’s add extensions to Int and Double :
    func toDouble() -> Double {
        Double(self)
    }
    
    /**
     One of the most useful features of Java is toString() method. It’s a method of absolutely all classes and types. Swift allows to do something similar using string interpolation: "\(someVar)" . But there’s one difference — your variable is optional. Swift will add the word optional to the output. Java will just crash, but Kotlin will handle optionals beautifully: someVar?.toString() will return an optional
     String, which is null ( nil ) if someVar is null ( nil ) or String containing value of var otherwise.
     */
    func toString() -> String {
        "\(self)"
    }
}

// MARK: Double Extentions
extension Double {
    ///As in the previous example, converting Double to String can be very useful. But in this case we’ll limit the output with two
    ///fractional digits. I can’t say this extension will be useful for all cases, but for most uses it will work well:
    func toString() -> String {
        String(format: "%.02f", self)
    }
    
    ///you can convert it with Double(a) , where a is an
    ///integer variable. But if a is optional, you can’t do it. Usage:
    ///Let’s add extensions to Int and Double :
    func toInt() -> Int {
        Int(self)
    }
}

extension String {
    func toInt() -> Int? {
        Int(self)
    }
    
    func toDouble() -> Double? {
        Double(self)
    }
}

extension String {
    private enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    private func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    private func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    private func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    public func makeACall() {
        if isValid(regex: .phone) {
//            let tel = self.onlyDigits()
            if let url = URL(string: "tel://\(self)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

///I found this really useful but I needed to do it in quite a few places so I've wrapped my approach up in a simple extension to NSMutableAttributedString:
extension NSMutableAttributedString {
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            return true
        }
        
        return false
    }
}

extension String {
    var toPriceFormatter: String {
        guard Int(self) != nil else {
            return "-"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let nsNumber = NSNumber(value: Int(self)!)
        let number = formatter.string(from: nsNumber)!
        
        return number
    }
}

extension Int {
    var toPriceFormatter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        let nsNumber = NSNumber(value: self)
        let number = formatter.string(from: nsNumber)!
        
        return number
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    var toCurrencyPriceFormatter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        return formatter.string(from: NSNumber(value: self))!
    }
    
    var toPriceFormatter: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let nsNumber = NSNumber(value: self)
        let number = formatter.string(from: nsNumber)!
        
        return number
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Array where Element == String {
    func includes() -> String {
        joined(separator: ",")
    }
}

enum AESError: Error {
    case failDecode
}
extension String {
    func aesDecrypt() throws -> String {
//        let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0))!
//        let decodeAES = try AES(key: "92e8d7c670ea01f57edc230c596687a65", iv: "c588adc65d3f3ea8").decrypt(data.bytes)
        let data = Data(base64Encoded: self)!
        let iv = "c588adc65d3f3ea8"
        let key = "92e8d7c670ea01f57edc230c59668765"
        let decodeAES = try AES(key: key, iv: iv).decrypt([UInt8](data))
        let decodedData =  decodeAES.data

        if let result = String(data: decodedData, encoding: .utf8) {
            return result
        }
        
        throw(AESError.failDecode)
    }
}

extension Array where Element == UInt8 {
    public var data: Data {
        var items: [UInt8] = self.map { UInt8($0) }
        let nsdata = NSData(bytes: &items, length: items.count)
        let dataF = Data.init(referencing: nsdata)
        items = []
        
        return dataF
    }
    
    public var string: String? {
        var items: [UInt8] = self
        let nsdata = NSData(bytes: &items, length: items.count)
        let data = Data.init(referencing: nsdata)
        items = []
        
        return String.init(data: data, encoding: .utf8)
    }
}


#if os(Linux) || os(Android) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

struct RandomBytesSequence: Sequence {
    let size: Int

    func makeIterator() -> AnyIterator<UInt8> {
        var count = 0
        return AnyIterator<UInt8>.init({ () -> UInt8? in
            if count >= self.size {
                return nil
            }
            count = count + 1

            #if os(Linux) || os(Android) || os(FreeBSD)
                let fd = open("/dev/urandom", O_RDONLY)
                if fd <= 0 {
                    return nil
                }

                var value: UInt8 = 0
                let result = read(fd, &value, MemoryLayout<UInt8>.size)
                precondition(result == 1)

                close(fd)
                return value
            #else
                return UInt8(arc4random_uniform(UInt32(UInt8.max) + 1))
            #endif
        })
    }
}
