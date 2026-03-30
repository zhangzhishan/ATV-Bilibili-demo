//
//  SpeedChangerPlugin.swift
//  BilibiliLive
//
//  Created by yicheng on 2024/5/25.
//

import AVKit

class SpeedChangerPlugin: NSObject, CommonPlayerPlugin {
    private var notifyView: UILabel?
    private weak var containerView: UIView?
    private weak var player: AVPlayer?
    private weak var playerVC: AVPlayerViewController?
    private var hasShownSpeedNotification = false

    @Published private(set) var currentPlaySpeed: PlaySpeed = .default

    func addViewToPlayerOverlay(container: UIView) {
        containerView = container
    }

    private func fadeOutNotifyView() {
        UIView.animate(withDuration: 1.0, animations: {
            self.notifyView?.alpha = 0.0 // Fade out to invisible
        }) { _ in
            self.notifyView?.removeFromSuperview() // Optionally remove from superview after fading out
        }
    }

    func playerDidLoad(playerVC: AVPlayerViewController) {
        self.playerVC = playerVC

        currentPlaySpeed = Settings.mediaPlayerSpeed
    }

    func playerDidChange(player: AVPlayer) {
        self.player = player
    }

    func playerWillStart(player: AVPlayer) {
        playerVC?.selectSpeed(AVPlaybackSpeed(rate: currentPlaySpeed.value, localizedName: currentPlaySpeed.name))
    }

    func playerDidStart(player: AVPlayer) {
        guard !hasShownSpeedNotification else { return }
        hasShownSpeedNotification = true

        // 只有在速度不为默认值1时才显示提示
        guard currentPlaySpeed != .default else { return }

        if notifyView == nil {
            notifyView = UILabel()
            notifyView?.backgroundColor = BLVisualTheme.cardBackground
            notifyView?.textColor = BLVisualTheme.textPrimary
            containerView?.addSubview(notifyView!)
            notifyView?.numberOfLines = 0
            notifyView?.layer.cornerRadius = 14
            notifyView?.layer.cornerCurve = .continuous
            notifyView?.layer.masksToBounds = true
            notifyView?.layer.borderWidth = 1
            notifyView?.layer.borderColor = BLVisualTheme.cardStroke.cgColor
            notifyView?.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
            notifyView?.textAlignment = NSTextAlignment.center
            notifyView?.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(380)
                make.height.equalTo(72)
            }
        }
        notifyView?.isHidden = false
        notifyView?.text = "播放速度设置为 \(currentPlaySpeed.name)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.fadeOutNotifyView()
        }
    }

    func addMenuItems(current: inout [UIMenuElement]) -> [UIMenuElement] {
        let gearImage = UIImage(systemName: "gearshape")

        let speedActions = PlaySpeed.blDefaults.map { playSpeed in
            UIAction(title: playSpeed.name, state: currentPlaySpeed == playSpeed ? .on : .off) {
                [weak self] _ in
                guard let self else { return }
                player?.currentItem?.audioTimePitchAlgorithm = .timeDomain
                playerVC?.selectSpeed(AVPlaybackSpeed(rate: playSpeed.value, localizedName: playSpeed.name))
                currentPlaySpeed = playSpeed
            }
        }
        let playSpeedMenu = UIMenu(title: "播放速度", options: [.displayInline, .singleSelection], children: speedActions)
        let menu = UIMenu(title: "播放设置", image: gearImage, identifier: UIMenu.Identifier(rawValue: "setting"), children: [playSpeedMenu])
        return [menu]
    }
}

struct PlaySpeed: Codable {
    var name: String
    var value: Float
}

extension PlaySpeed: Equatable {
    static let `default` = PlaySpeed(name: "1X", value: 1)

    static let blDefaults = [
        PlaySpeed(name: "0.5X", value: 0.5),
        PlaySpeed(name: "0.75X", value: 0.75),
        PlaySpeed(name: "1X", value: 1),
        PlaySpeed(name: "1.25X", value: 1.25),
        PlaySpeed(name: "1.5X", value: 1.5),
        PlaySpeed(name: "2X", value: 2),
    ]
}
