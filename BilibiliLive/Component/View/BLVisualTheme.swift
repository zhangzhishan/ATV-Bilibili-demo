//
//  BLVisualTheme.swift
//  BilibiliLive
//
//  Created by Codex on 2026/3/29.
//

import UIKit

enum BLVisualTheme {
    static let accent = UIColor(hex: 0x48C2F9)
    static let accentSecondary = UIColor(hex: 0x34B4EA)
    static let textOnAccent = UIColor(hex: 0x00394F)
    static let textPrimary = UIColor(hex: 0xF6F6FC)
    static let textSecondary = UIColor(hex: 0xAAABB0)
    static let cardBackground = UIColor(hex: 0x171A1F, alpha: 0.6)
    static let cardStroke = UIColor(hex: 0x46484D, alpha: 0.3)
    static let focusGlow = UIColor(hex: 0x48C2F9, alpha: 0.15)
    static let sidebarBackground = UIColor(hex: 0x111318)
    static let appBackgroundTop = UIColor(hex: 0x0C0E12)
    static let appBackgroundBottom = UIColor(hex: 0x0C0E12)
}

final class BLGradientBackgroundView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    private var gradientLayer: CAGradientLayer {
        layer as! CAGradientLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        isUserInteractionEnabled = false
        gradientLayer.colors = [
            BLVisualTheme.appBackgroundTop.cgColor,
            BLVisualTheme.appBackgroundBottom.cgColor,
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }
}

extension UIViewController {
    private static let modernBackgroundTag = 0xB17B71

    func applyModernBackgroundIfNeeded() {
        guard view.viewWithTag(Self.modernBackgroundTag) == nil else { return }
        let backgroundView = BLGradientBackgroundView()
        backgroundView.tag = Self.modernBackgroundTag
        view.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
