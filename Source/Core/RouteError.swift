//
//  RouteError.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit

/// 路由错误
public enum RouteError {
    /// 路由地址格式错误
    case badURL(url: String)
    /// 尝试注册路由但地址已存在
    case alreadyExist(url: String)
    /// 路由终点页面未注册
    case routeDoesNotExist(url: String)
    /// 参数验证失败
    case parameterValidationFailed(vcType: UIViewController.Type, name: String)
}

// MARK: - LocalizedError

extension RouteError: LocalizedError {

    /// 错误信息
    public var errorDescription: String? {
        switch self {
            case .badURL(url: let url):
                return "路由失败 路径[\(url)]"
            case .alreadyExist(url: let url):
                return "路由失败 路径[\(url)]"
            case .routeDoesNotExist(url: let url):
                return "路由失败 路径[\(url)]"
            case .parameterValidationFailed(vcType: let type, name: let name):
                return "路由参数验证失败 页面[\(type)] 参数[\(name)]"
        }
    }

    /// 错误发生原因
    public var failureReason: String? {
        switch self {
            case .badURL:
                return "路由地址格式错误"
            case .alreadyExist:
                return "尝试注册路由但地址已存在"
            case .routeDoesNotExist:
                return "路由终点页面未注册"
            case .parameterValidationFailed(vcType: _, name: let name):
                return "未能获取参数[\(name)]"
        }
    }
}
