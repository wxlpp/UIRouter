//
// URLRouter.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import Foundation

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
            throw RouteError.alreadyExist(url: path)
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
                    parameters.set(path, to: name)
                    currentNode = parameter
                    continue search
                }

                if let anything = currentNode.anything {
                    currentNode = anything
                    continue search
                }

                guard let catchallHandle = currentNode.catchall?.handler else {
                    throw RouteError.routeDoesNotExist(url: components.path)
                }
                return catchallHandle(parameters, completionHandler)
            }
            guard let handle = currentNode.handler else {
                throw RouteError.routeDoesNotExist(url: components.path)
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
