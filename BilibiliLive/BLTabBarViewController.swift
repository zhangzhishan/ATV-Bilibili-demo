//
//  BLTabBarViewController.swift
//  BilibiliLive
//
//  Created by Etan Chen on 2021/4/5.
//

import UIKit

protocol BLTabBarContentVCProtocol {
    func reloadData()
}

let selectedIndexKey = "BLTabBarViewController.selectedIndex"

class BLTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    static func clearSelected() {
        UserDefaults.standard.removeObject(forKey: selectedIndexKey)
    }

    deinit {
        print("BLTabBarViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyModernBackgroundIfNeeded()
        configureTabBarAppearance()
        delegate = self
        var vcs = [UIViewController]()

        let followVC = FollowsViewController()
        followVC.tabBarItem.title = "关注"
        vcs.append(followVC)

        let feedVC = FeedViewController()
        feedVC.tabBarItem.title = "推荐"
        vcs.append(feedVC)

        let hotVC = HotViewController()
        hotVC.tabBarItem.title = "热门"
        vcs.append(hotVC)

        let rank = RankingViewController()
        rank.tabBarItem.title = "排行榜"
        vcs.append(rank)

        let liveVC = LiveViewController()
        liveVC.tabBarItem.title = "直播"
        vcs.append(liveVC)

        let fav = FavoriteViewController()
        fav.tabBarItem.title = "收藏"
        vcs.append(fav)

        let persionVC = PersonalViewController.create()
        persionVC.extendedLayoutIncludesOpaqueBars = true
        persionVC.tabBarItem.title = "我的"
        vcs.append(persionVC)

        setViewControllers(vcs, animated: false)
        selectedIndex = UserDefaults.standard.integer(forKey: selectedIndexKey)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.28)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BLVisualTheme.textSecondary,
            .font: UIFont.systemFont(ofSize: 27, weight: .semibold),
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: BLVisualTheme.textPrimary,
            .font: UIFont.systemFont(ofSize: 27, weight: .bold),
        ]

        for itemAppearance in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            itemAppearance.normal.titleTextAttributes = normalAttributes
            itemAppearance.normal.iconColor = BLVisualTheme.textSecondary
            itemAppearance.selected.titleTextAttributes = selectedAttributes
            itemAppearance.selected.iconColor = BLVisualTheme.accent
            itemAppearance.focused.titleTextAttributes = selectedAttributes
            itemAppearance.focused.iconColor = BLVisualTheme.accent
        }

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.unselectedItemTintColor = BLVisualTheme.textSecondary
        tabBar.tintColor = BLVisualTheme.accent
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        guard let buttonPress = presses.first?.type else { return }
        if buttonPress == .playPause {
            if let reloadVC = topMostViewController() as? BLTabBarContentVCProtocol {
                print("send reload to \(reloadVC)")
                reloadVC.reloadData()
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UserDefaults.standard.set(tabBarController.selectedIndex, forKey: selectedIndexKey)
    }
}
