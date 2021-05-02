//
//  UserProfileViewController.swift
//  Submodule
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit
import UIRouter

public final class UserProfileViewController: UIViewController {}

// MARK: 路由

extension UserProfileViewController: Routable {
    public static func route(parameters: RouterParameters, completion: @escaping RouteCompletionHandler<UserProfileViewController>) {
        if let userID: String = parameters.get("userID") {
            completion(.success(UserProfileViewController()))
        } else {
            completion(.failure(RouteError.parameterValidationFailed(url: path, name: "userID")))
        }
    }

    public static var path: String {
        "user/profile/:id"
    }
}
