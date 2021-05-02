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


/// 一个路由器可以通过解析链接获得一个指定的`UIViewController`实例
public class UIViewControllerRouter {
    private var isInitialized = false

    static let shared = UIViewControllerRouter()
    private let urlRouter = URLRouter<UIViewController>()
    private var interceptors: [RouteInterceptor] = []
    private(set) var errorHandler: RouteErrorHandling?
    private var lock = pthread_rwlock_t()

    init() {
        pthread_rwlock_init(&lock, nil)
        interceptors.append(urlRouter)
    }

    deinit {
        pthread_rwlock_destroy(&self.lock)
    }

    
    /// 如果路由未注册,自动进行注册
    public func autoRegisterIfNeed() {
        if !isInitialized {
            DispatchQueue(label: "com.router.register").async {
                self.registerIfNeed()
            }
        }
    }

    
    /// 注册拦截器
    /// - Parameter interceptors: 拦截器数组
    public func register(interceptors: [RouteInterceptor]) {
        let last = self.interceptors.removeLast()
        self.interceptors.append(contentsOf: interceptors)
        self.interceptors.append(last)
    }

    
    /// 注册错误处理器
    /// - Parameter handler: 一个错误处理器
    public func registerErrorHandler(_ handler: RouteErrorHandling) {
        errorHandler = handler
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

    func handleInterceptor(interceptors: [RouteInterceptor], components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController>) {
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
}
