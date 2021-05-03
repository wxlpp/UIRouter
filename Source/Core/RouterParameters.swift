//
//  RouterParameters.swift
//  UIRouter
//
//  Created by wxlpp on 2021/5/2.
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
    ///   - value: 参数
    ///   - name: 名称
    mutating func set<T>(_ value: T?, to name: String) where T: CustomStringConvertible {
        append(URLQueryItem(name: name, value: value?.description))
    }
}
