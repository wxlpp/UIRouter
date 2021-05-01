//
//  SubViewController.swift
//  Submodule
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit
import UIRouter

public final class SubViewController: UIViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Sub"
    }
}

// MARK: - 路由

extension SubViewController: Routable {
    public static func route(parameters: RouterParameters, completion: @escaping RouteCompletionHandler<SubViewController>) {
        completion(.success(SubViewController()))
    }

    public static var path: String {
        "sub"
    }
}
