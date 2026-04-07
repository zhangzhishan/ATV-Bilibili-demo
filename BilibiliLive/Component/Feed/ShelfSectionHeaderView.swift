//
//  ShelfSectionHeaderView.swift
//  BilibiliLive
//
//  Created on 2026/4/7.
//

import SnapKit
import UIKit

/// A non-focusable section header that displays the section title.
/// The "查看全部" action is handled by a dedicated trailing cell in the
/// shelf row, avoiding focus-chain issues with boundary supplementary views.
class ShelfSectionHeaderView: UICollectionReusableView {
    static let elementKind = "shelf-section-header"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        label.textColor = BLVisualTheme.textPrimary
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func configure() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
            make.centerY.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
}
