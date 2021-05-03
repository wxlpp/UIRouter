//
// Route.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import UIKit

/// 路由结果回调闭包
public typealias RouteCompletionHandler<T> = (Result<T, Error>) -> Void
/// 路由处理闭包
public typealias RouterHandler<T> = (RouterParameters, Any?, @escaping RouteCompletionHandler<T>) -> Void

struct Route<Output> {

    var path: [PathComponent]

    var handler: RouterHandler<Output>

    init(path: [PathComponent], handler: @escaping RouterHandler<Output>) {
        self.path = path
        self.handler = handler
    }
}
