//
//  BLVisualTheme.swift
//  BilibiliLive
//
//  Created by Codex on 2026/3/29.
//

import UIKit

enum BLVisualTheme {
    static let accent = UIColor(hex: 0x35C8FF)
    static let accentSecondary = UIColor(hex: 0x7A7DFF)
    static let textOnAccent = UIColor(hex: 0x06121F)
    static let textPrimary = UIColor(hex: 0xF5F8FF)
    static let textSecondary = UIColor(hex: 0xB7C2DC)
    static let cardBackground = UIColor(hex: 0x141B2F, alpha: 0.9)
    static let cardStroke = UIColor.white.withAlphaComponent(0.12)
    static let focusGlow = UIColor(hex: 0x5CCEFF, alpha: 0.7)
    static let sidebarBackground = UIColor(hex: 0x111A2E, alpha: 0.62)
    static let appBackgroundTop = UIColor(hex: 0x0A1020)
    static let appBackgroundBottom = UIColor(hex: 0x111C36)

    static func scaledFontSize(_ size: CGFloat) -> CGFloat {
        Settings.interfaceTextSize.scaled(size)
    }

    static func font(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: scaledFontSize(size), weight: weight)
    }
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
            UIColor(hex: 0x0D1730).cgColor,
            BLVisualTheme.appBackgroundBottom.cgColor,
        ]
        gradientLayer.locations = [0.0, 0.45, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.15, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.85, y: 1.0)
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
