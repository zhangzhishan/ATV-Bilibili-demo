import UIKit
import SnapKit

class SideNavigationBar: UIView {

    private let stackView = UIStackView()
    private let profileContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = BLVisualTheme.sidebarBackground
        layer.shadowColor = BLVisualTheme.focusGlow.cgColor
        layer.shadowOffset = CGSize(width: 20, height: 0)
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 60

        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.centerX.equalToSuperview()
        }

        let icons = ["magnifyingglass", "chart.line.uptrend.xyaxis", "clock.arrow.circlepath"]
        for icon in icons {
            let iv = UIImageView(image: UIImage(systemName: icon))
            iv.tintColor = BLVisualTheme.textSecondary
            iv.contentMode = .scaleAspectFit
            iv.snp.makeConstraints { make in
                make.width.height.equalTo(44)
            }
            stackView.addArrangedSubview(iv)
        }

        addSubview(profileContainer)
        profileContainer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        let profileImageView = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        profileImageView.tintColor = BLVisualTheme.accent
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = BLVisualTheme.cardStroke

        profileContainer.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
