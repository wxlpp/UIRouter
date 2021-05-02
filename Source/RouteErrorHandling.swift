//
//  RouteErrorHandling.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import Foundation

public protocol RouteErrorHandling {
    func handle(error: Error)
    func handleRouteError(_ error: RouteError)
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
