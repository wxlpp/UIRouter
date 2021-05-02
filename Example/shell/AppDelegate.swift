//
//  AppDelegate.swift
//  Example
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit
import UIRouter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        application.router.isNeedAutoRegister = true
        application.router.register(interceptors: [WebInterceptor()])
        application.router.registerErrorHandler(RouteErrorHandler())
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
