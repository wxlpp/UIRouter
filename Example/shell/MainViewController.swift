//
//  MainViewController.swift
//  shell
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit
import UIRouter
class MainViewController: UITableViewController {
    let routes = [(name: "SubModule", path: "sub"),
                  (name: "Baidu", path: "https://www.baidu.com"),
                  (name: "用户简介", path: "user/profile")]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        var contentConfiguration = UIListContentConfiguration.cell()
        contentConfiguration.text = routes[indexPath.row].name
        cell.contentConfiguration = contentConfiguration
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIApplication.shared.route(url: routes[indexPath.row].path).push()
        UIApplication.shared.route(url: routes[indexPath.row].path).presentWithNavigationController(UINavigationController.self)
    }
}
