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

enum FollowsFeedCompatibility {
    static func isPlayable(archiveAid: String?, pgcEpid: Int?) -> Bool {
        if let archiveAid, let aid = Int(archiveAid), aid > 0 {
            return true
        }
        return (pgcEpid ?? 0) > 0
    }

    static func canAdvance(hasMore: Bool, currentOffset: String, nextOffset: String) -> Bool {
        hasMore && nextOffset != currentOffset
    }
}
