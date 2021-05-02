//
//  URLComponentsConvertible.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
//

import Foundation

public protocol URLComponentsConvertible {
    func asURLComponents() throws -> URLComponents
}

extension String: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(string: trimmingCharacters(in: .whitespaces)) else {
            throw RouteError.badURL(url: self)
        }
        return components
    }
}

extension URL: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw RouteError.badURL(url: self.absoluteString)
        }
        return components
    }
}

extension URLComponents: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents { self }
}

