//
//  RouteRequest.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import UIKit

/// 路由请求包装,由此可以进行简便的页面跳转操作.
public final class RouteRequest {
    var viewController: UIViewController?

    private let url: URLComponentsConvertible
    private let object: Any?

    init(url: URLComponentsConvertible, object: Any?) {
        self.url = url
        self.object = object
    }

    private func getVisibleViewController() -> UIViewController? {
        let keyWindow: UIWindow?
        if #available(iOS 13.0.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter(\.isKeyWindow).first
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow?.rootViewController?.visibleViewController()
    }

    /// 异步获取路由结果页面
    /// - Parameter completionHandler: 异步回调
    public func asyncGetViewController(_ completionHandler: @escaping RouteCompletionHandler<UIViewController>) {
        if let vc = viewController {
            completionHandler(.success(vc))
            return
        }
        UIViewControllerRouter.shared.route(url: url, object: object) { result in
            switch result {
                case .success(let vc):
                    self.viewController = vc
                case .failure(let error):
                    UIViewControllerRouter.shared.errorHandler?.handle(error: error)
            }
            completionHandler(result)
        }
    }

    /// 进行页面跳转
    /// - Parameters:
    ///   - root: 使用这个`UIViewController`的`UINavigationController`进行页面跳转
    ///   - animated: 是否开启动画
    ///   - completionHandler: 异步回调结果
    public func push(by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = viewController {
            let root = root ?? getVisibleViewController()
            root?.navigationController?.pushViewController(vc, animated: animated)
            completionHandler?(.success(vc))
            return
        }
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    let root = root ?? self.getVisibleViewController()
                    root?.navigationController?.pushViewController(vc, animated: animated)
                    completionHandler?(.success(vc))
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }

    /// 弹出页面
    /// - Parameters:
    ///   - root: 使用这个`UIViewController`进行弹出
    ///   - animated: 是否开启动画
    ///   - completionHandler: 异步回调结果
    public func present(by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = viewController {
            let root = root ?? getVisibleViewController()
            root?.present(vc, animated: animated, completion: {
                completionHandler?(.success(vc))
            })
            return
        }
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    let root = root ?? self.getVisibleViewController()
                    root?.present(vc, animated: animated, completion: {
                        completionHandler?(.success(vc))
                    })
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }

    /// 将页面包裹在`UINavigationController`中后弹出
    /// - Parameters:
    ///   - type: `UINavigationController`的类型
    ///   - root: 使用这个`UIViewController`进行弹出
    ///   - animated: 是否开启动画
    ///   - completionHandler: 完成后异步回调
    public func presentWithNavigationController<N: UINavigationController>(_ type: N.Type, by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = viewController {
            let root = root ?? getVisibleViewController()
            root?.present(type.init(rootViewController: vc), animated: animated, completion: {
                completionHandler?(.success(vc))
            })
            return
        }
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    let root = root ?? self.getVisibleViewController()
                    root?.present(type.init(rootViewController: vc), animated: animated, completion: {
                        completionHandler?(.success(vc))
                    })
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }
}
