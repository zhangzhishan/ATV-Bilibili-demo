//
//  BLSearchPresentation.swift
//  BilibiliLive
//
//  Created by Codex on 2026/5/14.
//

import UIKit

enum BLSearchPresentation {
    static let placeholder = "搜索内容"
    static let accessibilityHint = "按住 Siri Remote 麦克风可听写，右侧按钮可切换是否自动繁体转简体。"

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
    private let conversionToggleButton = BLCustomTextButton()

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let textField = searchController.searchBar.blSearchTextField {
            return [textField, conversionToggleButton]
        }

        return [searchController.searchBar, conversionToggleButton]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConversionToggleButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activateSearchFieldIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutConversionToggleButton()
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

    private func configureConversionToggleButton() {
        conversionToggleButton.titleFont = BLVisualTheme.font(size: 24, weight: .semibold)
        conversionToggleButton.accessibilityLabel = "搜索繁体转简体"
        conversionToggleButton.accessibilityHint = "切换是否自动将繁体中文输入转换为简体中文。"
        conversionToggleButton.addTarget(self, action: #selector(toggleTraditionalChineseConversion), for: .primaryActionTriggered)
        view.addSubview(conversionToggleButton)
        updateConversionToggleButton()
    }

    private func layoutConversionToggleButton() {
        let searchFrame = searchController.searchBar.convert(searchController.searchBar.bounds, to: view)
        let textFieldFrame: CGRect
        if let textField = searchController.searchBar.blSearchTextField {
            textFieldFrame = textField.convert(textField.bounds, to: view)
        } else {
            textFieldFrame = searchFrame
        }
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let buttonWidth: CGFloat = 118
        let buttonHeight: CGFloat = 58
        let proposedX = textFieldFrame.maxX + 20
        let x = min(max(safeFrame.minX + 20, proposedX), safeFrame.maxX - buttonWidth)
        let y = max(safeFrame.minY + 12, textFieldFrame.midY - (buttonHeight / 2))
        conversionToggleButton.frame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
    }

    private func updateConversionToggleButton() {
        let isEnabled = Settings.searchAutoConvertTraditionalChineseToSimplified
        conversionToggleButton.title = isEnabled ? "转简 开" : "转简 关"
        conversionToggleButton.accessibilityValue = isEnabled ? "开" : "关"
    }

    @objc
    private func toggleTraditionalChineseConversion() {
        Settings.searchAutoConvertTraditionalChineseToSimplified.toggle()
        updateConversionToggleButton()

        guard Settings.searchAutoConvertTraditionalChineseToSimplified,
              let currentText = searchController.searchBar.text,
              !currentText.isEmpty
        else {
            searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
            return
        }

        let simplifiedText = currentText.convertedTraditionalChineseToSimplified()
        searchController.searchBar.text = simplifiedText
        searchController.searchBar.blSearchTextField?.text = simplifiedText
        searchController.searchResultsUpdater?.updateSearchResults(for: searchController)
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
