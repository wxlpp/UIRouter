//
//  RouteErrorHandling.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import Foundation

/// 实现`RouteErrorHandling`完成路由错误的集中处理
public protocol RouteErrorHandling {

    /// 处理所有错误,已有默认实现,无需实现
    /// - Parameter error: 任意错误
    func handle(error: Error)

    /// 处理路由错误
    /// - Parameter error: 一个`RouteError`实例
    func handleRouteError(_ error: RouteError)

    /// 处理自定义错误
    /// - Parameter error: 用户自定义的错误
    func handleCustomError(_ error: Error)
}

public extension RouteErrorHandling {
    func handle(error: Error) {
        switch error {
            case let rooError as RouteError:
                handleRouteError(rooError)
            default:
                handleCustomError(error)
        }
    }
}
