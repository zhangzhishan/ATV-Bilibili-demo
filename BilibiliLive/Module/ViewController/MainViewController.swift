//
//  MainViewController.swift
//  BilibiliLive
//
//  Created on 2026/4/7.
//

import Kingfisher
import SnapKit
import UIKit

class MainViewController: UIViewController {
    // MARK: - Top Bar

    private let topBar = UIView()
    private let searchButton = BLCustomButton()
    private let segmentedControl = UISegmentedControl(items: ["首页", "直播"])
    private let avatarControl = AvatarControl()

    // MARK: - Content

    private let contentView = UIView()
    private var homeVC: HomeShelfViewController?
    private var liveVC: LiveShelfViewController?
    private weak var currentChild: UIViewController?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyModernBackgroundIfNeeded()
        setupTopBar()
        setupContentView()
        setupFocusGuides()

        // Default to home
        segmentedControl.selectedSegmentIndex = 0
        switchToHome()

        // Listen for account changes to refresh avatar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAccountUpdate),
            name: AccountManager.didUpdateNotification,
            object: nil
        )
        updateAvatar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupTopBar() {
        topBar.backgroundColor = .clear
        view.addSubview(topBar)
        topBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        // Search button (left)
        searchButton.image = UIImage(systemName: "magnifyingglass")
        topBar.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(60)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }
        searchButton.onPrimaryAction = { [weak self] _ in
            self?.presentSearch()
        }

        // Segmented control (center)
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        topBar.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(360)
        }

        // Avatar control (right) — focusable, loads avatar from network
        avatarControl.addTarget(self, action: #selector(avatarTapped), for: .primaryActionTriggered)
        topBar.addSubview(avatarControl)
        avatarControl.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(60)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
    }

    private func setupContentView() {
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupFocusGuides() {
        // Focus guide below top bar directing to content.
        // This preserves the existing "top bar -> content" down-navigation.
        let belowBarGuide = UIFocusGuide()
        view.addLayoutGuide(belowBarGuide)
        belowBarGuide.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topBar.snp.bottom)
            make.height.equalTo(10)
        }
        belowBarGuide.preferredFocusEnvironments = [contentView]

        // Symmetric focus bridge from the top edge of content back to the
        // segmented control. Without this, repeatedly swiping up inside the
        // shelf content can get trapped in the collection view, especially
        // when remembersLastFocusedIndexPath restores the last content cell.
        let aboveContentGuide = UIFocusGuide()
        view.addLayoutGuide(aboveContentGuide)
        aboveContentGuide.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(contentView.snp.top)
            make.height.equalTo(10)
        }
        aboveContentGuide.preferredFocusEnvironments = [segmentedControl]
    }

    // MARK: - Child VC Management

    private func switchToHome() {
        if homeVC == nil {
            homeVC = HomeShelfViewController()
        }
        transitionTo(homeVC!)
    }

    private func switchToLive() {
        if liveVC == nil {
            liveVC = LiveShelfViewController()
        }
        transitionTo(liveVC!)
    }

    private func transitionTo(_ child: UIViewController) {
        guard child !== currentChild else { return }

        currentChild?.willMove(toParent: nil)
        currentChild?.view.removeFromSuperview()
        currentChild?.removeFromParent()

        addChild(child)
        contentView.addSubview(child.view)
        child.view.makeConstraintsToBindToSuperview()
        child.didMove(toParent: self)

        currentChild = child

        // Allow the collection view to drive the scroll indicator
        if let shelfVC = child as? ShelfViewController {
            setContentScrollView(shelfVC.collectionView)
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            switchToHome()
        } else {
            switchToLive()
        }
    }

    @objc private func avatarTapped() {
        let personalVC = PersonalViewController.create()
        personalVC.modalPresentationStyle = .fullScreen
        present(personalVC, animated: true)
    }

    private func presentSearch() {
        let resultVC = SearchResultViewController()
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = resultVC
        present(UISearchContainerViewController(searchController: searchVC), animated: true)
    }

    // MARK: - Account

    @objc private func handleAccountUpdate() {
        updateAvatar()
    }

    private func updateAvatar() {
        guard let account = AccountManager.shared.activeAccount,
              let url = URL(string: account.profile.avatar),
              !account.profile.avatar.isEmpty
        else {
            avatarControl.setPlaceholder()
            return
        }
        avatarControl.setAvatarURL(url)
    }

    // MARK: - Play/Pause Reload

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        guard let buttonPress = presses.first?.type else { return }
        if buttonPress == .playPause {
            if let reloadVC = currentChild as? BLTabBarContentVCProtocol {
                reloadVC.reloadData()
            }
        }
    }
}

// MARK: - AvatarControl

/// A focusable circular avatar control for tvOS.
/// Uses Kingfisher to load the user's avatar image from a URL.
private class AvatarControl: UIControl {
    private let imageView = UIImageView()

    override var canBecomeFocused: Bool { true }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        clipsToBounds = true
        backgroundColor = BLVisualTheme.cardBackground
        layer.borderWidth = 2
        layer.borderColor = BLVisualTheme.cardStroke.cgColor

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = BLVisualTheme.textSecondary
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2
        layer.cornerRadius = radius
        imageView.layer.cornerRadius = radius
    }

    func setAvatarURL(_ url: URL) {
        imageView.kf.setImage(
            with: url,
            options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: 112, height: 112))),
                .processor(RoundCornerImageProcessor(radius: .widthFraction(0.5))),
                .cacheSerializer(FormatIndicatedCacheSerializer.png),
            ]
        )
    }

    func setPlaceholder() {
        imageView.kf.cancelDownloadTask()
        imageView.image = UIImage(systemName: "person.crop.circle.fill")
    }

    // MARK: - Focus

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations {
            if self.isFocused {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.layer.borderColor = BLVisualTheme.accent.cgColor
                self.layer.shadowColor = BLVisualTheme.focusGlow.cgColor
                self.layer.shadowOpacity = 0.5
                self.layer.shadowOffset = CGSize(width: 0, height: 8)
                self.layer.shadowRadius = 16
            } else {
                self.transform = .identity
                self.layer.borderColor = BLVisualTheme.cardStroke.cgColor
                self.layer.shadowOpacity = 0
            }
        }
    }

    // MARK: - Press handling

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        if presses.first?.type == .select {
            sendActions(for: .primaryActionTriggered)
        }
    }
}
