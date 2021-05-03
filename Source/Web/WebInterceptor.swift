//
//  WebInterceptor.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import SafariServices
import UIKit

/// 默认的网页拦截器,可以拦截`http`协议的链接,返回一个`SFSafariViewController`
open class WebInterceptor: RouteInterceptor {

    public init() {}

    /// 收到路由事件后由此进行拦截,可以继承后修改实现.
    /// - Parameters:
    ///   - components: 一个`URLComponents`实例,由路由链接构造.
    ///   - completionHandler: 拦截后由此进行回调.
    open func handle(components: URLComponents, object: Any?, completionHandler: @escaping RouteCompletionHandler<UIViewController?>) {
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
