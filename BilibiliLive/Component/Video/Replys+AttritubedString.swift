//
//  Replys+AttritubedString.swift
//  BilibiliLive
//
//  Created by yicheng on 9/11/2024.
//

import Kingfisher
import UIKit

extension Replys.Reply {
    func createAttributedString(displayView: UIView) -> NSAttributedString? {
        guard let emote = content.emote, !emote.isEmpty else {
            return nil
        }
        let displayStyle = commentDisplayStyle(for: displayView)
        let attr = NSMutableAttributedString(string: content.message)
        attr.addAttributes([
            .font: displayStyle.font,
            .foregroundColor: displayStyle.foregroundColor,
        ], range: NSRange(location: 0, length: attr.length))
        for (tag, emote) in emote {
            guard let url = URL(string: emote.url) else { continue }
            let ranges = attr.string.ranges(of: tag).reversed()
            let emoteSize = 36.0
            for range in ranges {
                let textAttachment = NSTextAttachment()
                let textAttachmentString = NSMutableAttributedString(attachment: textAttachment)
                textAttachmentString.append(NSAttributedString(string: " ", attributes: [
                    .font: displayStyle.font,
                    .foregroundColor: displayStyle.foregroundColor,
                ]))
                attr.replaceCharacters(in: NSRange(range, in: attr.string), with: textAttachmentString)
                KF.url(url)
                    .resizing(referenceSize: CGSize(width: emoteSize, height: emoteSize))
                    .onSuccess { [weak textAttachment] res in
                        guard let textAttachment = textAttachment else { return }
                        textAttachment.bounds = CGRect(x: 0, y: displayStyle.descender, width: emoteSize, height: emoteSize)
                    }
                    .set(to: textAttachment, attributedView: displayView)
            }
        }
        return attr
    }

    private func commentDisplayStyle(for displayView: UIView) -> (font: UIFont, foregroundColor: UIColor, descender: CGFloat) {
        if let label = displayView as? UILabel {
            return (label.font, label.textColor ?? BLVisualTheme.commentText, label.font.descender)
        }
        if let button = displayView as? UIButton {
            let font = button.titleLabel?.font ?? BLVisualTheme.font(size: 30, weight: .medium)
            let color = button.titleColor(for: .normal) ?? BLVisualTheme.commentText
            return (font, color, font.descender)
        }
        let font = BLVisualTheme.font(size: 30, weight: .medium)
        return (font, BLVisualTheme.commentText, font.descender)
    }
}
