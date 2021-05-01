//
// URLRouter.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import Foundation
/// 路由参数集合
///
///
///     let parameters: RouterParameters = [URLQueryItem(name: "id", value: "0123456"),
///     URLQueryItem(name: "name", value: "wxlpp")]
///     let id: Int! = parameters.get("id")
///     print(id)
///     // Prints "0123456"
///     let name = parameters.get("name", as: String.self)
///     print(name)
///     // Prints "wxlpp"
///
public typealias RouterParameters = [URLQueryItem]

public extension RouterParameters {

    /// 将路由参数转为字典集合
    func toDictionary() -> [String: String] {
        var dic: [String: String] = [:]
        for parameter in self {
            dic.updateValue(parameter.value ?? "", forKey: parameter.name)
        }
        return dic
    }

    /// 获取
    /// - Parameters:
    ///   - name: 参数名称
    ///   - : 参数类型,需要符合`LosslessStringConvertible`协议
    /// - Returns: 返回找到的参数,不存在返回 nil
    func get<T>(_ name: String, as _: T.Type = T.self) -> T? where T: LosslessStringConvertible {
        first(where: { $0.name == name })?.value.flatMap(T.init)
    }

    /// 添加参数
    /// - Parameters:
    ///   - name: 参数名称
    ///   - value: 参数对应值
    mutating func set(_ name: String, to value: String?) {
        append(URLQueryItem(name: name, value: value))
    }
}

public protocol URLComponentsConvertible {
    func asURLComponents() throws -> URLComponents
}

extension String: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(string: trimmingCharacters(in: CharacterSet(charactersIn: " "))) else {
            throw URLError(.badURL)
        }
        return components
    }
}

extension URL: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLError(.badURL)
        }
        return components
    }
}

extension URLComponents: URLComponentsConvertible {
    public func asURLComponents() throws -> URLComponents { self }
}

open class URLRouter<Output>: CustomStringConvertible {
    private var root = Node()

    public init() {}
    public func register(route path: String, handler: @escaping RouterHandler<Output>) throws {
        var current = root
        for item in path.split(separator: "/") {
            let component = PathComponent(stringLiteral: String(item))
            current = current.buildOrFetchChild(for: component)
        }
        if current.handler != nil {
            throw URLError(.badURL)
        }

        current.handler = handler
    }

    open func route(url: URLComponentsConvertible, completionHandler: @escaping RouteCompletionHandler<Output>) {
        do {
            let components = try url.asURLComponents()
            var parameters = components.queryItems ?? []
            let pathComponents = components.path.split(separator: "/").map({String($0)})
            var currentNode: Node = root
            search: for path in pathComponents {
                if let constant = currentNode.constants[path] {
                    currentNode = constant
                    continue search
                }

                if let (name, parameter) = currentNode.parameter {
                    parameters.set(name, to: path)
                    currentNode = parameter
                    continue search
                }

                if let anything = currentNode.anything {
                    currentNode = anything
                    continue search
                }

                guard let catchallHandle = currentNode.catchall?.handler else {
                    throw URLError(.badURL)
                }
                return catchallHandle(parameters, completionHandler)
            }
            guard let handle = currentNode.handler else {
                throw URLError(.badURL)
            }
            return handle(parameters, completionHandler)
        } catch {
            completionHandler(.failure(error))
        }
    }

    public var description: String {
        root.description
    }
}

extension URLRouter {
    final class Node: CustomStringConvertible {
        var constants: [String: Node]
        var parameter: (String, Node)?
        var catchall: Node?
        var anything: Node?
        var handler: RouterHandler<Output>?

        init(handle: RouterHandler<Output>? = nil) {
            self.handler = handle
            self.constants = [String: Node]()
        }

        func buildOrFetchChild(for component: PathComponent) -> Node {
            switch component {
                case .constant(let string):
                    if let node = constants[string] {
                        return node
                    }
                    let node = Node()
                    constants[string] = node
                    return node
                case .parameter(let name):
                    let node: Node
                    if let (existingName, existingNode) = parameter {
                        node = existingNode
                        assert(existingName == name, "Route parameter name mis-match \(existingName) != \(name)")
                    } else {
                        node = Node()
                        parameter = (name, node)
                    }
                    return node
                case .catchall:
                    let node: Node
                    if let fallback = catchall {
                        node = fallback
                    } else {
                        node = Node()
                        catchall = node
                    }
                    return node
                case .anything:
                    let node: Node
                    if let anything = self.anything {
                        node = anything
                    } else {
                        node = Node()
                        anything = node
                    }
                    return node
            }
        }

        var description: String {
            var desc: [String] = []
            if let (name, parameter) = self.parameter {
                desc.append("→ \(name)")
                desc.append(parameter.description.indented())
            }
            if let catchall = self.catchall {
                desc.append("→ *")
                desc.append(catchall.description.indented())
            }
            if let anything = self.anything {
                desc.append("→ :")
                desc.append(anything.description.indented())
            }
            for (name, constant) in constants {
                desc.append("→ \(name)")
                desc.append(constant.description.indented())
            }
            return desc.joined(separator: "\n")
        }
    }
}

private extension String {
    func indented() -> String {
        split(separator: "\n").map { line in
            "  " + line
        }.joined(separator: "\n")
    }
}
