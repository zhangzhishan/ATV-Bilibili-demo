//
//  LoginViewController.swift
//  BilibiliLive
//
//  Created by Etan Chen on 2021/3/28.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var qrcodeImageView: UIImageView!
    var currentLevel: Int = 0, finalLevel: Int = 200
    var timer: Timer?
    var oauthKey: String = ""

    static func create() -> LoginViewController {
        let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(identifier: "Login") as! LoginViewController
        return loginVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        applyModernBackgroundIfNeeded()
        styleLoginUI()
        BLTabBarViewController.clearSelected()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initValidation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        qrcodeImageView.image = nil
        stopValidationTimer()
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    func initValidation() {
        timer?.invalidate()
        ApiRequest.requestLoginQR { [weak self] code, url in
            guard let self else { return }
            let image = self.generateQRCode(from: url)
            self.qrcodeImageView.image = image
            self.oauthKey = code
            self.startValidationTimer()
        }
    }

    func startValidationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentLevel += 1
            if self.currentLevel > self.finalLevel {
                self.stopValidationTimer()
            }
            self.loopValidation()
        }
    }

    func stopValidationTimer() {
        timer?.invalidate()
        timer = nil
    }

    func didValidationSuccess() {
        qrcodeImageView.image = nil
        AppDelegate.shared.showTabBar()
        stopValidationTimer()
    }

    func loopValidation() {
        ApiRequest.verifyLoginQR(code: oauthKey) {
            [weak self] state in
            guard let self = self else { return }
            switch state {
            case .expire:
                self.initValidation()
            case .waiting:
                break
            case let .success(token, cookies):
                print(token)
                AccountManager.shared.registerAccount(token: token, cookies: cookies) { [weak self] _ in
                    self?.didValidationSuccess()
                }
            case .fail:
                break
            }
        }
    }

    @IBAction func actionStart(_ sender: Any) {
        initValidation()
    }

    private func styleLoginUI() {
        view.backgroundColor = .clear
        qrcodeImageView.backgroundColor = UIColor.white
        qrcodeImageView.layer.cornerRadius = 30
        qrcodeImageView.layer.cornerCurve = .continuous
        qrcodeImageView.layer.borderWidth = 1
        qrcodeImageView.layer.borderColor = BLVisualTheme.cardStroke.cgColor
        qrcodeImageView.clipsToBounds = true

        if let button = view.findSubview(of: UIButton.self) {
            button.configuration = UIButton.Configuration.filled()
            button.configuration?.title = "刷新二维码"
            button.configuration?.baseBackgroundColor = BLVisualTheme.accent
            button.configuration?.baseForegroundColor = UIColor.black
            button.configuration?.cornerStyle = .capsule
            button.titleLabel?.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        }

        let labels = view.findSubviews(of: UILabel.self)
        for label in labels {
            label.textColor = BLVisualTheme.textSecondary
            if label.font.pointSize >= 40 {
                label.textColor = BLVisualTheme.textPrimary
                label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
            }
        }
    }
}

private extension UIView {
    func findSubview<T: UIView>(of type: T.Type) -> T? {
        if let view = self as? T {
            return view
        }
        for child in subviews {
            if let found = child.findSubview(of: type) {
                return found
            }
        }
        return nil
    }

    func findSubviews<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        if let view = self as? T {
            result.append(view)
        }
        for child in subviews {
            result.append(contentsOf: child.findSubviews(of: type))
        }
        return result
    }
}
