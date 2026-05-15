//
//  String.swift
//  BilibiliLive
//
//  Created by whw on 2022/10/31.
//

import CoreFoundation
import Foundation

extension String {
    static func += (lhs: inout String, rhs: Int) {
        if let number = Int(lhs) {
            lhs = String(number + rhs)
        }
    }

    static func -= (lhs: inout String, rhs: Int) {
        if let number = Int(lhs) {
            lhs = String(number - rhs)
        }
    }

    func isMatch(pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        return regex.firstMatch(in: self, options: [], range: NSMakeRange(0, utf16.count)) != nil
    }

    func removingHTMLTags() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    func convertedTraditionalChineseToSimplified() -> String {
        guard !isEmpty else { return self }

        let mutable = NSMutableString(string: self)
        let didTransform = CFStringTransform(mutable, nil, "Traditional-Simplified" as CFString, false)
        return didTransform ? (mutable as String) : self
    }
}
