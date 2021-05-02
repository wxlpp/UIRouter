//
//  ErrorDetailsViewController.swift
//  shell
//
//  Created by wxlpp on 2021/5/1.
//

import UIKit

class ErrorDetailsViewController: UITableViewController {
    let error: Error
    let errorDetails: [(key: String,value: String)]

    init(error: Error) {
        self.error = error
        if let localizedError = error as? LocalizedError {
            var list: [(key: String,value: String)] = []
            if let errorDescription = localizedError.errorDescription {
                list.append(("简述",errorDescription))
            }
            if let failureReason = localizedError.failureReason {
                list.append(("原因",failureReason))

            }
            if let helpAnchor = localizedError.helpAnchor {
                list.append(("解决",helpAnchor))

            }
            if let recoverySuggestion = localizedError.recoverySuggestion {
                list.append(("恢复",recoverySuggestion))

            }
            errorDetails = list
        }else {
            errorDetails = [("错误",error.localizedDescription)]
        }
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "错误信息"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        errorDetails.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        var contentConfiguration = UIListContentConfiguration.subtitleCell()
        contentConfiguration.text = errorDetails[indexPath.row].key
        contentConfiguration.secondaryText = errorDetails[indexPath.row].value
        cell.contentConfiguration = contentConfiguration
        return cell
    }
}
