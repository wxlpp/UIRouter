//
//  RouteErrorHandler.swift
//  shell
//
//  Created by wxlpp on 2021/5/1.
//

import UIRouter

class RouteErrorHandler: RouteErrorHandling {
    func handleRouteError(_ error: RouteError) {
        #if DEBUG
            let vc = ErrorDetailsViewController(error: error)
            UIApplication.shared.route(viewcontroller: vc).presentWithNavigationController(UINavigationController.self)
        #else
            debugPrint(error.errorDescription)
        #endif
    }

    func handleCustomError(_ error: Error) {}
}
