//
//  Routable.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/3.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import UIKit

public protocol RouteBase: UIViewController {
    static var paths: [String] { get }
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
