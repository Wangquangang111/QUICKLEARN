//
//  HistoryListViewController.swift
//  QUICKLEARN
//
//  Created by  wangquangang on 2019/10/24.
//  Copyright © 2019 wangquangang. All rights reserved.
//

import UIKit

class HistoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var historySearchBar: UISearchBar!
    @IBOutlet weak var historyTableView: UITableView!
    var dataArr = [[String]]()
    var searchArray = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserDefaults.standard.array(forKey: "languageData") as? [[String]] {
            dataArr = data
            searchArray = dataArr
        }
    }

    func searchArr(text: String) -> [[String]] {
        var array = [[String]]()
        for data in dataArr {
            if hasSearchString(data: data, text: text) {
                array.append(data)
            }
        }
        return array
    }

    func hasSearchString(data: [String], text: String) -> Bool {
        for item in data {
            if item.contains(text) {
                return true
            }
        }
        return false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            searchArray = searchArr(text: searchText)
        } else {
            searchArray = dataArr
        }
        historyTableView.reloadData()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < searchArray.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "historycell") as? HistoryCell {
                let data = searchArray[indexPath.row]
                if data.count >= 2 {
                    cell.englishTextView.text = data[0]
                    cell.chineseTextView.text = data[1]
                }
                return cell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
