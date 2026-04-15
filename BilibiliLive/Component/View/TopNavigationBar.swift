import UIKit
import SnapKit

class TopNavigationBar: UIView {

    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(hex: 0x0C0E12, alpha: 0.8)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.text = "The Neon Observatory"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .black)
        titleLabel.textColor = BLVisualTheme.accent

        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(48)
            make.centerY.equalToSuperview()
        }

        container.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 48
        stackView.alignment = .center

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(60)
            make.centerY.equalToSuperview()
        }

        let tabs = ["Home", "Live", "Anime", "My"]
        for (index, tab) in tabs.enumerated() {
            let label = UILabel()
            label.text = tab
            if index == 0 {
                label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                label.textColor = BLVisualTheme.accent
            } else {
                label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
                label.textColor = BLVisualTheme.textSecondary
            }
            stackView.addArrangedSubview(label)
        }

        let rightStack = UIStackView()
        rightStack.axis = .horizontal
        rightStack.spacing = 24
        rightStack.alignment = .center

        let settingsIcon = UIImageView(image: UIImage(systemName: "gearshape.fill"))
        settingsIcon.tintColor = BLVisualTheme.textSecondary
        settingsIcon.contentMode = .scaleAspectFit
        settingsIcon.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }

        let profileIcon = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        profileIcon.tintColor = BLVisualTheme.accent
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }

        rightStack.addArrangedSubview(settingsIcon)
        rightStack.addArrangedSubview(profileIcon)

        container.addSubview(rightStack)
        rightStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-48)
            make.centerY.equalToSuperview()
        }
    }
}
