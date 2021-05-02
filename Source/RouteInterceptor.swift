//
//  RouteInterceptor.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit

public protocol RouteInterceptor {
    func handle(components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController?>)
}

extension URLRouter: RouteInterceptor where Output == UIViewController {
    public func handle(components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController?>) {
        route(url: components) { result in
            completionHandler(result.map({ $0 as UIViewController?}))
        }
    }
}
