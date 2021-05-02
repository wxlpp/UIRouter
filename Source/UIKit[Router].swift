//
//  UIKit[Router].swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import UIKit

public extension UIApplication {

    var router: UIViewControllerRouter {
        .shared
    }

    @inline(__always)
    func route(url: URLComponentsConvertible) -> RouteResponse {
        RouteResponse(url: url)
    }

    func route(viewcontroller: UIViewController) -> RouteResponse {
        let router = RouteResponse(url: String(describing: viewcontroller))
        router.viewController = viewcontroller
        return router
    }
}

extension UIViewController {
    func visibleViewController() -> UIViewController? {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.visibleViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController()
        }
        if isViewLoaded {
            return self
        }
        return nil
    }
}
