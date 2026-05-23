//
//  MainContentTab.swift
//  BilibiliLive
//

import Foundation

enum MainContentTab: Int, CaseIterable {
    case home
    case continueWatching
    case live

    var title: String {
        switch self {
        case .home:
            return "首页"
        case .continueWatching:
            return "继续观看"
        case .live:
            return "直播"
        }
    }
}
