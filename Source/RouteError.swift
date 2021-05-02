//
//  RouteError.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import Foundation

public enum RouteError {
    /// 路由地址格式错误
    case badURL(url: String)
    /// 尝试注册路由但地址已存在
    case alreadyExist(url: String)
    /// 路由终点页面未注册
    case routeDoesNotExist(url: String)
    /// 参数验证失败
    case parameterValidationFailed(url: String,name: String)
}

// MARK: - LocalizedError

extension RouteError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badURL(url: let url):
            return "路由失败 路径[\(url)]"
        case .alreadyExist(url: let url):
            return "路由失败 路径[\(url)]"
        case .routeDoesNotExist(url: let url):
            return "路由失败 路径[\(url)]"
        case .parameterValidationFailed(url: let url, name: let name):
            return "路由参数验证失败 路径[\(url)] 参数[\(name)]"
        }
    }
    public var failureReason: String? {
        switch self {
        case .badURL(url: let url):
            return "路由地址格式错误"
        case .alreadyExist(url: let url):
            return "尝试注册路由但地址已存在"
        case .routeDoesNotExist(url: let url):
            return "路由终点页面未注册"
        case .parameterValidationFailed(url: let url, name: let name):
            return "未能获取参数[\(name)]"
        }
    }
}
