//
//  ContinueWatchingViewController.swift
//  BilibiliLive
//

import UIKit

class ContinueWatchingViewController: UIViewController {
    let collectionVC = FeedCollectionViewController()

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [collectionVC.collectionView]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyModernBackgroundIfNeeded()
        view.backgroundColor = .clear
        collectionVC.show(in: self)
        collectionVC.didSelect = { [weak self] in
            self?.goDetail(with: $0 as! HistoryData)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    func goDetail(with history: HistoryData) {
        let detailVC = VideoDetailViewController.create(aid: history.aid, cid: history.cid ?? 0)
        detailVC.present(from: self)
    }
}

extension ContinueWatchingViewController: BLTabBarContentVCProtocol {
    func reloadData() {
        WebRequest.requestHistory { [weak self] datas in
            self?.collectionVC.displayDatas = ContinueWatchingFilter.filtered(datas)
        }
    }
}

extension HistoryData: ContinueWatchingHistoryItem {
    var continueWatchingViewAt: Int { view_at }
    var continueWatchingProgress: Int { progress }
    var continueWatchingDuration: Int { duration }
}
