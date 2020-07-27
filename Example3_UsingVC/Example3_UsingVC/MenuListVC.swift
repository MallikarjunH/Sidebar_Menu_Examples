//
//  MenuListVC.swift
//  Example3_UsingVC
//
//  Created by Mallikarjun on 14/07/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit

class MenuListVC: UITableViewController {

    var itemsList:[String] = ["First", "Second", "Third"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MenuListTableViewCell.self, forCellReuseIdentifier: "MenuListTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuListTableViewCell") as! MenuListTableViewCell
        
        cell.menuLabel.text = "Test"//itemsList[indexPath.row]
        
        return cell
    }


}
