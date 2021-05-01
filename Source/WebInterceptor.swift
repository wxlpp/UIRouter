//
//  WebInterceptor.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import SafariServices
import UIKit

open class WebInterceptor: InterceptorType {

    public init() {}
    open func handle(components: URLComponents, completionHandler: @escaping RouteCompletionHandler<UIViewController?>) {
        if components.scheme?.hasPrefix("http") ?? false {
            if let url = components.url {
                let vc = SFSafariViewController(url: url)
                completionHandler(.success(vc))
            }
        } else {
            completionHandler(.success(nil))
        }
    }
}
