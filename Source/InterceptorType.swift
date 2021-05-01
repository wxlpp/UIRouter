//
//  InterceptorType.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import Foundation

public protocol InterceptorType {
    func handle(components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController?>)
}

extension URLRouter: InterceptorType where Output == UIViewController {
    public func handle(components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController?>) {
        route(url: components) { result in
            completionHandler(result.map({ $0 as UIViewController?}))
        }
    }
}
