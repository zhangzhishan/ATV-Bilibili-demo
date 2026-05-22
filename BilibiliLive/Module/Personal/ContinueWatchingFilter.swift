//
//  ContinueWatchingFilter.swift
//  BilibiliLive
//

import Foundation

protocol ContinueWatchingHistoryItem {
    var continueWatchingViewAt: Int { get }
    var continueWatchingProgress: Int { get }
    var continueWatchingDuration: Int { get }
}

enum ContinueWatchingFilter {
    static let defaultRecentDays = 7
    static let defaultFinishedTolerance = 60

    static func filtered<T: ContinueWatchingHistoryItem>(
        _ items: [T],
        now: Int = Int(Date().timeIntervalSince1970),
        recentDays: Int = defaultRecentDays,
        finishedTolerance: Int = defaultFinishedTolerance
    ) -> [T] {
        return items.filter {
            shouldInclude($0, now: now, recentDays: recentDays, finishedTolerance: finishedTolerance)
        }
    }

    static func shouldInclude<T: ContinueWatchingHistoryItem>(
        _ item: T,
        now: Int = Int(Date().timeIntervalSince1970),
        recentDays: Int = defaultRecentDays,
        finishedTolerance: Int = defaultFinishedTolerance
    ) -> Bool {
        let duration = item.continueWatchingDuration
        let progress = item.continueWatchingProgress
        guard duration > 0, progress > 0 else { return false }

        let recentWindow = recentDays * 24 * 60 * 60
        guard item.continueWatchingViewAt >= now - recentWindow else { return false }

        return progress < duration - effectiveFinishedTolerance(duration: duration, tolerance: finishedTolerance)
    }

    private static func effectiveFinishedTolerance(duration: Int, tolerance: Int) -> Int {
        guard duration < tolerance * 2 else { return tolerance }
        return max(5, Int(Double(duration) * 0.05))
    }
}
