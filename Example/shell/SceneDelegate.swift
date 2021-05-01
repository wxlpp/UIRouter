//
//  SceneDelegate.swift
//  Example
//
//  Created by wxlpp on 2021/5/1.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UINavigationController(rootViewController: MainViewController())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
