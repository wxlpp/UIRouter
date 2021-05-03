//
//  URLComponentsConvertible.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import Foundation

/// Types adopting the `URLComponentsConvertible` protocol can be used to construct `URLComponents`s, which can then be used to route.
public protocol URLComponentsConvertible {
    /// 如果构造成功则返回一个 `URLComponents`,否则抛出异常.
    ///
    /// - Returns: 构造成功的`URLComponents`
    /// - Throws:  一个`RouteError.badURL(url:)` 实例.
    func asURLComponents() throws -> URLComponents
}

extension String: URLComponentsConvertible {

    /// 如果构造成功则返回一个 `URLComponents`,否则抛出异常.
    ///
    /// - Returns: 构造成功的`URLComponents`
    /// - Throws:  一个`RouteError.badURL(url:)` 实例.
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(string: trimmingCharacters(in: .whitespaces)) else {
            throw RouteError.badURL(url: self)
        }
        return components
    }
}

extension URL: URLComponentsConvertible {
    /// 如果构造成功则返回一个 `URLComponents`,否则抛出异常.
    ///
    /// - Returns: 构造成功的`URLComponents`
    /// - Throws:  一个`RouteError.badURL(url:)` 实例.
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw RouteError.badURL(url: absoluteString)
        }
        return components
    }
}

extension URLComponents: URLComponentsConvertible {
    /// 如果构造成功则返回一个 `URLComponents`,否则抛出异常.
    ///
    /// - Returns: 构造成功的`URLComponents`
    /// - Throws:  一个`RouteError.badURL(url:)` 实例.
    public func asURLComponents() throws -> URLComponents { self }
}
