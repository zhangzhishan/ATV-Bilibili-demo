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
    static let textPlaceholder = UIColor(hex: 0x8A97B5)
    static let cardBackground = UIColor(hex: 0x141B2F, alpha: 0.9)
    static let commentCardBackground = UIColor(hex: 0x0A1020, alpha: 0.96)
    static let commentDetailBackground = UIColor(hex: 0x050914, alpha: 0.98)
    static let inputBackground = UIColor(hex: 0x18233B, alpha: 0.96)
    static let commentUserName = UIColor(hex: 0xA7D9FF)
    static let commentText = UIColor(hex: 0xF8FBFF)
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

extension UITextField {
    func applyBLFormTheme() {
        overrideUserInterfaceStyle = .dark
        backgroundColor = BLVisualTheme.inputBackground
        textColor = BLVisualTheme.textPrimary
        tintColor = BLVisualTheme.accent
        keyboardAppearance = .dark
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        layer.masksToBounds = true

        defaultTextAttributes[.foregroundColor] = BLVisualTheme.textPrimary

        if let placeholder, !placeholder.isEmpty {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: BLVisualTheme.textPlaceholder]
            )
        }

        leftView?.applyBLInputIconTint(color: BLVisualTheme.textSecondary)
        rightView?.applyBLInputIconTint(color: BLVisualTheme.textSecondary)
        subviews.forEach { $0.applyBLInputIconTint(color: BLVisualTheme.textPrimary) }
    }
}

extension UISearchController {
    func applyBLTheme() {
        overrideUserInterfaceStyle = .dark
        searchBar.overrideUserInterfaceStyle = .dark
        searchBar.tintColor = BLVisualTheme.accent
        searchBar.barTintColor = BLVisualTheme.inputBackground
        searchBar.searchBarStyle = .minimal

        guard let textField = searchBar.blSearchTextField else { return }

        textField.applyBLFormTheme()
        textField.leftView?.applyBLInputIconTint(color: BLVisualTheme.textSecondary)
        textField.rightView?.applyBLInputIconTint(color: BLVisualTheme.textSecondary)
    }
}

extension UIAlertController {
    func applyBLTheme() {
        overrideUserInterfaceStyle = .dark
        view.tintColor = BLVisualTheme.accent
        textFields?.forEach { $0.applyBLFormTheme() }
    }

    func addBLTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        addTextField { textField in
            configurationHandler?(textField)
            textField.applyBLFormTheme()
        }
    }
}

private extension UIView {
    func blFirstDescendant<T: UIView>(of type: T.Type) -> T? {
        for subview in subviews {
            if let match = subview as? T {
                return match
            }

            if let match = subview.blFirstDescendant(of: type) {
                return match
            }
        }

        return nil
    }

    func applyBLInputIconTint(color: UIColor) {
        tintColor = color

        if let imageView = self as? UIImageView {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        }

        if let button = self as? UIButton {
            button.tintColor = color
            let states: [UIControl.State] = [.normal, .highlighted, .focused, .selected]
            states.forEach { state in
                button.setImage(button.image(for: state)?.withRenderingMode(.alwaysTemplate), for: state)
            }
        }

        subviews.forEach { $0.applyBLInputIconTint(color: color) }
    }
}

extension UISearchBar {
    var blSearchTextField: UITextField? {
        blFirstDescendant(of: UITextField.self)
    }
}
