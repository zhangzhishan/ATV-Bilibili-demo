//
//  FlexibleJSONDecoding.swift
//  BilibiliLive
//

import Foundation

extension KeyedDecodingContainer {
    /// Bilibili APIs occasionally switch numeric fields between JSON numbers
    /// and numeric strings. Decode both forms without failing the whole feed.
    func decodeFlexibleIntIfPresent(forKey key: Key) -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value
        }
        if let value = try? decodeIfPresent(String.self, forKey: key) {
            return Int(value)
        }
        return nil
    }
}
