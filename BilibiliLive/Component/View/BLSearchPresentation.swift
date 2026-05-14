//
//  BLSearchPresentation.swift
//  BilibiliLive
//
//  Created by Codex on 2026/5/14.
//

import UIKit

enum BLSearchPresentation {
    static let placeholder = "搜索内容，或按住 Siri Remote 麦克风听写"
    static let accessibilityHint = "按住 Siri Remote 上的麦克风按钮可使用系统听写输入关键词。"

    static func makeSearchContainer(
        resultsController: UIViewController & UISearchResultsUpdating
    ) -> UIViewController {
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = resultsController
        searchController.applyBLTheme()
        searchController.configureBLVoiceFriendlySearch()

        let containerViewController = BLSearchContainerViewController(searchController: searchController)
        containerViewController.overrideUserInterfaceStyle = .dark
        containerViewController.modalPresentationStyle = .fullScreen
        return containerViewController
    }
}

final class BLSearchContainerViewController: UISearchContainerViewController {
    private var hasActivatedSearchField = false

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let textField = searchController.searchBar.blSearchTextField {
            return [textField]
        }

        return [searchController.searchBar]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activateSearchFieldIfNeeded()
    }

    private func activateSearchFieldIfNeeded() {
        guard !hasActivatedSearchField else { return }

        hasActivatedSearchField = true
        searchController.isActive = true
        setNeedsFocusUpdate()
        updateFocusIfNeeded()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.searchController.isActive = true
            if let textField = self.searchController.searchBar.blSearchTextField {
                _ = textField.becomeFirstResponder()
            } else {
                _ = self.searchController.searchBar.becomeFirstResponder()
            }
        }
    }
}

private extension UISearchController {
    func configureBLVoiceFriendlySearch() {
        obscuresBackgroundDuringPresentation = false
        searchBar.placeholder = BLSearchPresentation.placeholder
        searchBar.accessibilityLabel = "搜索"
        searchBar.accessibilityHint = BLSearchPresentation.accessibilityHint

        if let textField = searchBar.blSearchTextField {
            textField.placeholder = BLSearchPresentation.placeholder
            textField.accessibilityHint = BLSearchPresentation.accessibilityHint
        }
    }
}
