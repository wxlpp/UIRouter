//
//  UIKit[Router].swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import UIKit

public extension UIApplication {

    
    /// 返回 `UIViewControllerRouter.shared`
    var router: UIViewControllerRouter {
        .shared
    }
    
    /// 通过链接进行页面跳转
    /// - Parameter url: 路由链接
    /// - Returns: 返回一个`RouteRequest`实例
    @inline(__always)
    func route(url: URLComponentsConvertible) -> RouteRequest {
        RouteRequest(url: url)
    }

    
    /// 直接进行页面跳转
    /// - Parameter viewcontroller: 想要跳转的`UIViewController`实例
    /// - Returns: 返回一个`RouteRequest`实例
    func route(viewcontroller: UIViewController) -> RouteRequest {
        let router = RouteRequest(url: String(describing: viewcontroller))
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
