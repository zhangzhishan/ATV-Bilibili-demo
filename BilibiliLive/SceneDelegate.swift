//
//  SceneDelegate.swift
//  BilibiliLive
//

import AVFoundation
import CocoaLumberjackSwift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.tintColor = BLVisualTheme.accent
        window.overrideUserInterfaceStyle = .dark
        self.window = window

        if ApiRequest.isLogin() {
            if let expireDate = ApiRequest.getToken()?.expireDate {
                let now = Date()
                if expireDate.timeIntervalSince(now) < 60 * 60 * 30 {
                    ApiRequest.refreshToken()
                }
            } else {
                ApiRequest.refreshToken()
            }
            window.rootViewController = MainViewController()
        } else {
            window.rootViewController = LoginViewController.create()
        }
        window.makeKeyAndVisible()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        } catch {
            DDLogError("Failed to configure playback audio session: \(error)")
        }
    }

    func showLogin() {
        replaceRootViewController(with: LoginViewController.create(), animated: false)
    }

    func showTabBar() {
        replaceRootViewController(with: MainViewController(), animated: false)
    }

    func resetTabBar() {
        replaceRootViewController(with: MainViewController(), animated: true)
    }

    private func replaceRootViewController(with viewController: UIViewController, animated: Bool) {
        guard let window else { return }
        if animated, let snapshot = window.snapshotView(afterScreenUpdates: false) {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            viewController.view.addSubview(snapshot)
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.alpha = 0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
        } else {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
