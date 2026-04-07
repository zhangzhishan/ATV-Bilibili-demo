//
//  LiveShelfViewController.swift
//  BilibiliLive
//
//  Created on 2026/4/7.
//

import UIKit

class LiveShelfViewController: ShelfViewController, BLTabBarContentVCProtocol {
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
                title: "关注",
                loadData: {
                    let rooms = try await WebRequest.requestLiveRoom(page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = MyLiveViewController()
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "推荐",
                loadData: {
                    let rooms = try await WebRequest.requestRecommandLiveRoom(page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: -1)
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "人气",
                loadData: {
                    let rooms = try await WebRequest.requestHotLiveRoom(page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: 0)
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "娱乐",
                loadData: {
                    let rooms = try await WebRequest.requestAreaLiveRoom(area: 1, page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: 1)
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "虚拟主播",
                loadData: {
                    let rooms = try await WebRequest.requestAreaLiveRoom(area: 9, page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: 9)
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "网游",
                loadData: {
                    let rooms = try await WebRequest.requestAreaLiveRoom(area: 2, page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: 2)
                    self.present(vc, animated: true)
                }
            ),
            ShelfSectionConfig(
                title: "单机",
                loadData: {
                    let rooms = try await WebRequest.requestAreaLiveRoom(area: 6, page: 1)
                    return Array(rooms.prefix(10))
                },
                showAllAction: { [weak self] in
                    guard let self else { return }
                    let vc = AreaLiveViewController(areaID: 6)
                    self.present(vc, animated: true)
                }
            ),
        ]
    }

    // MARK: - Selection

    private func handleSelect(_ data: any DisplayData) {
        let playerVC = LivePlayerViewController()
        if let liveRoom = data as? LiveRoom {
            playerVC.room = liveRoom
        } else if let areaRoom = data as? AreaLiveRoom {
            playerVC.room = areaRoom.toLiveRoom()
        } else {
            return
        }
        present(playerVC, animated: true)
    }
}
