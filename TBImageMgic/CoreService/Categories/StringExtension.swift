
import UIKit
import Foundation
import CommonCrypto

// MARK: 处理
extension String {
    public
    var trim: String {
        var resultString = self.trimmingCharacters(in: CharacterSet.whitespaces)
        resultString = resultString.trimmingCharacters(in: CharacterSet.newlines)
        return resultString
    }
    
    public
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = self.data(using: .utf8) {
            _ = d.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(d.count), &digest)
                return ""
            }
        }
        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    // MARK: 截取
    public func subToIndex(index : Int) -> String {
        return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: index)])
    }
}

