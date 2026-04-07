//
//  ShelfViewController.swift
//  BilibiliLive
//
//  Created on 2026/4/7.
//

import SnapKit
import UIKit

/// Configuration for a single shelf section (one horizontal row).
struct ShelfSectionConfig {
    let title: String
    let loadData: () async throws -> [any DisplayData]
    let showAllAction: () -> Void
}

/// Reusable base class that renders multiple horizontal-scrolling sections
/// ("shelves") using `UICollectionViewCompositionalLayout`.
class ShelfViewController: UIViewController {
    private(set) var collectionView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<Int, ShelfItem>!
    private var sectionConfigs: [ShelfSectionConfig] = []

    /// Tracks which sections have been loaded so we can hide empty ones.
    private var loadedSections: Set<Int> = []

    /// Called when a card is tapped. Override point for subclasses.
    var didSelect: ((any DisplayData) -> Void)?

    /// Called when a card is long-pressed. Override point for subclasses.
    var didLongPress: ((any DisplayData) -> Void)?

    // MARK: - Subclass API

    /// Subclasses must call this (typically in `viewDidLoad`) to define
    /// which sections to display.
    func configureSections(_ configs: [ShelfSectionConfig]) {
        sectionConfigs = configs
    }

    /// Triggers async data loading for all sections.
    func loadAllSections() {
        loadedSections.removeAll()
        for index in sectionConfigs.indices {
            loadSection(at: index)
        }
    }

    /// Reload a single section.
    func loadSection(at index: Int) {
        guard index < sectionConfigs.count else { return }
        let config = sectionConfigs[index]
        Task { @MainActor in
            do {
                let items = try await config.loadData()
                let contentItems = items.prefix(10).map { ShelfItem.content(AnyDispplayData(data: $0)) }
                loadedSections.insert(index)

                if contentItems.isEmpty {
                    // Hide section entirely when no data
                    applyItems([], toSection: index)
                } else {
                    var wrapped = Array(contentItems)
                    wrapped.append(.showAll(section: index))
                    applyItems(wrapped, toSection: index)
                }
            } catch {
                Logger.warn("Shelf section '\(config.title)' load failed: \(error)")
                loadedSections.insert(index)
                // Hide section on error
                applyItems([], toSection: index)
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCollectionView()
        configureDataSource()
    }

    // MARK: - Layout

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.remembersLastFocusedIndexPath = true
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 50

        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, environment in
            guard let self else { return nil }

            // For sections with no items, return a minimal zero-height section
            let snapshot = self.dataSource?.snapshot()
            let itemCount = snapshot.map { sn in
                sn.sectionIdentifiers.contains(sectionIndex)
                    ? sn.itemIdentifiers(inSection: sectionIndex).count
                    : 0
            } ?? 0

            if itemCount == 0 {
                return self.makeEmptySection()
            }
            return self.makeShelfSection(environment: environment)
        }, configuration: config)
    }

    private func makeEmptySection() -> NSCollectionLayoutSection {
        // Collapsed section with zero height
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        return section
    }

    private func makeShelfSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let style = Settings.displayStyle

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(style.heightEstimated)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupWidth: CGFloat = style.fractionalWidth
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidth),
            heightDimension: .estimated(style.heightEstimated)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        // Extra top padding to prevent focused card scale-up from overlapping the header;
        // extra bottom padding so the shadow / scale doesn't bleed into the next section.
        section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 25, bottom: 40, trailing: 25)

        // Section header (non-focusable title only)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: ShelfSectionHeaderView.elementKind,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return section
    }

    // MARK: - Data Source

    private func configureDataSource() {
        let contentCellRegistration = UICollectionView.CellRegistration<FeedCollectionViewCell, AnyDispplayData> {
            [weak self] cell, _, displayData in
            cell.setup(data: displayData.data)
            cell.onLongPress = {
                self?.didLongPress?(displayData.data)
            }
        }

        let showAllCellRegistration = UICollectionView.CellRegistration<ShowAllCell, Int> {
            cell, _, _ in
            cell.configure()
        }

        dataSource = UICollectionViewDiffableDataSource<Int, ShelfItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case let .content(data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: contentCellRegistration, for: indexPath, item: data
                )
            case let .showAll(section):
                return collectionView.dequeueConfiguredReusableCell(
                    using: showAllCellRegistration, for: indexPath, item: section
                )
            }
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<ShelfSectionHeaderView>(
            elementKind: ShelfSectionHeaderView.elementKind
        ) { [weak self] headerView, _, indexPath in
            guard let self, indexPath.section < self.sectionConfigs.count else { return }
            headerView.setTitle(self.sectionConfigs[indexPath.section].title)
        }

        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }

        // Initialize empty snapshot with all sections
        var snapshot = NSDiffableDataSourceSnapshot<Int, ShelfItem>()
        for i in sectionConfigs.indices {
            snapshot.appendSections([i])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func applyItems(_ items: [ShelfItem], toSection section: Int) {
        var snapshot = dataSource.snapshot()
        let existing = snapshot.itemIdentifiers(inSection: section)
        snapshot.deleteItems(existing)
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate

extension ShelfViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case let .content(data):
            didSelect?(data.data)
        case let .showAll(section):
            guard section < sectionConfigs.count else { return }
            sectionConfigs[section].showAllAction()
        }
    }
}

// MARK: - ShelfItem

/// Distinguishes content cards from the trailing "show all" card.
enum ShelfItem: Hashable {
    case content(AnyDispplayData)
    case showAll(section: Int)
}

// MARK: - ShowAllCell

/// A compact focusable cell at the end of each shelf row that triggers
/// the "查看全部" action. Sized to match the height of content cards but
/// narrower in width, creating a clear visual "tail" element.
private class ShowAllCell: UICollectionViewCell {
    private let label = UILabel()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(blurView)
        blurView.layer.cornerRadius = 16
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = BLVisualTheme.cardStroke.cgColor
        blurView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            // Match the image area height of FeedCollectionViewCell, not the full cell
            let style = Settings.displayStyle
            let imageHeight: CGFloat = style == .large ? 320 : 230
            make.height.equalTo(imageHeight)
            make.width.equalTo(160)
        }

        label.text = "查看全部\n>"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        label.textColor = BLVisualTheme.textSecondary
        blurView.contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }

    func configure() {
        // Placeholder for future customization per-section
    }

    override var canBecomeFocused: Bool { true }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations {
            if self.isFocused {
                self.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
                self.label.textColor = BLVisualTheme.textOnAccent
                self.blurView.layer.borderColor = BLVisualTheme.accent.cgColor
                self.blurView.contentView.backgroundColor = BLVisualTheme.accent.withAlphaComponent(0.78)
                self.layer.shadowColor = BLVisualTheme.focusGlow.cgColor
                self.layer.shadowOpacity = 0.45
                self.layer.shadowOffset = CGSize(width: 0, height: 14)
                self.layer.shadowRadius = 22
            } else {
                self.transform = .identity
                self.label.textColor = BLVisualTheme.textSecondary
                self.blurView.layer.borderColor = BLVisualTheme.cardStroke.cgColor
                self.blurView.contentView.backgroundColor = .clear
                self.layer.shadowOpacity = 0
            }
        }
    }
}
