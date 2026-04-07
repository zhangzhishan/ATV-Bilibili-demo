//
//  FeedViewController.swift
//  BilibiliLive
//
//  Created by yicheng on 2021/5/19.
//

import UIKit

class FeedViewController: StandardVideoCollectionViewController<ApiRequest.FeedResp.Items> {
    private let topNavBar = TopNavigationBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(topNavBar)
        topNavBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        collectionVC.collectionView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
    }

    override func setupCollectionView() {
        super.setupCollectionView()
        collectionVC.pageSize = 1
    }

    override func request(page: Int) async throws -> [ApiRequest.FeedResp.Items] {
        if page == 1 {
            return try await ApiRequest.getFeeds()
        } else if let last = (collectionVC.displayDatas.last as? ApiRequest.FeedResp.Items)?.idx {
            return try await ApiRequest.getFeeds(lastIdx: last)
        } else {
            throw NSError(domain: "", code: -1)
        }
    }
}

extension ApiRequest.FeedResp.Items: PlayableData {
    var aid: Int { Int(param) ?? 0 }
    var cid: Int { 0 }
}
