//
//  HomeShelfViewController.swift
//  BilibiliLive
//
//  Created on 2026/4/7.
//

import UIKit

class HomeShelfViewController: ShelfViewController, BLTabBarContentVCProtocol {
    override func viewDidLoad() {
        configureSections(makeSections())
        super.viewDidLoad()

        didSelect = { [weak self] data in
            self?.handleSelect(data)
        }

        loadAllSections()
    }

    func reloadData() {
        loadAllSections()
    }

    // MARK: - Section Definitions

    private func makeSections() -> [ShelfSectionConfig] {
        return [
            ShelfSectionConfig(
                title: "关注动态",
                loadData: {
                    let info = try await WebRequest.requestFollowsFeed(offset: "", page: 1)
                    return Array(info.videoFeeds.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = FollowsViewController()
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "追番更新",
                loadData: {
                    let data = try await WebRequest.requestFollowBangumiList(type: 1)
                    return Array((data?.list ?? []).prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = FollowBangumiViewController()
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "推荐",
                loadData: {
                    let items = try await ApiRequest.getFeeds()
                    return Array(items.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = FeedViewController()
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "热门",
                loadData: {
                    let data = try await WebRequest.requestHotVideo(page: 1)
                    return Array(data.list.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = HotViewController()
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "排行榜",
                loadData: {
                    let list = try await WebRequest.requestRank(for: 0)
                    return Array(list.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = RankingViewController()
                    self.present(vc, animated: true)
                }
            ),
        ]
    }

    // MARK: - Selection

    private func handleSelect(_ data: any DisplayData) {
        if let feed = data as? DynamicFeedData {
            let epid = feed.modules.module_dynamic.major?.pgc?.epid
            let detailVC = VideoDetailViewController.create(aid: feed.aid, cid: feed.cid, epid: epid)
            detailVC.present(from: self)
        } else if let bangumi = data as? FollowBangumiListData.Bangumi {
            let detailVC = VideoDetailViewController.create(seasonId: bangumi.season_id)
            detailVC.present(from: self)
        } else if let feedItem = data as? ApiRequest.FeedResp.Items {
            let aid = Int(feedItem.param) ?? 0
            let detailVC = VideoDetailViewController.create(aid: aid, cid: 0)
            detailVC.present(from: self)
        } else if let videoInfo = data as? VideoDetail.Info {
            let detailVC = VideoDetailViewController.create(aid: videoInfo.aid, cid: videoInfo.cid)
            detailVC.present(from: self)
        }
    }
}
