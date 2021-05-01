//
// PathComponent.swift
//
// Created by wxlpp on 2021/5/1.
// Copyright © 2021 Wang Xiaolong. All rights reserved.
//

import Foundation

public enum PathComponent: ExpressibleByStringLiteral, CustomStringConvertible {

    case constant(String)

    case parameter(String)

    case anything

    case catchall

    public init(stringLiteral value: String) {
        if value.hasPrefix(":") {
            self = .parameter(.init(value.dropFirst()))
        } else if value == ":" {
            self = .anything
        } else if value == "*" {
            self = .catchall
        } else {
            self = .constant(value)
        }
    }

    public var description: String {
        switch self {
            case .anything: return ":"
            case .catchall: return "*"
            case .parameter(let name): return ":" + name
            case .constant(let constant): return constant
        }
    }
}

public extension Array where Element == PathComponent {

    var string: String {
        map(\.description).joined(separator: "/")
    }
}
