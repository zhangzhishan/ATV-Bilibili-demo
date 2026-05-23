import Foundation

@main
struct MainContentTabTests {
    static func main() {
        let expectedTitles = ["首页", "继续观看", "直播"]
        let actualTitles = MainContentTab.allCases.map(\.title)
        precondition(actualTitles == expectedTitles, "Expected main content tabs \(expectedTitles), got \(actualTitles)")

        precondition(MainContentTab.home.rawValue == 0, "Home should remain the first tab")
        precondition(MainContentTab.continueWatching.rawValue == 1, "Continue watching should be visible between home and live")
        precondition(MainContentTab.live.rawValue == 2, "Live should remain reachable after continue watching")
    }
}
