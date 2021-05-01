//
// Route.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import UIKit

public typealias RouteCompletionHandler<T> = (Result<T, Error>) -> Void
public typealias RouterHandler<T> = (RouterParameters, @escaping RouteCompletionHandler<T>) -> Void

struct Route<Output> {

    var path: [PathComponent]

    var handler: RouterHandler<Output>

    init(path: [PathComponent], handler: @escaping RouterHandler<Output>) {
        self.path = path
        self.handler = handler
    }
}
