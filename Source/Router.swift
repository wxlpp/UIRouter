//
// Router.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import UIKit

public protocol RouteBase: UIViewController {
    static var path: String { get }
    static func routeVC(parameters: RouterParameters, completion: @escaping RouteCompletionHandler<UIViewController>)
}

/// 需要通过路由解耦的 `UIViewController` 实现此协议后,路由中心将会自动完成组件的注册
public protocol Routable: RouteBase {

    /// 路由中心通过路由链接到指定 `UIViewController` 后由此回调进行页面构造
    /// - Parameters:
    ///   - parameters: 由路由 `URL` 解析后传递的参数
    ///   - completion: 验证参数后构造页面通过回调返回结果
    static func route(parameters: RouterParameters, completion: @escaping RouteCompletionHandler<Self>)
}

public extension Routable {
    static func routeVC(parameters: RouterParameters, completion: @escaping RouteCompletionHandler<UIViewController>) {
        route(parameters: parameters) { result in
            completion(result.map { $0 as UIViewController })
        }
    }
}

public class UIViewControllerRouter {
    private var isInitialized = false
    public var isNeedAutoRegister = false {
        didSet {
            if !isInitialized {
                registerIfNeed()
            }
        }
    }

    static let shared = UIViewControllerRouter()
    private let urlRouter = URLRouter<UIViewController>()
    private var interceptors: [InterceptorType] = []
    private var lock = pthread_rwlock_t()

    init() {
        pthread_rwlock_init(&lock, nil)
        interceptors.append(urlRouter)
    }

    deinit {
        pthread_rwlock_destroy(&self.lock)
    }

    func autoRegisterIfNeed() {
        if isNeedAutoRegister {
            DispatchQueue.global().async {
                self.registerIfNeed()
            }
        }
    }

    func registerIfNeed() {
        if isInitialized {
            return
        }
        pthread_rwlock_wrlock(&lock)
        let numberOfClasses = Int(objc_getClassList(nil, 0))
        if numberOfClasses > 0 {
            let classesPtr = UnsafeMutablePointer<AnyClass>.allocate(capacity: numberOfClasses)
            let autoreleasingClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(classesPtr)
            let count = objc_getClassList(autoreleasingClasses, Int32(numberOfClasses))
            assert(numberOfClasses == count)
            defer { classesPtr.deallocate() }
            for i in 0 ..< numberOfClasses {
                let item: AnyClass = classesPtr[i]
                if let vcType = item as? RouteBase.Type {
                    try? urlRouter.register(route: vcType.path) { parameters, completion in
                        vcType.routeVC(parameters: parameters, completion: completion)
                    }
                }
            }
        }
        isInitialized = true
        pthread_rwlock_unlock(&lock)
    }

    func handleInterceptor(interceptors: [InterceptorType], components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController>) {
        if interceptors.isEmpty {
            return
        }
        var interceptors = interceptors
        let interceptor = interceptors.removeFirst()
        interceptor.handle(components: components) {[weak self] result in
            switch result {
                case .success(let vc):
                    if let vc = vc {
                        completionHandler(.success(vc))
                    } else {
                        self?.handleInterceptor(interceptors: interceptors, components: components, completionHandler: completionHandler)
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
            }
        }
    }

    func route(url: URLComponentsConvertible, completionHandler: @escaping RouteCompletionHandler<UIViewController>) {
        do {
            let components = try url.asURLComponents()
            registerIfNeed()
            pthread_rwlock_rdlock(&lock)
            handleInterceptor(interceptors: interceptors, components: components) {[weak self] result in
                switch result {
                    case .success(let vc):
                        completionHandler(.success(vc))
                    case .failure(let error):
                        completionHandler(.failure(error))
                }
                if let self = self {
                    pthread_rwlock_unlock(&self.lock)
                }
            }
        } catch {
            completionHandler(.failure(error))
        }
    }

    public func register<T: InterceptorType>(interceptors: [T]) {
        let last = self.interceptors.removeLast()
        self.interceptors.append(contentsOf: interceptors)
        self.interceptors.append(last)
    }
}

public final class UIRouter {
    private var viewController: UIViewController?

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
            self.viewController = try? result.get()
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
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    if let vc = self.viewController {
                        let root = root ?? self.getVisibleViewController()
                        root?.navigationController?.pushViewController(vc, animated: animated)
                        completionHandler?(.success(vc))
                    }
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }

    public func present(by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    if let vc = self.viewController {
                        let root = root ?? self.getVisibleViewController()
                        root?.present(vc, animated: animated, completion: {
                            completionHandler?(.success(vc))
                        })
                    }
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }

    public func presentWithNavigationController<N: UINavigationController>(_ type: N.Type, by root: UIViewController? = nil, animated: Bool = true, completionHandler: RouteCompletionHandler<UIViewController>? = nil) {
        asyncGetViewController { result in
            switch result {
                case .success(let vc):
                    if let vc = self.viewController {
                        let root = root ?? self.getVisibleViewController()
                        root?.present(type.init(rootViewController: vc), animated: animated, completion: {
                            completionHandler?(.success(vc))
                        })
                    }
                case .failure(let error):
                    completionHandler?(.failure(error))
            }
        }
    }
}

public extension UIApplication {

    var router: UIViewControllerRouter {
        .shared
    }

    @inline(__always)
    func route(url: URLComponentsConvertible) -> UIRouter {
        UIRouter(url: url)
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
