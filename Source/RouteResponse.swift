//
//  RouteResponse.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import UIKit

public final class RouteResponse {
    var viewController: UIViewController?

    private let url: URLComponentsConvertible

    init(url: URLComponentsConvertible) {
        self.url = url
    }

    func asyncGetViewController(_ completionHandler: @escaping RouteCompletionHandler<UIViewController>) {
        if let vc = viewController {
            completionHandler(.success(vc))
            return
        }
        UIViewControllerRouter.shared.route(url: url) { result in
            switch result {
            case .success(let vc):
                self.viewController = vc
            case .failure(let error):
                UIViewControllerRouter.shared.errorHandler?.handle(error: error)
            }
            completionHandler(result)
        }
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

    public func push(by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = self.viewController {
            let root = root ?? self.getVisibleViewController()
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

    public func present(by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = self.viewController {
            let root = root ?? self.getVisibleViewController()
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

    public func presentWithNavigationController<N: UINavigationController>(_ type: N.Type, by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        if let vc = self.viewController {
            let root = root ?? self.getVisibleViewController()
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
