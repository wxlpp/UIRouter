//
//  RouteErrorInterceptor.swift
//  shell
//
//  Created by wxlpp on 2021/5/1.
//

import UIRouter

class RouteErrorHandler: RouteErrorHandler {
    override func handleRouteError(_ error: RouteError) {
        #if DEBUG
            let vc = ErrorDetailsViewController(error: error)
            UIApplication.shared.route(viewcontroller: vc).presentWithNavigationController(UINavigationController.self)
        #else
            debugPrint(error.errorDescription)
        #endif
    }

    override func handleCustomError(_ error: Error) {
        
    }
}
